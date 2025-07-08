import 'dart:io';
import 'dart:typed_data';

import 'network_file_system.dart';

/// 使用系统级NFS挂载点进行文件访问
/// 支持通过本地挂载点访问NFS共享文件系统
class NFSFileSystem extends NetworkFileSystem {
  bool _isConnected = false;
  Directory? _mountDirectory;

  NFSFileSystem(super.config);

  @override
  Future<void> connect() async {
    try {
      // 尝试通过系统挂载点访问NFS
      await _establishNFSConnection();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      throw NetworkFileSystemException('NFS连接失败: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _mountDirectory = null;
  }

  @override
  Future<bool> ping() async {
    try {
      // 测试主机连通性
      final result = await Process.run(
          'ping', [Platform.isWindows ? '-n' : '-c', '1', config.host]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      // 构建实际的文件系统路径
      final targetPath = _buildLocalPath(path);
      final directory = Directory(targetPath);

      if (!await directory.exists()) {
        throw NetworkFileNotFoundException(path);
      }

      final files = <NetworkFileInfo>[];
      await for (final entity in directory.list()) {
        final stat = await entity.stat();
        final relativePath = _getRelativePath(entity.path);

        files.add(NetworkFileInfo(
          name: entity.path.split(Platform.pathSeparator).last,
          path: relativePath,
          isDirectory: entity is Directory,
          size: stat.size,
          lastModified: stat.modified,
        ));
      }

      return files;
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('列出NFS目录失败: $path - $e');
    }
  }

  @override
  Future<bool> exists(String path) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final targetPath = _buildLocalPath(path);
      final entity = FileSystemEntity.typeSync(targetPath);
      return entity != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final targetPath = _buildLocalPath(path);
      final entity = FileSystemEntity.typeSync(targetPath);

      if (entity == FileSystemEntityType.notFound) {
        return null;
      }

      final stat = await FileStat.stat(targetPath);
      final relativePath = _getRelativePath(targetPath);

      return NetworkFileInfo(
        name: path.split('/').last,
        path: relativePath,
        isDirectory: entity == FileSystemEntityType.directory,
        size: stat.size,
        lastModified: stat.modified,
      );
    } catch (e) {
      throw NetworkFileSystemException('获取NFS文件信息失败: $path - $e');
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final targetPath = _buildLocalPath(path);
      final file = File(targetPath);

      if (!await file.exists()) {
        throw NetworkFileNotFoundException(path);
      }

      return await file.readAsBytes();
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('下载NFS文件失败: $path - $e');
    }
  }

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    Function(int, int)? onProgress,
  }) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final sourceFile = File(localPath);
      if (!await sourceFile.exists()) {
        throw NetworkFileSystemException('本地文件不存在: $localPath');
      }

      final targetPath = _buildLocalPath(remotePath);
      final targetFile = File(targetPath);

      // 确保目标目录存在
      await targetFile.parent.create(recursive: true);

      final data = await sourceFile.readAsBytes();
      await targetFile.writeAsBytes(data);

      onProgress?.call(data.length, data.length);
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('上传文件到NFS失败: $remotePath - $e');
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final targetPath = _buildLocalPath(path);
      final directory = Directory(targetPath);
      await directory.create(recursive: true);
    } catch (e) {
      throw NetworkFileSystemException('创建NFS目录失败: $path - $e');
    }
  }

  @override
  Future<void> delete(String path) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final targetPath = _buildLocalPath(path);
      final entity = FileSystemEntity.typeSync(targetPath);

      if (entity == FileSystemEntityType.file) {
        await File(targetPath).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(targetPath).delete(recursive: true);
      } else {
        throw NetworkFileNotFoundException(path);
      }
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('删除NFS文件失败: $path - $e');
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    if (!_isConnected || _mountDirectory == null) {
      throw NetworkFileSystemException('NFS未连接');
    }

    try {
      final oldTargetPath = _buildLocalPath(oldPath);
      final newTargetPath = _buildLocalPath(newPath);

      final entity = FileSystemEntity.typeSync(oldTargetPath);
      if (entity == FileSystemEntityType.notFound) {
        throw NetworkFileNotFoundException(oldPath);
      }

      if (entity == FileSystemEntityType.file) {
        await File(oldTargetPath).rename(newTargetPath);
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(oldTargetPath).rename(newTargetPath);
      }
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('重命名NFS文件失败: $oldPath -> $newPath - $e');
    }
  }

  @override
  Future<void> downloadFileToLocal(
    String remotePath,
    String localPath, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final data = await downloadFile(remotePath);
      final file = File(localPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data);
      onProgress?.call(data.length, data.length);
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException(
          '下载文件到本地失败: $remotePath -> $localPath - $e');
    }
  }

  /// 建立NFS连接
  /// 尝试多种方式访问NFS共享
  Future<void> _establishNFSConnection() async {
    try {
      // 方式1: 检查是否已有挂载点
      await _findExistingMountPoint();

      if (_mountDirectory != null) {
        return; // 找到现有挂载点
      }

      // 方式2: 尝试创建临时挂载点 (需要管理员权限)
      if (Platform.isLinux || Platform.isMacOS) {
        await _createTemporaryMount();
      } else if (Platform.isWindows) {
        await _connectWindowsNFS();
      }

      if (_mountDirectory == null) {
        throw Exception('无法建立NFS连接，请确保NFS共享已正确挂载');
      }
    } catch (e) {
      throw NetworkFileSystemException('建立NFS连接失败: $e');
    }
  }

  /// 查找现有的NFS挂载点
  Future<void> _findExistingMountPoint() async {
    try {
      if (Platform.isLinux || Platform.isMacOS) {
        // 检查 /proc/mounts 或 mount 命令输出
        final result = await Process.run('mount', []);
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          for (final line in lines) {
            if (line.contains(config.host) && line.contains('nfs')) {
              final parts = line.split(' ');
              if (parts.length >= 3) {
                final mountPoint = parts[2];
                final dir = Directory(mountPoint);
                if (await dir.exists()) {
                  _mountDirectory = dir;
                  return;
                }
              }
            }
          }
        }
      } else if (Platform.isWindows) {
        // Windows: 检查网络驱动器
        final result = await Process.run('net', ['use']);
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          for (final line in lines) {
            if (line.contains(config.host)) {
              // 解析驱动器字母
              final match = RegExp(r'([A-Z]:)').firstMatch(line);
              if (match != null) {
                final driveLetter = match.group(1)!;
                final dir = Directory(driveLetter);
                if (await dir.exists()) {
                  _mountDirectory = dir;
                  return;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // 忽略查找错误，继续尝试其他方式
    }
  }

  /// 创建临时挂载点 (Linux/macOS)
  Future<void> _createTemporaryMount() async {
    try {
      // 创建临时挂载目录
      final tempDir = Directory.systemTemp;
      final mountDir =
          Directory('${tempDir.path}/nfs_${config.host}_${config.port}');

      if (!await mountDir.exists()) {
        await mountDir.create(recursive: true);
      }

      // 构建NFS挂载命令
      final nfsPath = '${config.host}:${config.remotePath}';
      final mountArgs = [
        '-t',
        'nfs',
        nfsPath,
        mountDir.path,
      ];

      // 添加挂载选项
      if (config.username?.isNotEmpty == true) {
        mountArgs.addAll(['-o', 'username=${config.username}']);
      }

      final result = await Process.run('mount', mountArgs);
      if (result.exitCode == 0) {
        _mountDirectory = mountDir;
      } else {
        throw Exception('挂载失败: ${result.stderr}');
      }
    } catch (e) {
      // 挂载失败，可能需要管理员权限
      throw Exception('创建NFS挂载失败: $e (可能需要管理员权限)');
    }
  }

  /// Windows NFS连接
  Future<void> _connectWindowsNFS() async {
    try {
      // Windows NFS客户端连接
      final nfsPath =
          '\\\\${config.host}\\${config.exportPath?.replaceAll('/', '\\')}';

      // 尝试直接访问UNC路径
      final dir = Directory(nfsPath);
      if (await dir.exists()) {
        _mountDirectory = dir;
        return;
      }

      // 尝试映射网络驱动器
      final result = await Process.run('net', [
        'use',
        '*',
        nfsPath,
        if (config.password?.isNotEmpty == true) config.password!,
        if (config.username?.isNotEmpty == true) '/user:${config.username}',
      ]);

      if (result.exitCode == 0) {
        // 解析分配的驱动器字母
        final output = result.stdout.toString();
        final match =
            RegExp(r'Drive ([A-Z]:) is now connected').firstMatch(output);
        if (match != null) {
          final driveLetter = match.group(1)!;
          _mountDirectory = Directory(driveLetter);
        }
      }
    } catch (e) {
      throw Exception('Windows NFS连接失败: $e');
    }
  }

  /// 构建本地文件系统路径
  String _buildLocalPath(String remotePath) {
    if (_mountDirectory == null) {
      throw NetworkFileSystemException('NFS未挂载');
    }

    // 清理路径
    String cleanPath = remotePath.replaceAll('//', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // 转换为本地路径分隔符
    if (Platform.isWindows) {
      cleanPath = cleanPath.replaceAll('/', '\\');
    }

    return '${_mountDirectory!.path}${Platform.pathSeparator}$cleanPath';
  }

  /// 获取相对路径
  String _getRelativePath(String localPath) {
    if (_mountDirectory == null) {
      return localPath;
    }

    final mountPath = _mountDirectory!.path;
    if (localPath.startsWith(mountPath)) {
      String relativePath = localPath.substring(mountPath.length);

      // 转换为Unix风格路径
      if (Platform.isWindows) {
        relativePath = relativePath.replaceAll('\\', '/');
      }

      if (!relativePath.startsWith('/')) {
        relativePath = '/$relativePath';
      }

      return relativePath;
    }

    return localPath;
  }
}

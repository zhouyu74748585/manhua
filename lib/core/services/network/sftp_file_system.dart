import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

import 'network_file_system.dart';

/// SFTP文件系统实现
/// 使用dartssh2包实现SFTP协议支持
class SFTPFileSystem extends NetworkFileSystem {
  SSHClient? _sshClient;
  SftpClient? _sftpClient;
  bool _isConnected = false;

  SFTPFileSystem(super.config);

  @override
  Future<void> connect() async {
    try {
      // 创建SSH客户端
      _sshClient = SSHClient(
        await SSHSocket.connect(
          config.host,
          config.port ?? 22,
          timeout: Duration(seconds: config.timeout),
        ),
        username: config.username ?? '',
        onPasswordRequest: () => config.password ?? '',
      );

      // 创建SFTP客户端
      _sftpClient = await _sshClient!.sftp();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      await _cleanup();

      if (e.toString().contains('authentication')) {
        throw NetworkAuthenticationException(details: e.toString());
      } else if (e.toString().contains('timeout')) {
        throw NetworkConnectionTimeoutException(config.host,
            details: e.toString());
      }

      throw NetworkFileSystemException(
        'SFTP连接失败',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await _cleanup();
  }

  @override
  Future<bool> ping() async {
    if (!_isConnected || _sftpClient == null) {
      return false;
    }

    try {
      // 尝试获取根目录信息来测试连接
      await _sftpClient!.stat('/');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    _ensureConnected();

    try {
      final items = await _sftpClient!.listdir(path);
      final result = <NetworkFileInfo>[];

      for (final item in items) {
        final fullPath = path.endsWith('/')
            ? '$path${item.filename}'
            : '$path/${item.filename}';

        result.add(NetworkFileInfo(
          name: item.filename,
          path: fullPath,
          isDirectory: item.attr.isDirectory,
          size: item.attr.size ?? 0,
          lastModified: item.attr.modifyTime != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  item.attr.modifyTime! * 1000)
              : null,
        ));
      }

      return result;
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP列出目录失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<bool> exists(String path) async {
    _ensureConnected();

    try {
      await _sftpClient!.stat(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    _ensureConnected();

    try {
      final stat = await _sftpClient!.stat(path);
      final fileName = _getFileName(path);

      return NetworkFileInfo(
        name: fileName,
        path: path,
        isDirectory: stat.isDirectory,
        size: stat.size ?? 0,
        lastModified: stat.modifyTime != null
            ? DateTime.fromMillisecondsSinceEpoch(stat.modifyTime! * 1000)
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    _ensureConnected();

    try {
      final file = await _sftpClient!.open(path);
      final data = await file.readBytes();
      await file.close();
      return data;
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP下载文件失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Stream<List<int>> downloadFileStream(String path, {int start = 0, int? length}) async* {
    // SFTP协议的流式下载实现，这里提供简化版本
    try {
      final data = await downloadFile(path);

      int currentPos = start;
      final endPos = length != null ? start + length : data.length;
      const chunkSize = 8192; // 8KB chunks

      while (currentPos < endPos && currentPos < data.length) {
        final chunkEnd = (currentPos + chunkSize < endPos)
            ? currentPos + chunkSize
            : endPos;

        if (chunkEnd <= data.length) {
          yield data.sublist(currentPos, chunkEnd);
        }
        currentPos = chunkEnd;
      }
    } catch (e) {
      throw NetworkFileSystemException('SFTP流式下载文件失败: $path', originalError: e);
    }
  }

  @override
  Future<void> downloadFileToLocal(
    String remotePath,
    String localPath, {
    Function(int downloaded, int total)? onProgress,
  }) async {
    _ensureConnected();

    try {
      // 获取文件大小
      final fileInfo = await getFileInfo(remotePath);
      final totalSize = fileInfo?.size ?? 0;

      // 打开远程文件
      final remoteFile = await _sftpClient!.open(remotePath);

      // 创建本地文件
      final localFile = File(localPath);
      final sink = localFile.openWrite();

      try {
        // 简化实现：直接读取整个文件
        final data = await remoteFile.readBytes();
        sink.add(data);
        onProgress?.call(data.length, totalSize);
      } finally {
        await sink.close();
        await remoteFile.close();
      }
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP下载文件到本地失败: $remotePath -> $localPath',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    Function(int uploaded, int total)? onProgress,
  }) async {
    _ensureConnected();

    try {
      final localFile = File(localPath);
      if (!await localFile.exists()) {
        throw NetworkFileSystemException('本地文件不存在: $localPath');
      }

      final totalSize = await localFile.length();
      final remoteFile = await _sftpClient!.open(
        remotePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write,
      );

      try {
        int uploaded = 0;

        await for (final chunk in localFile.openRead()) {
          await remoteFile.writeBytes(chunk as Uint8List);
          uploaded += chunk.length;
          onProgress?.call(uploaded, totalSize);
        }
      } finally {
        await remoteFile.close();
      }
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP上传文件失败: $localPath -> $remotePath',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    _ensureConnected();

    try {
      await _sftpClient!.mkdir(path);
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP创建目录失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String path) async {
    _ensureConnected();

    try {
      final fileInfo = await getFileInfo(path);
      if (fileInfo == null) {
        throw NetworkFileNotFoundException(path);
      }

      if (fileInfo.isDirectory) {
        await _sftpClient!.rmdir(path);
      } else {
        await _sftpClient!.remove(path);
      }
    } catch (e) {
      if (e is NetworkFileNotFoundException) {
        rethrow;
      }
      throw NetworkFileSystemException(
        'SFTP删除文件失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    _ensureConnected();

    try {
      await _sftpClient!.rename(oldPath, newPath);
    } catch (e) {
      throw NetworkFileSystemException(
        'SFTP重命名文件失败: $oldPath -> $newPath',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// 确保已连接
  void _ensureConnected() {
    if (!_isConnected || _sftpClient == null) {
      throw NetworkFileSystemException('SFTP未连接，请先调用connect()');
    }
  }

  /// 清理资源
  Future<void> _cleanup() async {
    try {
      _sftpClient?.close();
      _sshClient?.close();
    } catch (e) {
      // 忽略清理时的错误
    } finally {
      _sftpClient = null;
      _sshClient = null;
      _isConnected = false;
    }
  }

  /// 获取文件名
  String _getFileName(String path) {
    if (path == '/' || path.isEmpty) {
      return '';
    }
    final lastSlash = path.lastIndexOf('/');
    return path.substring(lastSlash + 1);
  }
}

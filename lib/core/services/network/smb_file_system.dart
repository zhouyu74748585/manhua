import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:smb_connect/smb_connect.dart';

import 'network_file_system.dart';

/// SMB/CIFS文件系统实现
/// 使用smb_connect包实现SMB协议支持
class SMBFileSystem extends NetworkFileSystem {
  SmbConnect? _smbClient;
  bool _isConnected = false;

  SMBFileSystem(super.config);

  @override
  Future<void> connect() async {
    // 如果已经连接，先断开
    if (_isConnected && _smbClient != null) {
      await disconnect();
    }

    try {
      _smbClient = await SmbConnect.connectAuth(
        host: config.host,
        domain: '',
        username: config.username ?? '',
        password: config.password ?? '',
      );

      _isConnected = true;
    } catch (e, stackTrace) {
      dev.log('SMB连接异常: $e, $stackTrace');
      _isConnected = false;
      // 确保清理资源
      await _cleanup();

      if (e.toString().contains('authentication') ||
          e.toString().contains('login')) {
        throw NetworkAuthenticationException(details: e.toString());
      } else if (e.toString().contains('timeout')) {
        throw NetworkConnectionTimeoutException(config.host,
            details: e.toString());
      }

      throw NetworkFileSystemException(
        'SMB连接失败',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await _cleanup();
  }

  /// 清理连接资源
  Future<void> _cleanup() async {
    try {
      if (_smbClient != null) {
        await _smbClient!.close();
      }
    } catch (e) {
      // 忽略断开连接时的错误，但记录日志
      print('SMB断开连接时发生错误: $e');
    } finally {
      _smbClient = null;
      _isConnected = false;
    }
  }

  @override
  Future<bool> ping() async {
    if (!_isConnected || _smbClient == null) {
      return false;
    }

    try {
      // 尝试列出共享来测试连接
      await _smbClient!.listShares();
      return true;
    } catch (e) {
      // 连接可能已断开，更新状态
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(path);
      final files = await _smbClient!.listFiles(smbFile);
      return files.map((file) => _convertToNetworkFileInfo(file)).toList();
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB列出目录失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<bool> exists(String path) async {
    _ensureConnected();

    try {
      await _smbClient!.file(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(path);
      return _convertToNetworkFileInfo(smbFile);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(path);
      final stream = await _smbClient!.openRead(smbFile);

      final chunks = <int>[];
      await for (final chunk in stream) {
        chunks.addAll(chunk);
      }

      return Uint8List.fromList(chunks);
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB下载文件失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Stream<List<int>> downloadFileStream(String path, {int start = 0, int? length}) async* {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(path);
      final stream = await _smbClient!.openRead(smbFile);

      int currentPosition = 0;
      int totalRead = 0;
      final targetLength = length ?? -1; // -1 表示读取到文件末尾

      await for (final chunk in stream) {
        // 跳过开始位置之前的数据
        if (currentPosition + chunk.length <= start) {
          currentPosition += chunk.length;
          continue;
        }

        // 计算当前chunk中需要的部分
        int chunkStart = 0;
        int chunkEnd = chunk.length;

        if (currentPosition < start) {
          chunkStart = start - currentPosition;
        }

        if (targetLength > 0 && totalRead + (chunkEnd - chunkStart) > targetLength) {
          chunkEnd = chunkStart + (targetLength - totalRead);
        }

        if (chunkStart < chunkEnd) {
          final relevantData = chunk.sublist(chunkStart, chunkEnd);
          totalRead += relevantData.length;
          yield relevantData;

          // 如果已读取足够数据，停止
          if (targetLength > 0 && totalRead >= targetLength) {
            break;
          }
        }

        currentPosition += chunk.length;
      }
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB流式下载文件失败: $path',
        details: e.toString(),
        originalError: e,
      );
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
      final smbFile = await _smbClient!.file(remotePath);
      final stream = await _smbClient!.openRead(smbFile);

      final localFile = File(localPath);
      final sink = localFile.openWrite();

      int downloaded = 0;
      final totalSize = smbFile.size ?? 0;

      try {
        await for (final chunk in stream) {
          sink.add(chunk);
          downloaded += chunk.length;
          onProgress?.call(downloaded, totalSize);
        }
      } finally {
        await sink.close();
      }
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB下载文件到本地失败: $remotePath -> $localPath',
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

      final smbFile = await _smbClient!.createFile(remotePath);
      final sink = await _smbClient!.openWrite(smbFile);

      final totalSize = await localFile.length();
      int uploaded = 0;

      try {
        await for (final chunk in localFile.openRead()) {
          sink.add(chunk);
          uploaded += chunk.length;
          onProgress?.call(uploaded, totalSize);
        }
      } finally {
        await sink.close();
      }
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB上传文件失败: $localPath -> $remotePath',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    _ensureConnected();

    try {
      await _smbClient!.createFolder(path);
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB创建目录失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> delete(String path) async {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(path);
      await _smbClient!.delete(smbFile);
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB删除文件失败: $path',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    _ensureConnected();

    try {
      final smbFile = await _smbClient!.file(oldPath);
      await _smbClient!.rename(smbFile, newPath);
    } catch (e) {
      throw NetworkFileSystemException(
        'SMB重命名文件失败: $oldPath -> $newPath',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// 确保已连接
  void _ensureConnected() {
    if (!_isConnected || _smbClient == null) {
      throw NetworkFileSystemException('SMB未连接，请先调用connect()');
    }
  }

  /// 异步确保已连接（支持自动重连）
  Future<void> _ensureConnectedAsync() async {
    if (!_isConnected || _smbClient == null) {
      throw NetworkFileSystemException('SMB未连接，请先调用connect()');
    }
  }

  /// 转换SMB文件信息为NetworkFileInfo
  NetworkFileInfo _convertToNetworkFileInfo(SmbFile smbFile) {
    return NetworkFileInfo(
      name: smbFile.name,
      path: smbFile.path,
      isDirectory: smbFile.isDirectory(),
      size: smbFile.size ?? 0,
      lastModified: smbFile.lastModified != null
          ? DateTime.fromMillisecondsSinceEpoch(smbFile.lastModified!)
          : null,
    );
  }
}

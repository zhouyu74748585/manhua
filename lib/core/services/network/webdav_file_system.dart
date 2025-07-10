import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;

import 'network_file_system.dart';

/// WebDAV文件系统实现
class WebDAVFileSystem extends NetworkFileSystem {
  webdav.Client? _client;
  bool _isConnected = false;

  WebDAVFileSystem(super.config);

  @override
  Future<void> connect() async {
    try {
      // 构建WebDAV服务器URL
      final uri = Uri.parse(config.host);
      final baseUrl = '${uri.scheme}://${uri.host}:${config.port}${uri.path}';

      // 创建WebDAV客户端
      _client = webdav.newClient(
        baseUrl,
        user: config.username ?? '',
        password: config.password ?? '',
        debug: false, // 生产环境关闭调试
      );

      // 设置超时时间
      _client!.setConnectTimeout(config.timeout * 1000);
      _client!.setSendTimeout(config.timeout * 1000);
      _client!.setReceiveTimeout(config.timeout * 1000);

      // 测试连接
      await _client!.ping();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      if (e.toString().contains('timeout')) {
        throw NetworkConnectionTimeoutException(config.host,
            details: e.toString());
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        throw NetworkAuthenticationException(details: e.toString());
      } else {
        throw NetworkFileSystemException('WebDAV连接失败', originalError: e);
      }
    }
  }

  @override
  Future<void> disconnect() async {
    _client = null;
    _isConnected = false;
  }

  @override
  Future<bool> ping() async {
    if (!_isConnected || _client == null) return false;

    try {
      await _client!.ping();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    _ensureConnected();

    try {
      final files = await _client!.readDir(path);
      return files.map((file) => _convertToNetworkFileInfo(file)).toList();
    } catch (e) {
      if (e.toString().contains('404')) {
        throw NetworkFileNotFoundException(path);
      } else if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(path);
      } else {
        throw NetworkFileSystemException('列出目录失败: $path', originalError: e);
      }
    }
  }

  @override
  Future<bool> exists(String path) async {
    _ensureConnected();

    try {
      await _client!.readDir(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    _ensureConnected();

    try {
      final parentPath = path.substring(0, path.lastIndexOf('/'));
      final fileName = path.substring(path.lastIndexOf('/') + 1);

      final files =
          await _client!.readDir(parentPath.isEmpty ? '/' : parentPath);
      final file = files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw NetworkFileNotFoundException(path),
      );

      return _convertToNetworkFileInfo(file);
    } catch (e) {
      if (e is NetworkFileNotFoundException) rethrow;
      return null;
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    _ensureConnected();

    try {
      final data = await _client!.read(path);
      return Uint8List.fromList(data);
    } catch (e) {
      if (e.toString().contains('404')) {
        throw NetworkFileNotFoundException(path);
      } else if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(path);
      } else {
        throw NetworkFileSystemException('下载文件失败: $path', originalError: e);
      }
    }
  }

  @override
  Stream<List<int>> downloadFileStream(String path,
      {int start = 0, int? length}) async* {
    // WebDAV协议的流式下载实现，这里提供简化版本
    try {
      final data = await downloadFile(path);

      int currentPos = start;
      final endPos = length != null ? start + length : data.length;
      const chunkSize = 8192; // 8KB chunks

      while (currentPos < endPos && currentPos < data.length) {
        final chunkEnd =
            (currentPos + chunkSize < endPos) ? currentPos + chunkSize : endPos;

        if (chunkEnd <= data.length) {
          yield data.sublist(currentPos, chunkEnd);
        }
        currentPos = chunkEnd;
      }
    } catch (e) {
      throw NetworkFileSystemException('WebDAV流式下载文件失败: $path',
          originalError: e);
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
      await _client!.read2File(
        remotePath,
        localPath,
        onProgress: onProgress,
      );
    } catch (e) {
      if (e.toString().contains('404')) {
        throw NetworkFileNotFoundException(remotePath);
      } else if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(remotePath);
      } else {
        throw NetworkFileSystemException('下载文件到本地失败: $remotePath',
            originalError: e);
      }
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
      await _client!.writeFromFile(
        localPath,
        remotePath,
        onProgress: onProgress,
      );
    } catch (e) {
      if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(remotePath);
      } else {
        throw NetworkFileSystemException('上传文件失败: $remotePath',
            originalError: e);
      }
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    _ensureConnected();

    try {
      await _client!.mkdir(path);
    } catch (e) {
      if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(path);
      } else {
        throw NetworkFileSystemException('创建目录失败: $path', originalError: e);
      }
    }
  }

  @override
  Future<void> delete(String path) async {
    _ensureConnected();

    try {
      await _client!.remove(path);
    } catch (e) {
      if (e.toString().contains('404')) {
        throw NetworkFileNotFoundException(path);
      } else if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(path);
      } else {
        throw NetworkFileSystemException('删除失败: $path', originalError: e);
      }
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    _ensureConnected();

    try {
      await _client!.rename(oldPath, newPath, true);
    } catch (e) {
      if (e.toString().contains('404')) {
        throw NetworkFileNotFoundException(oldPath);
      } else if (e.toString().contains('403')) {
        throw NetworkPermissionDeniedException(oldPath);
      } else {
        throw NetworkFileSystemException('重命名失败: $oldPath -> $newPath',
            originalError: e);
      }
    }
  }

  /// 确保已连接
  void _ensureConnected() {
    if (!_isConnected || _client == null) {
      throw NetworkFileSystemException('WebDAV客户端未连接');
    }
  }

  /// 转换WebDAV文件信息为通用文件信息
  NetworkFileInfo _convertToNetworkFileInfo(webdav.File file) {
    return NetworkFileInfo(
      name: file.name ?? '',
      path: file.path ?? '',
      isDirectory: file.isDir ?? false,
      size: file.size ?? 0,
      lastModified: file.mTime,
      mimeType: file.mimeType,
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../data/models/network_config.dart';
import 'network_file_system.dart';
import 'network_file_system_factory.dart';

/// HTTP/HTTPS文件系统实现
/// 支持基本的HTTP文件访问，主要用于访问Web服务器上的漫画文件
class HTTPFileSystem extends NetworkFileSystem {
  late final Dio _dio;
  bool _isConnected = false;

  HTTPFileSystem(super.config) {
    _initializeDio();
  }

  /// 初始化Dio客户端
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _buildBaseUrl(),
      connectTimeout: Duration(seconds: config.timeout),
      receiveTimeout: Duration(seconds: config.timeout),
      sendTimeout: Duration(seconds: config.timeout),
      headers: {
        'User-Agent': 'MangaReader/1.0',
      },
    ));

    // 添加基本认证（如果需要）
    if (config.username?.isNotEmpty == true && config.password?.isNotEmpty == true) {
      final auth =
          'Basic ${base64Encode('${config.username}:${config.password}'.codeUnits)}';
      _dio.options.headers['Authorization'] = auth;
    }

    // 添加拦截器用于错误处理
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final networkError = _convertDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: networkError,
        ));
      },
    ));
  }

  /// 构建基础URL
  String _buildBaseUrl() {
    final scheme = config.protocol == NetworkProtocol.https ? 'https' : 'http';
    final port =
        config.port != NetworkFileSystemFactory.getDefaultPort(config.protocol)
            ? ':${config.port}'
            : '';
    return '$scheme://${config.host}$port';
  }

  @override
  Future<void> connect() async {
    try {
      // 测试连接
      final response = await _dio.head('/');
      if (response.statusCode != null && response.statusCode! < 400) {
        _isConnected = true;
      } else {
        throw NetworkFileSystemException('HTTP连接失败: ${response.statusCode}');
      }
    } catch (e) {
      _isConnected = false;
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw NetworkConnectionTimeoutException(config.host,
              details: e.toString());
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw NetworkAuthenticationException(details: e.toString());
        }
      }
      throw NetworkFileSystemException('HTTP连接失败', originalError: e);
    }
  }

  @override
  Future<void> disconnect() async {
    _dio.close();
    _isConnected = false;
  }

  @override
  Future<bool> ping() async {
    if (!_isConnected) return false;

    try {
      final response = await _dio.head('/');
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    _ensureConnected();

    try {
      final response = await _dio.get(path);

      // 尝试解析HTML目录列表
      if (response.headers.value('content-type')?.contains('text/html') ==
          true) {
        return _parseHTMLDirectoryListing(response.data, path);
      } else {
        // 如果不是HTML，假设是单个文件
        final fileName = path.split('/').last;
        if (fileName.isNotEmpty) {
          return [
            NetworkFileInfo(
              name: fileName,
              path: path,
              isDirectory: false,
              size: int.tryParse(
                      response.headers.value('content-length') ?? '0') ??
                  0,
            ),
          ];
        }
        return [];
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        throw NetworkFileNotFoundException(path);
      }
      throw NetworkFileSystemException('列出目录失败: $path', originalError: e);
    }
  }

  @override
  Future<bool> exists(String path) async {
    _ensureConnected();

    try {
      final response = await _dio.head(path);
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    _ensureConnected();

    try {
      final response = await _dio.head(path);
      if (response.statusCode != null && response.statusCode! < 400) {
        final fileName = path.split('/').last;
        return NetworkFileInfo(
          name: fileName,
          path: path,
          isDirectory: false,
          size: int.tryParse(response.headers.value('content-length') ?? '0') ??
              0,
          mimeType: response.headers.value('content-type'),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    _ensureConnected();

    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      } else {
        throw NetworkFileSystemException('下载文件失败: 响应数据为空');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        throw NetworkFileNotFoundException(path);
      }
      throw NetworkFileSystemException('下载文件失败: $path', originalError: e);
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
      await _dio.download(
        remotePath,
        localPath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        throw NetworkFileNotFoundException(remotePath);
      }
      throw NetworkFileSystemException('下载文件到本地失败: $remotePath',
          originalError: e);
    }
  }

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    Function(int uploaded, int total)? onProgress,
  }) async {
    throw NetworkFileSystemException('HTTP协议不支持文件上传');
  }

  @override
  Future<void> createDirectory(String path) async {
    throw NetworkFileSystemException('HTTP协议不支持创建目录');
  }

  @override
  Future<void> delete(String path) async {
    throw NetworkFileSystemException('HTTP协议不支持删除文件');
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    throw NetworkFileSystemException('HTTP协议不支持重命名文件');
  }

  /// 确保已连接
  void _ensureConnected() {
    if (!_isConnected) {
      throw NetworkFileSystemException('HTTP客户端未连接');
    }
  }

  /// 转换Dio错误为网络文件系统异常
  NetworkFileSystemException _convertDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkConnectionTimeoutException(config.host,
            details: error.toString());

      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401 ||
            error.response?.statusCode == 403) {
          return NetworkAuthenticationException(details: error.toString());
        } else if (error.response?.statusCode == 404) {
          return NetworkFileNotFoundException('请求的资源未找到');
        } else {
          return NetworkFileSystemException(
              'HTTP请求失败: ${error.response?.statusCode}',
              originalError: error);
        }

      default:
        return NetworkFileSystemException('网络请求失败', originalError: error);
    }
  }

  /// 解析HTML目录列表
  /// 这是一个简单的实现，可能需要根据具体的Web服务器调整
  List<NetworkFileInfo> _parseHTMLDirectoryListing(
      String html, String basePath) {
    final files = <NetworkFileInfo>[];

    // 简单的正则表达式匹配链接
    final linkRegex =
        RegExp(r'<a\s+href="([^"]+)"[^>]*>([^<]+)</a>', caseSensitive: false);
    final matches = linkRegex.allMatches(html);

    for (final match in matches) {
      final href = match.group(1)!;
      final name = match.group(2)!.trim();

      // 跳过父目录链接和特殊链接
      if (href == '../' || href.startsWith('?') || href.startsWith('#')) {
        continue;
      }

      final isDirectory = href.endsWith('/');
      final fileName = isDirectory ? name.replaceAll('/', '') : name;
      final fullPath =
          basePath.endsWith('/') ? '$basePath$href' : '$basePath/$href';

      // 只包含漫画相关文件和目录
      if (isDirectory ||
          NetworkFileSystem.isSupportedMangaFile(fileName) ||
          NetworkFileSystem.isSupportedImageFile(fileName)) {
        files.add(NetworkFileInfo(
          name: fileName,
          path: fullPath,
          isDirectory: isDirectory,
          size: 0, // HTML列表通常不包含文件大小
        ));
      }
    }

    return files;
  }
}

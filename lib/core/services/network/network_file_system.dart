import 'dart:typed_data';

import '../../../data/models/network_config.dart';

/// 网络文件系统统一接口
/// 定义所有网络协议客户端的通用操作
abstract class NetworkFileSystem {
  /// 网络配置
  final NetworkConfig config;

  NetworkFileSystem(this.config);

  /// 连接到远程服务器
  Future<void> connect();

  /// 断开连接
  Future<void> disconnect();

  /// 测试连接是否可用
  Future<bool> ping();

  /// 列出目录内容
  /// [path] 目录路径，默认为根目录
  /// 返回文件和目录列表
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']);

  /// 检查文件或目录是否存在
  Future<bool> exists(String path);

  /// 获取文件信息
  Future<NetworkFileInfo?> getFileInfo(String path);

  /// 下载文件内容
  /// [path] 远程文件路径
  /// 返回文件字节数据
  Future<Uint8List> downloadFile(String path);

  /// 下载文件到本地
  /// [remotePath] 远程文件路径
  /// [localPath] 本地保存路径
  /// [onProgress] 下载进度回调 (已下载字节数, 总字节数)
  Future<void> downloadFileToLocal(
    String remotePath,
    String localPath, {
    Function(int downloaded, int total)? onProgress,
  });

  /// 上传文件
  /// [localPath] 本地文件路径
  /// [remotePath] 远程保存路径
  /// [onProgress] 上传进度回调
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    Function(int uploaded, int total)? onProgress,
  });

  /// 创建目录
  Future<void> createDirectory(String path);

  /// 删除文件或目录
  Future<void> delete(String path);

  /// 重命名文件或目录
  Future<void> rename(String oldPath, String newPath);

  /// 获取支持的文件扩展名
  static const List<String> supportedMangaExtensions = [
    '.cbz',
    '.cbr',
    '.zip',
    //'.rar',
    '.7z',
    '.pdf',
    '.epub',
  ];

  /// 获取支持的图片扩展名
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];

  /// 检查文件是否为支持的漫画格式
  static bool isSupportedMangaFile(String filename) {
    final extension = filename.toLowerCase();
    return supportedMangaExtensions.any((ext) => extension.endsWith(ext));
  }

  /// 检查文件是否为支持的图片格式
  static bool isSupportedImageFile(String filename) {
    final extension = filename.toLowerCase();
    return supportedImageExtensions.any((ext) => extension.endsWith(ext));
  }

  /// 检查目录是否可能包含漫画
  static bool isPotentialMangaDirectory(List<NetworkFileInfo> files) {
    // 如果目录包含漫画文件或图片文件，则认为是潜在的漫画目录
    return files.any((file) =>
        isSupportedMangaFile(file.name) || isSupportedImageFile(file.name));
  }
}

/// 网络文件信息
class NetworkFileInfo {
  /// 文件名
  final String name;

  /// 完整路径
  final String path;

  /// 是否为目录
  final bool isDirectory;

  /// 文件大小（字节）
  final int size;

  /// 最后修改时间
  final DateTime? lastModified;

  /// MIME类型
  final String? mimeType;

  const NetworkFileInfo({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.lastModified,
    this.mimeType,
  });

  /// 是否为漫画文件
  bool get isMangaFile => NetworkFileSystem.isSupportedMangaFile(name);

  /// 是否为图片文件
  bool get isImageFile => NetworkFileSystem.isSupportedImageFile(name);

  @override
  String toString() {
    return 'NetworkFileInfo(name: $name, path: $path, isDirectory: $isDirectory, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkFileInfo &&
        other.name == name &&
        other.path == path &&
        other.isDirectory == isDirectory;
  }

  @override
  int get hashCode {
    return name.hashCode ^ path.hashCode ^ isDirectory.hashCode;
  }
}

/// 网络文件系统异常
class NetworkFileSystemException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  const NetworkFileSystemException(
    this.message, {
    this.details,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('NetworkFileSystemException: $message');
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// 连接超时异常
class NetworkConnectionTimeoutException extends NetworkFileSystemException {
  NetworkConnectionTimeoutException(String host, {String? details})
      : super('连接超时: $host', details: details);
}

/// 认证失败异常
class NetworkAuthenticationException extends NetworkFileSystemException {
  NetworkAuthenticationException({String? details})
      : super('认证失败', details: details);
}

/// 文件未找到异常
class NetworkFileNotFoundException extends NetworkFileSystemException {
  NetworkFileNotFoundException(String path) : super('文件未找到: $path');
}

/// 权限拒绝异常
class NetworkPermissionDeniedException extends NetworkFileSystemException {
  NetworkPermissionDeniedException(String path) : super('权限被拒绝: $path');
}

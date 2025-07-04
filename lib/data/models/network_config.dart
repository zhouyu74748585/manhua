import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

part 'network_config.g.dart';

/// 网络协议类型
enum NetworkProtocol {
  @JsonValue('smb')
  smb,
  @JsonValue('ftp')
  ftp,
  @JsonValue('sftp')
  sftp,
  @JsonValue('webdav')
  webdav,
  @JsonValue('nfs')
  nfs,
}

extension NetworkProtocolExtension on NetworkProtocol {
  String get displayName {
    switch (this) {
      case NetworkProtocol.smb:
        return 'SMB/CIFS';
      case NetworkProtocol.ftp:
        return 'FTP';
      case NetworkProtocol.sftp:
        return 'SFTP';
      case NetworkProtocol.webdav:
        return 'WebDAV';
      case NetworkProtocol.nfs:
        return 'NFS';
    }
  }

  String get description {
    switch (this) {
      case NetworkProtocol.smb:
        return 'Windows 共享文件夹';
      case NetworkProtocol.ftp:
        return 'FTP 文件传输协议';
      case NetworkProtocol.sftp:
        return 'SSH 文件传输协议';
      case NetworkProtocol.webdav:
        return 'WebDAV 网络文件系统';
      case NetworkProtocol.nfs:
        return 'NFS 网络文件系统';
    }
  }

  String get defaultPort {
    switch (this) {
      case NetworkProtocol.smb:
        return '445';
      case NetworkProtocol.ftp:
        return '21';
      case NetworkProtocol.sftp:
        return '22';
      case NetworkProtocol.webdav:
        return '80';
      case NetworkProtocol.nfs:
        return '2049';
    }
  }

  List<String> get requiredFields {
    switch (this) {
      case NetworkProtocol.smb:
        return ['host', 'username', 'password', 'shareName'];
      case NetworkProtocol.ftp:
      case NetworkProtocol.sftp:
        return ['host', 'port', 'username', 'password'];
      case NetworkProtocol.webdav:
        return ['host', 'username', 'password'];
      case NetworkProtocol.nfs:
        return ['host', 'exportPath'];
    }
  }
}

/// 网络配置
@JsonSerializable()
class NetworkConfig {
  final NetworkProtocol protocol;
  final String host;
  final int? port;
  final String? username;
  final String? password;
  final String? shareName; // SMB 共享名
  final String? exportPath; // NFS 导出路径
  final String? remotePath; // 远程路径
  final bool useSSL; // WebDAV 是否使用 HTTPS
  final Map<String, dynamic> additionalSettings;

  const NetworkConfig({
    required this.protocol,
    required this.host,
    this.port,
    this.username,
    this.password,
    this.shareName,
    this.exportPath,
    this.remotePath,
    this.useSSL = false,
    this.additionalSettings = const {},
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) =>
      _$NetworkConfigFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkConfigToJson(this);

  // 从连接字符串解析配置
  factory NetworkConfig.fromConnectionString(String connectionString) {
    try {
      final uri = Uri.parse(connectionString);
      NetworkProtocol protocol;

      switch (uri.scheme.toLowerCase()) {
        case 'smb':
          protocol = NetworkProtocol.smb;
          break;
        case 'ftp':
          protocol = NetworkProtocol.ftp;
          break;
        case 'sftp':
          protocol = NetworkProtocol.sftp;
          break;
        case 'http':
        case 'https':
          protocol = NetworkProtocol.webdav;
          break;
        case 'nfs':
          protocol = NetworkProtocol.nfs;
          break;
        default:
          protocol = NetworkProtocol.smb;
      }

      String? shareName;
      String? exportPath;
      String? remotePath = uri.path;

      if (protocol == NetworkProtocol.smb && uri.pathSegments.isNotEmpty) {
        shareName = uri.pathSegments.first;
        if (uri.pathSegments.length > 1) {
          remotePath = uri.pathSegments.skip(1).join('/');
        } else {
          remotePath = null;
        }
      } else if (protocol == NetworkProtocol.nfs) {
        // NFS 路径格式: nfs://host:port/export/path/remote/path
        final pathParts = uri.path.split('/');
        if (pathParts.length >= 3) {
          exportPath = '/${pathParts[1]}/${pathParts[2]}';
          if (pathParts.length > 3) {
            remotePath = pathParts.skip(3).join('/');
          } else {
            remotePath = null;
          }
        }
      }

      return NetworkConfig(
        protocol: protocol,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        username:
            uri.userInfo.isNotEmpty ? uri.userInfo.split(':').first : null,
        password: uri.userInfo.contains(':')
            ? uri.userInfo.split(':').skip(1).join(':')
            : null,
        shareName: shareName,
        exportPath: exportPath,
        remotePath: remotePath?.isEmpty == true ? null : remotePath,
        useSSL: uri.scheme.toLowerCase() == 'https',
      );
    } catch (e, stackTrace) {
      // 解析失败时返回默认配置
      log('网络解析异常: $e, $stackTrace');
      return NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '',
      );
    }
  }

  NetworkConfig copyWith({
    NetworkProtocol? protocol,
    String? host,
    int? port,
    String? username,
    String? password,
    String? shareName,
    String? exportPath,
    String? remotePath,
    bool? useSSL,
    Map<String, dynamic>? additionalSettings,
  }) {
    return NetworkConfig(
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      shareName: shareName ?? this.shareName,
      exportPath: exportPath ?? this.exportPath,
      remotePath: remotePath ?? this.remotePath,
      useSSL: useSSL ?? this.useSSL,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// 获取完整的连接URL
  String get connectionUrl {
    final portStr = port != null ? ':$port' : '';
    final pathStr = remotePath ?? '';

    switch (protocol) {
      case NetworkProtocol.smb:
        return 'smb://$host$portStr/$shareName$pathStr';
      case NetworkProtocol.ftp:
        return 'ftp://$host$portStr$pathStr';
      case NetworkProtocol.sftp:
        return 'sftp://$host$portStr$pathStr';
      case NetworkProtocol.webdav:
        final scheme = useSSL ? 'https' : 'http';
        return '$scheme://$host$portStr$pathStr';
      case NetworkProtocol.nfs:
        return 'nfs://$host$portStr$exportPath$pathStr';
    }
  }

  /// 验证配置是否完整
  bool get isValid {
    if (host.isEmpty) return false;

    final required = protocol.requiredFields;

    if (required.contains('username') && (username?.isEmpty ?? true))
      return false;
    if (required.contains('password') && (password?.isEmpty ?? true))
      return false;
    if (required.contains('shareName') && (shareName?.isEmpty ?? true))
      return false;
    if (required.contains('exportPath') && (exportPath?.isEmpty ?? true))
      return false;
    if (required.contains('port') && port == null) return false;

    return true;
  }
}

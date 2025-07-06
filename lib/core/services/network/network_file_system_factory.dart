import '../../../data/models/network_config.dart';
import 'ftp_file_system.dart';
import 'http_file_system.dart';
import 'network_file_system.dart';
import 'nfs_file_system.dart';
import 'sftp_file_system.dart';
import 'smb_file_system.dart';
import 'webdav_file_system.dart';

/// 网络文件系统工厂类
/// 根据协议类型创建相应的文件系统实现
class NetworkFileSystemFactory {
  /// 创建网络文件系统实例
  /// [config] 网络配置
  /// 返回对应协议的文件系统实现
  static NetworkFileSystem create(NetworkConfig config) {
    switch (config.protocol) {
      case NetworkProtocol.http:
      case NetworkProtocol.https:
        return HTTPFileSystem(config);

      case NetworkProtocol.ftp:
        return FTPFileSystem(config);

      case NetworkProtocol.webdav:
        return WebDAVFileSystem(config);

      case NetworkProtocol.smb:
        return SMBFileSystem(config);

      case NetworkProtocol.sftp:
        return SFTPFileSystem(config);

      case NetworkProtocol.nfs:
        return NFSFileSystem(config);

      default:
        throw NetworkFileSystemException('不支持的网络协议: ${config.protocol}');
    }
  }

  /// 获取支持的协议列表
  static List<NetworkProtocol> getSupportedProtocols() {
    return [
      NetworkProtocol.http,
      NetworkProtocol.https,
      NetworkProtocol.ftp,
      NetworkProtocol.webdav,
      NetworkProtocol.smb,
      NetworkProtocol.sftp,
      // 以下协议暂时不完全支持
      // NetworkProtocol.nfs,
    ];
  }

  /// 检查协议是否受支持
  static bool isProtocolSupported(NetworkProtocol protocol) {
    return getSupportedProtocols().contains(protocol);
  }

  /// 获取协议的显示名称
  static String getProtocolDisplayName(NetworkProtocol protocol) {
    switch (protocol) {
      case NetworkProtocol.http:
        return 'HTTP';
      case NetworkProtocol.https:
        return 'HTTPS';
      case NetworkProtocol.ftp:
        return 'FTP';
      case NetworkProtocol.sftp:
        return 'SFTP';
      case NetworkProtocol.webdav:
        return 'WebDAV';
      case NetworkProtocol.smb:
        return 'SMB/CIFS';
      case NetworkProtocol.nfs:
        return 'NFS';
      default:
        return protocol.toString().toUpperCase();
    }
  }

  /// 获取协议的默认端口
  static int getDefaultPort(NetworkProtocol protocol) {
    switch (protocol) {
      case NetworkProtocol.http:
        return 80;
      case NetworkProtocol.https:
        return 443;
      case NetworkProtocol.ftp:
        return 21;
      case NetworkProtocol.sftp:
        return 22;
      case NetworkProtocol.webdav:
        return 80; // 或443（HTTPS）
      case NetworkProtocol.smb:
        return 445;
      case NetworkProtocol.nfs:
        return 2049;
      default:
        return 80;
    }
  }

  /// 检查协议是否需要认证
  static bool requiresAuthentication(NetworkProtocol protocol) {
    switch (protocol) {
      case NetworkProtocol.http:
      case NetworkProtocol.https:
        return false; // HTTP可能需要也可能不需要
      case NetworkProtocol.ftp:
      case NetworkProtocol.sftp:
      case NetworkProtocol.webdav:
      case NetworkProtocol.smb:
      case NetworkProtocol.nfs:
        return true;
      default:
        return true;
    }
  }
}

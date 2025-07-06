// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkConfig _$NetworkConfigFromJson(Map<String, dynamic> json) =>
    NetworkConfig(
      protocol: $enumDecode(_$NetworkProtocolEnumMap, json['protocol']),
      host: json['host'] as String,
      port: (json['port'] as num?)?.toInt(),
      username: json['username'] as String?,
      password: json['password'] as String?,
      shareName: json['shareName'] as String?,
      exportPath: json['exportPath'] as String?,
      remotePath: json['remotePath'] as String?,
      useSSL: json['useSSL'] as bool? ?? false,
      timeout: (json['timeout'] as num?)?.toInt() ?? 30,
      additionalSettings:
          json['additionalSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$NetworkConfigToJson(NetworkConfig instance) =>
    <String, dynamic>{
      'protocol': _$NetworkProtocolEnumMap[instance.protocol]!,
      'host': instance.host,
      'port': instance.port,
      'username': instance.username,
      'password': instance.password,
      'shareName': instance.shareName,
      'exportPath': instance.exportPath,
      'remotePath': instance.remotePath,
      'useSSL': instance.useSSL,
      'timeout': instance.timeout,
      'additionalSettings': instance.additionalSettings,
    };

const _$NetworkProtocolEnumMap = {
  NetworkProtocol.http: 'http',
  NetworkProtocol.https: 'https',
  NetworkProtocol.smb: 'smb',
  NetworkProtocol.ftp: 'ftp',
  NetworkProtocol.sftp: 'sftp',
  NetworkProtocol.webdav: 'webdav',
  NetworkProtocol.nfs: 'nfs',
};

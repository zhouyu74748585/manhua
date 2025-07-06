// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      platform: json['platform'] as String,
      version: json['version'] as String,
      ipAddress: json['ipAddress'] as String,
      port: (json['port'] as num).toInt(),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? true,
      isTrusted: json['isTrusted'] as bool? ?? false,
      capabilities: json['capabilities'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'platform': instance.platform,
      'version': instance.version,
      'ipAddress': instance.ipAddress,
      'port': instance.port,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'isOnline': instance.isOnline,
      'isTrusted': instance.isTrusted,
      'capabilities': instance.capabilities,
    };

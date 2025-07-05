import 'package:json_annotation/json_annotation.dart';

part 'device_info.g.dart';

/// Device information for multi-device sharing
@JsonSerializable()
class DeviceInfo {
  final String id;
  final String name;
  final String platform; // 'android', 'windows', 'ios', 'macos', 'linux'
  final String version; // App version
  final String ipAddress;
  final int port;
  final DateTime lastSeen;
  final bool isOnline;
  final bool isTrusted; // Whether this device is trusted for sync
  final Map<String, dynamic> capabilities; // Device capabilities

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.platform,
    required this.version,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
    this.isOnline = true,
    this.isTrusted = false,
    this.capabilities = const {},
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);

  DeviceInfo copyWith({
    String? id,
    String? name,
    String? platform,
    String? version,
    String? ipAddress,
    int? port,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isTrusted,
    Map<String, dynamic>? capabilities,
  }) {
    return DeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      isTrusted: isTrusted ?? this.isTrusted,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeviceInfo{id: $id, name: $name, platform: $platform, ipAddress: $ipAddress}';
  }
}

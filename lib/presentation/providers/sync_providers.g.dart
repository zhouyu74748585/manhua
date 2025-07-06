// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$multiDeviceSyncServiceHash() =>
    r'd2227c5559ca8cfc1392f14808deba98e7ea4bc2';

/// 多设备同步服务提供者
///
/// Copied from [multiDeviceSyncService].
@ProviderFor(multiDeviceSyncService)
final multiDeviceSyncServiceProvider =
    AutoDisposeProvider<MultiDeviceSyncService>.internal(
  multiDeviceSyncService,
  name: r'multiDeviceSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$multiDeviceSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MultiDeviceSyncServiceRef
    = AutoDisposeProviderRef<MultiDeviceSyncService>;
String _$librarySyncServiceHash() =>
    r'0792c418f95544ee3a48e540c97e71409fc12766';

/// 库同步服务提供者
///
/// Copied from [librarySyncService].
@ProviderFor(librarySyncService)
final librarySyncServiceProvider =
    AutoDisposeProvider<LibrarySyncService>.internal(
  librarySyncService,
  name: r'librarySyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$librarySyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LibrarySyncServiceRef = AutoDisposeProviderRef<LibrarySyncService>;
String _$syncCoordinatorServiceHash() =>
    r'fd452b871b10e9bf72c85e58e6b7c459787c5804';

/// 同步协调服务提供者
///
/// Copied from [syncCoordinatorService].
@ProviderFor(syncCoordinatorService)
final syncCoordinatorServiceProvider =
    AutoDisposeProvider<SyncCoordinatorService>.internal(
  syncCoordinatorService,
  name: r'syncCoordinatorServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncCoordinatorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncCoordinatorServiceRef
    = AutoDisposeProviderRef<SyncCoordinatorService>;
String _$syncCoordinatorHash() => r'c1f0b6e287336f4f117e0b943560a525a49090ed';

/// 同步协调器提供者（别名）
///
/// Copied from [syncCoordinator].
@ProviderFor(syncCoordinator)
final syncCoordinatorProvider =
    AutoDisposeProvider<SyncCoordinatorService>.internal(
  syncCoordinator,
  name: r'syncCoordinatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncCoordinatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncCoordinatorRef = AutoDisposeProviderRef<SyncCoordinatorService>;
String _$deviceDiscoveryServiceHash() =>
    r'4cd3ba1ff6320b2cb8d6f67c2510bc1ae446f7c6';

/// 设备发现服务提供者
///
/// Copied from [deviceDiscoveryService].
@ProviderFor(deviceDiscoveryService)
final deviceDiscoveryServiceProvider =
    AutoDisposeProvider<DeviceDiscoveryService>.internal(
  deviceDiscoveryService,
  name: r'deviceDiscoveryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceDiscoveryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceDiscoveryServiceRef
    = AutoDisposeProviderRef<DeviceDiscoveryService>;
String _$currentDeviceHash() => r'b07e5ed60828c125c7c71fddff75d80e9d49592e';

/// 当前设备信息提供者
///
/// Copied from [currentDevice].
@ProviderFor(currentDevice)
final currentDeviceProvider = AutoDisposeFutureProvider<DeviceInfo?>.internal(
  currentDevice,
  name: r'currentDeviceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentDeviceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentDeviceRef = AutoDisposeFutureProviderRef<DeviceInfo?>;
String _$availableDevicesHash() => r'f849ed1f0d558ec15963935f8ce7f0ea2f90a4bc';

/// 可用设备列表提供者
///
/// Copied from [availableDevices].
@ProviderFor(availableDevices)
final availableDevicesProvider =
    AutoDisposeStreamProvider<List<DeviceInfo>>.internal(
  availableDevices,
  name: r'availableDevicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableDevicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableDevicesRef = AutoDisposeStreamProviderRef<List<DeviceInfo>>;
String _$activeSyncSessionsHash() =>
    r'e969fdc4e1cefb028b10abb1895c653da79f06a8';

/// 活跃同步会话提供者
///
/// Copied from [activeSyncSessions].
@ProviderFor(activeSyncSessions)
final activeSyncSessionsProvider =
    AutoDisposeStreamProvider<List<SyncSession>>.internal(
  activeSyncSessions,
  name: r'activeSyncSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSyncSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSyncSessionsRef = AutoDisposeStreamProviderRef<List<SyncSession>>;
String _$syncProgressProviderHash() =>
    r'b0769d56d280f10d542164b3bade2fe31bd6d1a8';

/// 同步进度提供者
///
/// Copied from [SyncProgressProvider].
@ProviderFor(SyncProgressProvider)
final syncProgressProviderProvider = AutoDisposeNotifierProvider<
    SyncProgressProvider, Map<String, double>>.internal(
  SyncProgressProvider.new,
  name: r'syncProgressProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncProgressProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncProgressProvider = AutoDisposeNotifier<Map<String, double>>;
String _$syncStatusHash() => r'a70079a3d53ca9e749e8723921573b27b31d3240';

/// 同步状态提供者
///
/// Copied from [SyncStatus].
@ProviderFor(SyncStatus)
final syncStatusProvider =
    AutoDisposeNotifierProvider<SyncStatus, Map<String, String>>.internal(
  SyncStatus.new,
  name: r'syncStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncStatus = AutoDisposeNotifier<Map<String, String>>;
String _$deviceConnectionStatusHash() =>
    r'22a0420fbd97663bfbb1abb7799f3846f23a31fd';

/// 设备连接状态提供者
///
/// Copied from [DeviceConnectionStatus].
@ProviderFor(DeviceConnectionStatus)
final deviceConnectionStatusProvider = AutoDisposeNotifierProvider<
    DeviceConnectionStatus, Map<String, bool>>.internal(
  DeviceConnectionStatus.new,
  name: r'deviceConnectionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceConnectionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceConnectionStatus = AutoDisposeNotifier<Map<String, bool>>;
String _$syncErrorsHash() => r'42c576fd29ecb1bf5610f131fff682b0e7ecb508';

/// 同步错误提供者
///
/// Copied from [SyncErrors].
@ProviderFor(SyncErrors)
final syncErrorsProvider =
    AutoDisposeNotifierProvider<SyncErrors, List<String>>.internal(
  SyncErrors.new,
  name: r'syncErrorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncErrors = AutoDisposeNotifier<List<String>>;
String _$syncSettingsHash() => r'6a5236534d02240f9fc23d18a1f95c6abe27e538';

/// 同步设置提供者
///
/// Copied from [SyncSettings].
@ProviderFor(SyncSettings)
final syncSettingsProvider =
    AutoDisposeNotifierProvider<SyncSettings, SyncSettingsData>.internal(
  SyncSettings.new,
  name: r'syncSettingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncSettings = AutoDisposeNotifier<SyncSettingsData>;
String _$syncStatisticsHash() => r'e0537c53c9b886efad874e579c24cd3fd3fca206';

/// 同步统计信息提供者
///
/// Copied from [SyncStatistics].
@ProviderFor(SyncStatistics)
final syncStatisticsProvider =
    AutoDisposeNotifierProvider<SyncStatistics, SyncStatisticsData>.internal(
  SyncStatistics.new,
  name: r'syncStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncStatistics = AutoDisposeNotifier<SyncStatisticsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

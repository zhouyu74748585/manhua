import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/network/device_discovery_service.dart';
import '../../data/models/sync/device_info.dart';
import '../../data/models/sync/sync_session.dart';
import '../../data/services/sync/library_sync_service.dart';
import '../../data/services/sync/multi_device_sync_service.dart';
import '../../data/services/sync/sync_coordinator_service.dart';

part 'sync_providers.g.dart';

/// 多设备同步服务提供者
@riverpod
MultiDeviceSyncService multiDeviceSyncService(MultiDeviceSyncServiceRef ref) {
  return MultiDeviceSyncService();
}

/// 库同步服务提供者
@riverpod
LibrarySyncService librarySyncService(LibrarySyncServiceRef ref) {
  return LibrarySyncService();
}

/// 同步协调服务提供者
@riverpod
SyncCoordinatorService syncCoordinatorService(SyncCoordinatorServiceRef ref) {
  return SyncCoordinatorService(
    multiDeviceSyncService: ref.watch(multiDeviceSyncServiceProvider),
    librarySyncService: ref.watch(librarySyncServiceProvider),
  );
}

/// 同步协调器提供者（别名）
@riverpod
SyncCoordinatorService syncCoordinator(SyncCoordinatorRef ref) {
  return ref.watch(syncCoordinatorServiceProvider);
}

/// 设备发现服务提供者
@riverpod
DeviceDiscoveryService deviceDiscoveryService(DeviceDiscoveryServiceRef ref) {
  return DeviceDiscoveryService();
}

/// 当前设备信息提供者
@riverpod
Future<DeviceInfo?> currentDevice(CurrentDeviceRef ref) async {
  final service = ref.watch(multiDeviceSyncServiceProvider);
  return service.currentDevice;
}

/// 可用设备列表提供者
@riverpod
Stream<List<DeviceInfo>> availableDevices(AvailableDevicesRef ref) {
  final service = ref.watch(multiDeviceSyncServiceProvider);
  return service.devicesStream;
}

/// 活跃同步会话提供者
@riverpod
Stream<List<SyncSession>> activeSyncSessions(ActiveSyncSessionsRef ref) {
  final service = ref.watch(multiDeviceSyncServiceProvider);
  return service.activeSyncSessionsStream;
}

/// 同步进度提供者
@riverpod
class SyncProgressProvider extends _$SyncProgressProvider {
  @override
  Map<String, double> build() {
    return {};
  }

  void updateProgress(String sessionId, double progress) {
    state = {...state, sessionId: progress};
  }

  void removeProgress(String sessionId) {
    final newState = Map<String, double>.from(state);
    newState.remove(sessionId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

/// 同步状态提供者
@riverpod
class SyncStatus extends _$SyncStatus {
  @override
  Map<String, String> build() {
    return {};
  }

  void updateStatus(String sessionId, String status) {
    state = {...state, sessionId: status};
  }

  void removeStatus(String sessionId) {
    final newState = Map<String, String>.from(state);
    newState.remove(sessionId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

/// 设备连接状态提供者
@riverpod
class DeviceConnectionStatus extends _$DeviceConnectionStatus {
  @override
  Map<String, bool> build() {
    return {};
  }

  void updateConnectionStatus(String deviceId, bool isConnected) {
    state = {...state, deviceId: isConnected};
  }

  void removeDevice(String deviceId) {
    final newState = Map<String, bool>.from(state);
    newState.remove(deviceId);
    state = newState;
  }

  bool isDeviceConnected(String deviceId) {
    return state[deviceId] ?? false;
  }
}

/// 同步错误提供者
@riverpod
class SyncErrors extends _$SyncErrors {
  @override
  List<String> build() {
    return [];
  }

  void addError(String error) {
    state = [...state, error];
  }

  void removeError(int index) {
    if (index >= 0 && index < state.length) {
      final newState = List<String>.from(state);
      newState.removeAt(index);
      state = newState;
    }
  }

  void clearErrors() {
    state = [];
  }
}

/// 同步设置提供者
@riverpod
class SyncSettings extends _$SyncSettings {
  @override
  SyncSettingsData build() {
    return const SyncSettingsData();
  }

  void updateAutoSync(bool enabled) {
    state = state.copyWith(autoSyncEnabled: enabled);
  }

  void updateSyncInterval(Duration interval) {
    state = state.copyWith(syncInterval: interval);
  }

  void updateConflictResolution(ConflictResolutionStrategy strategy) {
    state = state.copyWith(conflictResolution: strategy);
  }

  void updateSyncOnWifiOnly(bool wifiOnly) {
    state = state.copyWith(syncOnWifiOnly: wifiOnly);
  }

  void updateWifiOnly(bool wifiOnly) {
    state = state.copyWith(wifiOnly: wifiOnly);
  }

  void updateVerboseLogging(bool enabled) {
    state = state.copyWith(verboseLogging: enabled);
  }

  void updateConnectionPoolEnabled(bool enabled) {
    state = state.copyWith(enableConnectionPool: enabled);
  }

  void updateBatchSize(int size) {
    state = state.copyWith(batchSize: size);
  }

  void updateConnectionTimeout(int timeout) {
    state = state.copyWith(connectionTimeout: timeout);
  }

  void updateTransferTimeout(int timeout) {
    state = state.copyWith(transferTimeout: timeout);
  }

  void updateMaxConcurrentConnections(int connections) {
    state = state.copyWith(maxConcurrentConnections: connections);
  }

  void updateRetryAttempts(int attempts) {
    state = state.copyWith(retryAttempts: attempts);
  }

  void updateAutoDiscovery(bool enabled) {
    state = state.copyWith(autoDiscovery: enabled);
  }

  void updateSyncThumbnails(bool enabled) {
    state = state.copyWith(syncThumbnails: enabled);
  }

  void updateSyncCovers(bool enabled) {
    state = state.copyWith(syncCovers: enabled);
  }

  void updateSyncOriginalFiles(bool enabled) {
    state = state.copyWith(syncOriginalFiles: enabled);
  }

  void updateAutoResolveConflicts(bool enabled) {
    state = state.copyWith(autoResolveConflicts: enabled);
  }

  void updateRequireConfirmation(bool enabled) {
    state = state.copyWith(requireConfirmation: enabled);
  }

  void updateEnableEncryption(bool enabled) {
    state = state.copyWith(enableEncryption: enabled);
  }
}

/// 同步设置数据类
class SyncSettingsData {
  final bool autoSyncEnabled;
  final Duration syncInterval;
  final ConflictResolutionStrategy conflictResolution;
  final bool syncOnWifiOnly;
  final bool syncThumbnails;
  final bool syncReadingProgress;
  // 网络设置
  final int connectionTimeout;
  final int transferTimeout;
  final bool wifiOnly;
  // 高级设置
  final int maxConcurrentConnections;
  final int retryAttempts;
  final bool verboseLogging;
  // 性能优化设置
  final int? batchSize;
  final bool? enableConnectionPool;
  // 设备发现设置
  final bool autoDiscovery;
  final int discoveryTimeout;
  final String deviceName;
  // 同步选项设置
  final bool syncCovers;
  final bool syncOriginalFiles;
  // 冲突解决设置
  final bool autoResolveConflicts;
  // 安全设置
  final bool requireConfirmation;
  final bool enableEncryption;
  final List<String> trustedDevices;

  const SyncSettingsData({
    this.autoSyncEnabled = false,
    this.syncInterval = const Duration(minutes: 30),
    this.conflictResolution = ConflictResolutionStrategy.latestWins,
    this.syncOnWifiOnly = true,
    this.syncThumbnails = true,
    this.syncReadingProgress = true,
    // 网络设置默认值
    this.connectionTimeout = 30,
    this.transferTimeout = 300,
    this.wifiOnly = true,
    // 高级设置默认值
    this.maxConcurrentConnections = 3,
    this.retryAttempts = 3,
    this.verboseLogging = false,
    // 性能优化设置默认值
    this.batchSize = 50,
    this.enableConnectionPool = true,
    // 设备发现设置默认值
    this.autoDiscovery = true,
    this.discoveryTimeout = 30,
    this.deviceName = '我的设备',
    // 同步选项设置默认值
    this.syncCovers = true,
    this.syncOriginalFiles = false,
    // 冲突解决设置默认值
    this.autoResolveConflicts = true,
    // 安全设置默认值
    this.requireConfirmation = false,
    this.enableEncryption = false,
    this.trustedDevices = const [],
  });

  SyncSettingsData copyWith({
    bool? autoSyncEnabled,
    Duration? syncInterval,
    ConflictResolutionStrategy? conflictResolution,
    bool? syncOnWifiOnly,
    bool? syncThumbnails,
    bool? syncReadingProgress,
    int? connectionTimeout,
    int? transferTimeout,
    bool? wifiOnly,
    int? maxConcurrentConnections,
    int? retryAttempts,
    bool? verboseLogging,
    int? batchSize,
    bool? enableConnectionPool,
    bool? autoDiscovery,
    int? discoveryTimeout,
    String? deviceName,
    bool? syncCovers,
    bool? syncOriginalFiles,
    bool? autoResolveConflicts,
    bool? requireConfirmation,
    bool? enableEncryption,
    List<String>? trustedDevices,
  }) {
    return SyncSettingsData(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncInterval: syncInterval ?? this.syncInterval,
      conflictResolution: conflictResolution ?? this.conflictResolution,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      syncThumbnails: syncThumbnails ?? this.syncThumbnails,
      syncReadingProgress: syncReadingProgress ?? this.syncReadingProgress,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      transferTimeout: transferTimeout ?? this.transferTimeout,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      maxConcurrentConnections:
          maxConcurrentConnections ?? this.maxConcurrentConnections,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      verboseLogging: verboseLogging ?? this.verboseLogging,
      batchSize: batchSize ?? this.batchSize,
      enableConnectionPool: enableConnectionPool ?? this.enableConnectionPool,
      autoDiscovery: autoDiscovery ?? this.autoDiscovery,
      discoveryTimeout: discoveryTimeout ?? this.discoveryTimeout,
      deviceName: deviceName ?? this.deviceName,
      syncCovers: syncCovers ?? this.syncCovers,
      syncOriginalFiles: syncOriginalFiles ?? this.syncOriginalFiles,
      autoResolveConflicts: autoResolveConflicts ?? this.autoResolveConflicts,
      requireConfirmation: requireConfirmation ?? this.requireConfirmation,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      trustedDevices: trustedDevices ?? this.trustedDevices,
    );
  }
}

/// 冲突解决策略枚举
enum ConflictResolutionStrategy {
  latestWins,
  localWins,
  remoteWins,
  manual,
  manualResolve,
  sourceWins,
  targetWins,
}

extension ConflictResolutionStrategyExtension on ConflictResolutionStrategy {
  String get displayName {
    switch (this) {
      case ConflictResolutionStrategy.latestWins:
        return '最新优先';
      case ConflictResolutionStrategy.localWins:
        return '本地优先';
      case ConflictResolutionStrategy.remoteWins:
        return '远程优先';
      case ConflictResolutionStrategy.manual:
        return '手动解决';
      case ConflictResolutionStrategy.manualResolve:
        return '手动解决';
      case ConflictResolutionStrategy.sourceWins:
        return '源设备优先';
      case ConflictResolutionStrategy.targetWins:
        return '目标设备优先';
    }
  }

  String get description {
    switch (this) {
      case ConflictResolutionStrategy.latestWins:
        return '自动选择最新的数据';
      case ConflictResolutionStrategy.localWins:
        return '始终保留本地数据';
      case ConflictResolutionStrategy.remoteWins:
        return '始终保留远程数据';
      case ConflictResolutionStrategy.manual:
        return '需要手动选择保留哪个版本';
      case ConflictResolutionStrategy.manualResolve:
        return '需要手动选择保留哪个版本';
      case ConflictResolutionStrategy.sourceWins:
        return '始终保留发送设备的数据';
      case ConflictResolutionStrategy.targetWins:
        return '始终保留接收设备的数据';
    }
  }
}

/// 同步统计信息提供者
@riverpod
class SyncStatistics extends _$SyncStatistics {
  @override
  SyncStatisticsData build() {
    return const SyncStatisticsData();
  }

  void updateStatistics({
    int? totalSyncSessions,
    int? successfulSyncs,
    int? failedSyncs,
    int? totalDataSynced,
    DateTime? lastSyncTime,
  }) {
    state = state.copyWith(
      totalSyncSessions: totalSyncSessions,
      successfulSyncs: successfulSyncs,
      failedSyncs: failedSyncs,
      totalDataSynced: totalDataSynced,
      lastSyncTime: lastSyncTime,
    );
  }

  void incrementSyncSession() {
    state = state.copyWith(totalSyncSessions: state.totalSyncSessions + 1);
  }

  void incrementSuccessfulSync() {
    state = state.copyWith(successfulSyncs: state.successfulSyncs + 1);
  }

  void incrementFailedSync() {
    state = state.copyWith(failedSyncs: state.failedSyncs + 1);
  }
}

/// 同步统计数据类
class SyncStatisticsData {
  final int totalSyncSessions;
  final int successfulSyncs;
  final int failedSyncs;
  final int totalDataSynced; // 以字节为单位
  final DateTime? lastSyncTime;

  const SyncStatisticsData({
    this.totalSyncSessions = 0,
    this.successfulSyncs = 0,
    this.failedSyncs = 0,
    this.totalDataSynced = 0,
    this.lastSyncTime,
  });

  SyncStatisticsData copyWith({
    int? totalSyncSessions,
    int? successfulSyncs,
    int? failedSyncs,
    int? totalDataSynced,
    DateTime? lastSyncTime,
  }) {
    return SyncStatisticsData(
      totalSyncSessions: totalSyncSessions ?? this.totalSyncSessions,
      successfulSyncs: successfulSyncs ?? this.successfulSyncs,
      failedSyncs: failedSyncs ?? this.failedSyncs,
      totalDataSynced: totalDataSynced ?? this.totalDataSynced,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  double get successRate {
    if (totalSyncSessions == 0) return 0.0;
    return successfulSyncs / totalSyncSessions;
  }

  String get formattedDataSize {
    if (totalDataSynced < 1024) {
      return '${totalDataSynced}B';
    } else if (totalDataSynced < 1024 * 1024) {
      return '${(totalDataSynced / 1024).toStringAsFixed(1)}KB';
    } else if (totalDataSynced < 1024 * 1024 * 1024) {
      return '${(totalDataSynced / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(totalDataSynced / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
}

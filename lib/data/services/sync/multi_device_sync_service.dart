import 'dart:async';
import 'dart:developer';

import '../../../core/services/network/device_discovery_service.dart';
import '../../../core/services/network/sync_communication_service.dart';
import '../../models/sync/device_info.dart';
import '../../models/sync/sync_conflict.dart';
import '../../models/sync/sync_session.dart';
import 'sync_coordinator_service.dart';

/// Main service for coordinating multi-device synchronization
class MultiDeviceSyncService {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  final SyncCommunicationService _communicationService =
      SyncCommunicationService();

  final StreamController<List<DeviceInfo>> _devicesController =
      StreamController<List<DeviceInfo>>.broadcast();
  final StreamController<SyncSession> _syncSessionController =
      StreamController<SyncSession>.broadcast();
  final StreamController<List<SyncConflict>> _conflictsController =
      StreamController<List<SyncConflict>>.broadcast();

  final Map<String, SyncSession> _activeSessions = {};
  final List<SyncConflict> _pendingConflicts = [];

  // 资源管理
  final List<StreamSubscription> _subscriptions = [];
  Timer? _sessionCleanupTimer;
  Timer? _resourceMonitorTimer;

  // 配置参数
  static const Duration _sessionTimeout = Duration(hours: 2);
  static const Duration _cleanupInterval = Duration(minutes: 10);
  static const int _maxActiveSessions = 50;

  bool _isInitialized = false;
  bool _isDiscovering = false;
  bool _isAdvertising = false;
  bool _isDisposed = false;

  /// Stream of discovered devices
  Stream<List<DeviceInfo>> get devicesStream => _devicesController.stream;

  /// Stream of sync session updates
  Stream<SyncSession> get syncSessionStream => _syncSessionController.stream;

  /// Stream of sync conflicts
  Stream<List<SyncConflict>> get conflictsStream => _conflictsController.stream;

  /// List of currently discovered devices
  List<DeviceInfo> get discoveredDevices => _discoveryService.discoveredDevices;

  /// Current device information
  DeviceInfo? get currentDevice => _discoveryService.currentDevice;

  /// Active sync sessions
  List<SyncSession> get activeSessions => _activeSessions.values.toList();

  /// Pending conflicts
  List<SyncConflict> get pendingConflicts => _pendingConflicts;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether device discovery is active
  bool get isDiscovering => _isDiscovering;

  /// Whether device advertising is active
  bool get isAdvertising => _isAdvertising;

  /// Initialize the multi-device sync service
  Future<void> initialize({int? port}) async {
    if (_isInitialized) {
      log('Multi-device sync service already initialized');
      return;
    }

    try {
      // Initialize discovery service
      await _discoveryService.initialize();

      // Initialize communication service
      await _communicationService.initialize(port: port);

      // Set up communication service callbacks
      _communicationService.onDeviceConnected = _handleDeviceConnected;
      _communicationService.onLibrarySyncRequested =
          _handleLibrarySyncRequested;
      _communicationService.onProgressSyncRequested =
          _handleProgressSyncRequested;
      _communicationService.onSyncSessionUpdate = _handleSyncSessionUpdate;

      // Listen to device discovery updates
      final deviceSubscription =
          _discoveryService.devicesStream.listen((devices) {
        if (!_isDisposed) {
          _devicesController.add(devices);
        }
      });
      _subscriptions.add(deviceSubscription);

      // 启动资源清理定时器
      _startResourceManagement();

      _isInitialized = true;
      log('Multi-device sync service initialized successfully');
    } catch (e, stackTrace) {
      log('Failed to initialize multi-device sync service: $e',
          stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Start device discovery and advertising
  Future<void> startSharing({int? port}) async {
    if (!_isInitialized) {
      await initialize(port: port);
    }

    try {
      // Start HTTP server for incoming requests
      await _communicationService.startServer();

      // Start advertising this device
      await _discoveryService.startAdvertising(port: port);
      _isAdvertising = true;

      // Start discovering other devices
      await _discoveryService.startDiscovery();
      _isDiscovering = true;

      log('Multi-device sharing started');
    } catch (e, stackTrace) {
      log('Failed to start multi-device sharing: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stop device discovery and advertising
  Future<void> stopSharing() async {
    try {
      await _discoveryService.stopDiscovery();
      await _discoveryService.stopAdvertising();
      await _communicationService.stopServer();

      _isDiscovering = false;
      _isAdvertising = false;

      log('Multi-device sharing stopped');
    } catch (e, stackTrace) {
      log('Failed to stop multi-device sharing: $e', stackTrace: stackTrace);
    }
  }

  /// Test connectivity to a device
  Future<bool> testDeviceConnectivity(DeviceInfo device) async {
    try {
      return await _communicationService.pingDevice(device);
    } catch (e) {
      log('Failed to test connectivity to ${device.name}: $e');
      return false;
    }
  }

  /// Start library synchronization with a device
  Future<SyncSession> startLibrarySync({
    required DeviceInfo targetDevice,
    required List<String> libraryIds,
    SyncDirection direction = SyncDirection.bidirectional,
  }) async {
    try {
      final sessionId = 'sync_${DateTime.now().millisecondsSinceEpoch}';
      final currentDeviceId = currentDevice?.id ?? 'unknown';

      final session = SyncSession(
        id: sessionId,
        sourceDeviceId: currentDeviceId,
        targetDeviceId: targetDevice.id,
        type: SyncType.libraryFull,
        direction: direction,
        status: SyncStatus.pending,
        libraryIds: libraryIds,
        startTime: DateTime.now(),
      );

      _activeSessions[sessionId] = session;
      _syncSessionController.add(session);

      // Request sync from target device
      final success = await _communicationService.requestLibrarySync(
          targetDevice, libraryIds);

      if (success) {
        final updatedSession = session.copyWith(status: SyncStatus.inProgress);
        _activeSessions[sessionId] = updatedSession;
        _syncSessionController.add(updatedSession);
      } else {
        final failedSession = session.copyWith(
          status: SyncStatus.failed,
          errorMessage: 'Failed to initiate sync with target device',
          endTime: DateTime.now(),
        );
        _activeSessions[sessionId] = failedSession;
        _syncSessionController.add(failedSession);
      }

      return _activeSessions[sessionId]!;
    } catch (e, stackTrace) {
      log('Failed to start library sync: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Start reading progress synchronization with a device
  Future<SyncSession> startProgressSync({
    required DeviceInfo targetDevice,
    required String mangaId,
  }) async {
    try {
      final sessionId =
          'progress_sync_${DateTime.now().millisecondsSinceEpoch}';
      final currentDeviceId = currentDevice?.id ?? 'unknown';

      final session = SyncSession(
        id: sessionId,
        sourceDeviceId: currentDeviceId,
        targetDeviceId: targetDevice.id,
        type: SyncType.readingProgress,
        direction: SyncDirection.bidirectional,
        status: SyncStatus.pending,
        libraryIds: [], // Not applicable for progress sync
        startTime: DateTime.now(),
        metadata: {'manga_id': mangaId},
      );

      _activeSessions[sessionId] = session;
      _syncSessionController.add(session);

      // Request progress sync from target device
      final success = await _communicationService.requestProgressSync(
          targetDevice, mangaId);

      if (success) {
        final updatedSession = session.copyWith(status: SyncStatus.inProgress);
        _activeSessions[sessionId] = updatedSession;
        _syncSessionController.add(updatedSession);
      } else {
        final failedSession = session.copyWith(
          status: SyncStatus.failed,
          errorMessage: 'Failed to initiate progress sync with target device',
          endTime: DateTime.now(),
        );
        _activeSessions[sessionId] = failedSession;
        _syncSessionController.add(failedSession);
      }

      return _activeSessions[sessionId]!;
    } catch (e, stackTrace) {
      log('Failed to start progress sync: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Resolve a sync conflict
  Future<void> resolveConflict(
      String conflictId, ConflictResolution resolution) async {
    try {
      final conflictIndex =
          _pendingConflicts.indexWhere((c) => c.id == conflictId);
      if (conflictIndex == -1) {
        throw Exception('Conflict not found: $conflictId');
      }

      final conflict = _pendingConflicts[conflictIndex];
      SyncConflict resolvedConflict;

      switch (resolution) {
        case ConflictResolution.latestWins:
          resolvedConflict = conflict.resolveWithLatestWins();
          break;
        case ConflictResolution.sourceWins:
          resolvedConflict = conflict.copyWith(
            resolution: ConflictResolution.sourceWins,
            resolvedAt: DateTime.now(),
            resolvedData: conflict.sourceData,
            isResolved: true,
          );
          break;
        case ConflictResolution.targetWins:
          resolvedConflict = conflict.copyWith(
            resolution: ConflictResolution.targetWins,
            resolvedAt: DateTime.now(),
            resolvedData: conflict.targetData,
            isResolved: true,
          );
          break;
        case ConflictResolution.manual:
          // Manual resolution requires additional data
          throw Exception('Manual resolution not implemented yet');

        case ConflictResolution.useSource:
          resolvedConflict = conflict.copyWith(
            resolution: ConflictResolution.useSource,
            resolvedAt: DateTime.now(),
            resolvedData: conflict.sourceData,
            isResolved: true,
          );
          break;

        case ConflictResolution.useTarget:
          resolvedConflict = conflict.copyWith(
            resolution: ConflictResolution.useTarget,
            resolvedAt: DateTime.now(),
            resolvedData: conflict.targetData,
            isResolved: true,
          );
          break;

        case ConflictResolution.useLatest:
          resolvedConflict = conflict.resolveWithLatestWins();
          break;

        case ConflictResolution.merge:
          // Merge resolution requires custom logic
          throw Exception('Merge resolution not implemented yet');
      }

      _pendingConflicts[conflictIndex] = resolvedConflict;
      _conflictsController.add(_pendingConflicts);

      log('Resolved conflict: $conflictId with strategy: $resolution');
    } catch (e, stackTrace) {
      log('Failed to resolve conflict: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get sync session by ID
  SyncSession? getSyncSession(String sessionId) {
    return _activeSessions[sessionId];
  }

  /// Cancel a sync session
  Future<void> cancelSyncSession(String sessionId) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) {
        throw Exception('Sync session not found: $sessionId');
      }

      if (session.isActive) {
        final cancelledSession = session.copyWith(
          status: SyncStatus.cancelled,
          endTime: DateTime.now(),
        );
        _activeSessions[sessionId] = cancelledSession;
        _syncSessionController.add(cancelledSession);
      }

      log('Cancelled sync session: $sessionId');
    } catch (e, stackTrace) {
      log('Failed to cancel sync session: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  // ==================== Event Handlers ====================

  void _handleDeviceConnected(DeviceInfo device) {
    log('Device connected: ${device.name}');
    // Handle device connection logic here
  }

  void _handleLibrarySyncRequested(
      String sourceDeviceId, List<String> libraryIds) {
    log('Library sync requested from $sourceDeviceId for libraries: $libraryIds');
    // Handle incoming library sync request
  }

  void _handleProgressSyncRequested(String sourceDeviceId, String mangaId) {
    log('Progress sync requested from $sourceDeviceId for manga: $mangaId');
    // Handle incoming progress sync request
  }

  void _handleSyncSessionUpdate(SyncSession session) {
    _activeSessions[session.id] = session;
    _syncSessionController.add(session);
    log('Sync session updated: ${session.id} - ${session.status}');
  }

  // ==================== 缺失的方法实现 ====================

  /// 可用设备流
  Stream<List<DeviceInfo>> get availableDevicesStream => devicesStream;

  /// 活跃同步会话流
  Stream<List<SyncSession>> get activeSyncSessionsStream =>
      _syncSessionController.stream
          .map((session) => _activeSessions.values.toList());

  /// 事件流 (用于与 SyncCoordinatorService 集成)
  Stream<MultiDeviceSyncEvent> get eventStream =>
      Stream.empty(); // TODO: 实现具体的事件流

  /// 开始设备发现
  Future<void> startDeviceDiscovery() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _discoveryService.startDiscovery();
    _isDiscovering = true;
    log('设备发现已开始');
  }

  /// 停止设备发现
  Future<void> stopDeviceDiscovery() async {
    await _discoveryService.stopDiscovery();
    _isDiscovering = false;
    log('设备发现已停止');
  }

  /// 更新同步会话
  Future<void> updateSyncSession(SyncSession session) async {
    _activeSessions[session.id] = session;
    _syncSessionController.add(session);
    log('同步会话已更新: ${session.id}');
  }

  /// 获取可用设备列表
  List<DeviceInfo> getAvailableDevices() {
    return discoveredDevices;
  }

  /// 获取活跃同步会话列表
  List<SyncSession> getActiveSyncSessions() {
    return _activeSessions.values.toList();
  }

  // ==================== 资源管理方法 ====================

  /// 启动资源管理
  void _startResourceManagement() {
    // 启动会话清理定时器
    _sessionCleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpiredSessions();
    });

    // 启动资源监控定时器
    _resourceMonitorTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _monitorResources(),
    );
  }

  /// 清理过期会话
  void _cleanupExpiredSessions() {
    if (_isDisposed) return;

    final now = DateTime.now();
    final expiredSessions = <String>[];

    for (final entry in _activeSessions.entries) {
      final session = entry.value;
      final sessionAge = now.difference(session.startTime);

      // 清理超时会话
      if (sessionAge > _sessionTimeout) {
        expiredSessions.add(entry.key);
        log('清理超时会话: ${session.id}');
      }

      // 清理已完成的会话（保留1小时）
      if (session.status == SyncStatus.completed ||
          session.status == SyncStatus.failed) {
        final completionTime = session.endTime ?? session.startTime;
        final timeSinceCompletion = now.difference(completionTime);
        if (timeSinceCompletion > const Duration(hours: 1)) {
          expiredSessions.add(entry.key);
          log('清理已完成会话: ${session.id}');
        }
      }
    }

    // 移除过期会话
    for (final sessionId in expiredSessions) {
      _activeSessions.remove(sessionId);
    }

    // 如果活跃会话过多，清理最旧的会话
    if (_activeSessions.length > _maxActiveSessions) {
      final sortedSessions = _activeSessions.entries.toList()
        ..sort((a, b) => a.value.startTime.compareTo(b.value.startTime));

      final toRemove =
          sortedSessions.take(_activeSessions.length - _maxActiveSessions);
      for (final entry in toRemove) {
        _activeSessions.remove(entry.key);
        log('清理旧会话以释放内存: ${entry.value.id}');
      }
    }
  }

  /// 监控资源使用
  void _monitorResources() {
    if (_isDisposed) return;

    log('资源监控 - 活跃会话: ${_activeSessions.length}, '
        '待处理冲突: ${_pendingConflicts.length}, '
        '订阅数: ${_subscriptions.length}');

    // 清理无效的冲突
    _pendingConflicts.removeWhere((conflict) {
      final age = DateTime.now().difference(conflict.detectedAt);
      return age > const Duration(hours: 24);
    });
  }

  /// 释放所有资源
  Future<void> dispose() async {
    if (_isDisposed) return;

    log('开始释放MultiDeviceSyncService资源');
    _isDisposed = true;

    try {
      // 停止所有服务
      await stopSharing();

      // 取消所有订阅
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();

      // 停止定时器
      _sessionCleanupTimer?.cancel();
      _sessionCleanupTimer = null;
      _resourceMonitorTimer?.cancel();
      _resourceMonitorTimer = null;

      // 关闭StreamController
      await _devicesController.close();
      await _syncSessionController.close();
      await _conflictsController.close();

      // 清理数据
      _activeSessions.clear();
      _pendingConflicts.clear();

      // 释放服务资源
      await _discoveryService.dispose();
      await _communicationService.dispose();

      // 重置状态
      _isInitialized = false;
      _isDiscovering = false;
      _isAdvertising = false;

      log('MultiDeviceSyncService资源释放完成');
    } catch (e, stackTrace) {
      log('释放资源时发生错误: $e', stackTrace: stackTrace);
    }
  }
}

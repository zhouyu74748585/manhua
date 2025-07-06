import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../presentation/providers/sync_providers.dart';
import '../../models/sync/device_info.dart';
import '../../models/sync/sync_conflict.dart';
import '../../models/sync/sync_session.dart';
import 'library_sync_service.dart';
import 'multi_device_sync_service.dart';

part 'sync_coordinator_service.g.dart';

/// 多设备同步事件类型
sealed class MultiDeviceSyncEvent {
  const MultiDeviceSyncEvent();

  /// 设备发现事件
  factory MultiDeviceSyncEvent.deviceDiscovered(DeviceInfo device) =
      MultiDeviceSyncDeviceDiscovered;

  /// 设备丢失事件
  factory MultiDeviceSyncEvent.deviceLost(String deviceId) =
      MultiDeviceSyncDeviceLost;

  /// 同步会话开始事件
  factory MultiDeviceSyncEvent.sessionStarted(SyncSession session) =
      MultiDeviceSyncSessionStarted;

  /// 同步会话完成事件
  factory MultiDeviceSyncEvent.sessionCompleted(SyncSession session) =
      MultiDeviceSyncSessionCompleted;

  /// 同步进度更新事件
  factory MultiDeviceSyncEvent.progressUpdated(
      String sessionId, double progress) = MultiDeviceSyncProgressUpdated;
}

/// 设备发现事件
class MultiDeviceSyncDeviceDiscovered extends MultiDeviceSyncEvent {
  final DeviceInfo device;
  const MultiDeviceSyncDeviceDiscovered(this.device);
}

/// 设备丢失事件
class MultiDeviceSyncDeviceLost extends MultiDeviceSyncEvent {
  final String deviceId;
  const MultiDeviceSyncDeviceLost(this.deviceId);
}

/// 同步会话开始事件
class MultiDeviceSyncSessionStarted extends MultiDeviceSyncEvent {
  final SyncSession session;
  const MultiDeviceSyncSessionStarted(this.session);
}

/// 同步会话完成事件
class MultiDeviceSyncSessionCompleted extends MultiDeviceSyncEvent {
  final SyncSession session;
  const MultiDeviceSyncSessionCompleted(this.session);
}

/// 同步进度更新事件
class MultiDeviceSyncProgressUpdated extends MultiDeviceSyncEvent {
  final String sessionId;
  final double progress;
  const MultiDeviceSyncProgressUpdated(this.sessionId, this.progress);
}

@riverpod
SyncCoordinatorService syncCoordinatorService(Ref ref) {
  return SyncCoordinatorService(
    multiDeviceSyncService: ref.watch(multiDeviceSyncServiceProvider),
    librarySyncService: ref.watch(librarySyncServiceProvider),
  );
}

/// Coordinates synchronization between multiple devices
/// Integrates device discovery, library sync, and conflict resolution
class SyncCoordinatorService {
  final MultiDeviceSyncService _multiDeviceSyncService;
  final LibrarySyncService _librarySyncService;

  final StreamController<SyncCoordinatorEvent> _eventController =
      StreamController<SyncCoordinatorEvent>.broadcast();

  SyncCoordinatorService({
    required MultiDeviceSyncService multiDeviceSyncService,
    required LibrarySyncService librarySyncService,
  })  : _multiDeviceSyncService = multiDeviceSyncService,
        _librarySyncService = librarySyncService {
    _initializeEventStreams();
  }

  /// Stream of sync coordinator events
  Stream<SyncCoordinatorEvent> get eventStream => _eventController.stream;

  /// Available devices for synchronization
  Stream<List<DeviceInfo>> get availableDevicesStream =>
      _multiDeviceSyncService.availableDevicesStream;

  /// Active sync sessions
  Stream<List<SyncSession>> get activeSyncSessionsStream =>
      _multiDeviceSyncService.activeSyncSessionsStream;

  /// Sync conflicts
  Stream<List<SyncConflict>> get conflictsStream =>
      _librarySyncService.conflictsStream;

  /// Pending conflicts
  List<SyncConflict> get pendingConflicts =>
      _librarySyncService.pendingConflicts;

  /// Initialize the sync coordinator
  Future<void> initialize() async {
    try {
      log('Initializing sync coordinator');

      // Initialize multi-device sync service
      await _multiDeviceSyncService.initialize();

      _eventController.add(SyncCoordinatorEvent.initialized());
      log('Sync coordinator initialized successfully');
    } catch (e, stackTrace) {
      log('Failed to initialize sync coordinator: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Initialization failed: $e'));
      rethrow;
    }
  }

  /// Start device discovery
  Future<void> startDeviceDiscovery() async {
    try {
      await _multiDeviceSyncService.startDeviceDiscovery();
      _eventController.add(SyncCoordinatorEvent.discoveryStarted());
    } catch (e) {
      log('Failed to start device discovery: $e');
      _eventController.add(SyncCoordinatorEvent.error('Discovery failed: $e'));
    }
  }

  /// Stop device discovery
  Future<void> stopDeviceDiscovery() async {
    try {
      await _multiDeviceSyncService.stopDeviceDiscovery();
      _eventController.add(SyncCoordinatorEvent.discoveryStopped());
    } catch (e) {
      log('Failed to stop device discovery: $e');
    }
  }

  /// Synchronize libraries with a target device
  Future<SyncResult> syncLibrariesWithDevice({
    required DeviceInfo targetDevice,
    required List<String> libraryIds,
    SyncDirection direction = SyncDirection.bidirectional,
    bool resolveConflictsAutomatically = true,
  }) async {
    try {
      log('Starting library sync with ${targetDevice.name}');

      // Create sync session
      final session = await _multiDeviceSyncService.startLibrarySync(
        targetDevice: targetDevice,
        libraryIds: libraryIds,
        direction: direction,
      );

      _eventController.add(SyncCoordinatorEvent.syncStarted(session));

      // Perform library synchronization
      final result = await _librarySyncService.syncLibraries(
        targetDevice: targetDevice,
        libraryIds: libraryIds,
        direction: direction,
        resolveConflictsAutomatically: resolveConflictsAutomatically,
      );

      // Update session with result
      final updatedSession = session.copyWith(
        status: result.status,
        totalItems: result.totalItems,
        processedItems: result.processedItems,
        failedItems: result.failedItems,
        errorMessage: result.errorMessage,
        endTime: result.endTime,
      );

      await _multiDeviceSyncService.updateSyncSession(updatedSession);

      _eventController
          .add(SyncCoordinatorEvent.syncCompleted(updatedSession, result));

      return result;
    } catch (e, stackTrace) {
      log('Library sync failed: $e', stackTrace: stackTrace);
      _eventController.add(SyncCoordinatorEvent.error('Sync failed: $e'));
      rethrow;
    }
  }

  /// Synchronize reading progress for a specific manga
  Future<SyncResult> syncReadingProgress({
    required DeviceInfo targetDevice,
    required String mangaId,
    bool useLatestWins = true,
  }) async {
    try {
      log('Starting reading progress sync for manga: $mangaId');

      final result = await _librarySyncService.syncReadingProgress(
        targetDevice: targetDevice,
        mangaId: mangaId,
        useLatestWins: useLatestWins,
      );

      _eventController
          .add(SyncCoordinatorEvent.progressSyncCompleted(mangaId, result));

      return result;
    } catch (e, stackTrace) {
      log('Reading progress sync failed: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Progress sync failed: $e'));
      rethrow;
    }
  }

  /// Synchronize reading progress for multiple manga
  Future<SyncResult> syncMultipleReadingProgress({
    required DeviceInfo targetDevice,
    required List<String> mangaIds,
    bool useLatestWins = true,
    bool syncFavorites = false,
    bool syncBookmarks = false,
  }) async {
    try {
      log('Starting multiple reading progress sync for ${mangaIds.length} manga');

      final startTime = DateTime.now();
      final sessionId = 'multi_progress_sync_${startTime.millisecondsSinceEpoch}';

      int totalItems = mangaIds.length;
      int processedItems = 0;
      List<String> errors = [];

      for (final mangaId in mangaIds) {
        try {
          await _librarySyncService.syncReadingProgress(
            targetDevice: targetDevice,
            mangaId: mangaId,
            useLatestWins: useLatestWins,
          );
          processedItems++;
        } catch (e) {
          errors.add('Failed to sync manga $mangaId: $e');
        }
      }

      final result = SyncResult(
        sessionId: sessionId,
        status: errors.isEmpty ? SyncStatus.completed : SyncStatus.partiallyCompleted,
        totalItems: totalItems,
        processedItems: processedItems,
        errorMessage: errors.isNotEmpty ? errors.join('; ') : null,
        startTime: startTime,
        endTime: DateTime.now(),
      );

      _eventController
          .add(SyncCoordinatorEvent.progressSyncCompleted('multiple', result));

      return result;
    } catch (e, stackTrace) {
      log('Multiple reading progress sync failed: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Multiple progress sync failed: $e'));
      rethrow;
    }
  }

  /// Resolve a specific conflict
  Future<void> resolveConflict(
      SyncConflict conflict, ConflictResolution resolution) async {
    try {
      log('Resolving conflict: ${conflict.id} with resolution: $resolution');

      final resolvedConflict = conflict.copyWith(
        resolution: resolution,
        resolvedAt: DateTime.now(),
        resolvedData: _getResolvedData(conflict, resolution),
      );

      // Apply the resolution
      await _applyConflictResolution(resolvedConflict);

      // Remove from pending conflicts
      _librarySyncService.pendingConflicts
          .removeWhere((c) => c.id == conflict.id);

      _eventController
          .add(SyncCoordinatorEvent.conflictResolved(resolvedConflict));
    } catch (e, stackTrace) {
      log('Failed to resolve conflict: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Conflict resolution failed: $e'));
    }
  }

  /// Get all available devices
  List<DeviceInfo> getAvailableDevices() {
    return _multiDeviceSyncService.getAvailableDevices();
  }

  /// Get active sync sessions
  List<SyncSession> getActiveSyncSessions() {
    return _multiDeviceSyncService.getActiveSyncSessions();
  }

  /// Accept a sync request from another device
  Future<void> acceptSyncRequest(
      String requestId, List<dynamic> selectedLibraries) async {
    try {
      log('Accepting sync request: $requestId');

      // Convert libraries to library IDs
      final libraryIds = selectedLibraries
          .map((lib) => lib is String ? lib : lib.id.toString())
          .cast<String>()
          .toList();

      // TODO: Implement actual sync request acceptance logic
      // This would typically involve:
      // 1. Validating the request
      // 2. Starting the sync process
      // 3. Notifying the requesting device

      _eventController.add(SyncCoordinatorEvent.initialized());
      log('Sync request accepted: $requestId');
    } catch (e, stackTrace) {
      log('Failed to accept sync request: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Failed to accept sync request: $e'));
      rethrow;
    }
  }

  /// Reject a sync request from another device
  Future<void> rejectSyncRequest(String requestId) async {
    try {
      log('Rejecting sync request: $requestId');

      // TODO: Implement actual sync request rejection logic
      // This would typically involve:
      // 1. Validating the request
      // 2. Notifying the requesting device
      // 3. Cleaning up any pending resources

      log('Sync request rejected: $requestId');
    } catch (e, stackTrace) {
      log('Failed to reject sync request: $e', stackTrace: stackTrace);
      _eventController
          .add(SyncCoordinatorEvent.error('Failed to reject sync request: $e'));
      rethrow;
    }
  }

  /// Initialize event stream listeners
  void _initializeEventStreams() {
    // Listen to multi-device sync events
    _multiDeviceSyncService.eventStream.listen((event) {
      _eventController.add(SyncCoordinatorEvent.multiDeviceEvent(event));
    });

    // Listen to library sync progress
    _librarySyncService.progressStream.listen((progress) {
      _eventController.add(SyncCoordinatorEvent.syncProgress(progress));
    });

    // Listen to conflicts
    _librarySyncService.conflictsStream.listen((conflicts) {
      _eventController.add(SyncCoordinatorEvent.conflictsDetected(conflicts));
    });
  }

  /// Get resolved data based on conflict resolution strategy
  Map<String, dynamic>? _getResolvedData(
      SyncConflict conflict, ConflictResolution resolution) {
    switch (resolution) {
      case ConflictResolution.useSource:
        return conflict.sourceData;
      case ConflictResolution.useTarget:
        return conflict.targetData;
      case ConflictResolution.useLatest:
        return conflict.sourceTimestamp.isAfter(conflict.targetTimestamp)
            ? conflict.sourceData
            : conflict.targetData;
      case ConflictResolution.merge:
        // For now, use latest as merge strategy
        return conflict.sourceTimestamp.isAfter(conflict.targetTimestamp)
            ? conflict.sourceData
            : conflict.targetData;
      case ConflictResolution.latestWins:
        return conflict.sourceTimestamp.isAfter(conflict.targetTimestamp)
            ? conflict.sourceData
            : conflict.targetData;
      case ConflictResolution.manual:
        // Manual resolution should provide resolved data
        return null;
      case ConflictResolution.sourceWins:
        return conflict.sourceData;
      case ConflictResolution.targetWins:
        return conflict.targetData;
    }
  }

  /// Apply conflict resolution
  Future<void> _applyConflictResolution(SyncConflict resolvedConflict) async {
    if (!resolvedConflict.isResolved || resolvedConflict.resolvedData == null) {
      return;
    }

    // This would be implemented by calling the appropriate service methods
    // based on the conflict type
    switch (resolvedConflict.type) {
      case ConflictType.library:
        // Apply library resolution
        break;
      case ConflictType.manga:
        // Apply manga resolution
        break;
      case ConflictType.readingProgress:
        // Apply reading progress resolution
        break;
      case ConflictType.libraryMetadata:
        // Apply library metadata resolution
        break;
      case ConflictType.mangaMetadata:
        // Apply manga metadata resolution
        break;
      case ConflictType.duplicateId:
        // Apply duplicate ID resolution
        break;
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _eventController.close();
    await _librarySyncService.dispose();
    await _multiDeviceSyncService.dispose();
  }
}

/// Sync coordinator events
sealed class SyncCoordinatorEvent {
  const SyncCoordinatorEvent();

  factory SyncCoordinatorEvent.initialized() = SyncCoordinatorInitialized;
  factory SyncCoordinatorEvent.discoveryStarted() =
      SyncCoordinatorDiscoveryStarted;
  factory SyncCoordinatorEvent.discoveryStopped() =
      SyncCoordinatorDiscoveryStopped;
  factory SyncCoordinatorEvent.syncStarted(SyncSession session) =
      SyncCoordinatorSyncStarted;
  factory SyncCoordinatorEvent.syncCompleted(
      SyncSession session, SyncResult result) = SyncCoordinatorSyncCompleted;
  factory SyncCoordinatorEvent.syncProgress(SyncProgress progress) =
      SyncCoordinatorSyncProgress;
  factory SyncCoordinatorEvent.progressSyncCompleted(
      String mangaId, SyncResult result) = SyncCoordinatorProgressSyncCompleted;
  factory SyncCoordinatorEvent.conflictsDetected(List<SyncConflict> conflicts) =
      SyncCoordinatorConflictsDetected;
  factory SyncCoordinatorEvent.conflictResolved(SyncConflict conflict) =
      SyncCoordinatorConflictResolved;
  factory SyncCoordinatorEvent.multiDeviceEvent(MultiDeviceSyncEvent event) =
      SyncCoordinatorMultiDeviceEvent;
  factory SyncCoordinatorEvent.error(String message) = SyncCoordinatorError;
}

class SyncCoordinatorInitialized extends SyncCoordinatorEvent {
  const SyncCoordinatorInitialized();
}

class SyncCoordinatorDiscoveryStarted extends SyncCoordinatorEvent {
  const SyncCoordinatorDiscoveryStarted();
}

class SyncCoordinatorDiscoveryStopped extends SyncCoordinatorEvent {
  const SyncCoordinatorDiscoveryStopped();
}

class SyncCoordinatorSyncStarted extends SyncCoordinatorEvent {
  final SyncSession session;
  const SyncCoordinatorSyncStarted(this.session);
}

class SyncCoordinatorSyncCompleted extends SyncCoordinatorEvent {
  final SyncSession session;
  final SyncResult result;
  const SyncCoordinatorSyncCompleted(this.session, this.result);
}

class SyncCoordinatorSyncProgress extends SyncCoordinatorEvent {
  final SyncProgress progress;
  const SyncCoordinatorSyncProgress(this.progress);
}

class SyncCoordinatorProgressSyncCompleted extends SyncCoordinatorEvent {
  final String mangaId;
  final SyncResult result;
  const SyncCoordinatorProgressSyncCompleted(this.mangaId, this.result);
}

class SyncCoordinatorConflictsDetected extends SyncCoordinatorEvent {
  final List<SyncConflict> conflicts;
  const SyncCoordinatorConflictsDetected(this.conflicts);
}

class SyncCoordinatorConflictResolved extends SyncCoordinatorEvent {
  final SyncConflict conflict;
  const SyncCoordinatorConflictResolved(this.conflict);
}

class SyncCoordinatorMultiDeviceEvent extends SyncCoordinatorEvent {
  final MultiDeviceSyncEvent event;
  const SyncCoordinatorMultiDeviceEvent(this.event);
}

class SyncCoordinatorError extends SyncCoordinatorEvent {
  final String message;
  const SyncCoordinatorError(this.message);
}

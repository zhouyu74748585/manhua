import 'dart:async';
import 'dart:developer';

import '../../../core/services/network/sync_communication_service.dart';
import '../../../core/services/sync/batch_sync_processor.dart';
import '../../models/library.dart';
import '../../models/manga.dart';
import '../../models/reading_progress.dart';
import '../../models/sync/device_info.dart';
import '../../models/sync/sync_conflict.dart';
import '../../models/sync/sync_session.dart';
import '../../services/drift_database_service.dart';

// Import the sync result and progress classes from coordinator
class SyncResult {
  final String sessionId;
  final SyncStatus status;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final List<SyncConflict> conflicts;
  final String? errorMessage;
  final DateTime startTime;
  final DateTime endTime;

  const SyncResult({
    required this.sessionId,
    required this.status,
    required this.totalItems,
    required this.processedItems,
    this.failedItems = 0,
    this.conflicts = const [],
    this.errorMessage,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
  bool get hasErrors => failedItems > 0 || errorMessage != null;
  bool get hasConflicts => conflicts.isNotEmpty;
}

class SyncProgress {
  final String sessionId;
  final int totalItems;
  final int processedItems;
  final String currentItem;

  const SyncProgress({
    required this.sessionId,
    required this.totalItems,
    required this.processedItems,
    required this.currentItem,
  });

  double get progress => totalItems > 0 ? processedItems / totalItems : 0.0;
}

/// Service for handling library synchronization between devices
class LibrarySyncService {
  final SyncCommunicationService _communicationService =
      SyncCommunicationService();

  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  final StreamController<List<SyncConflict>> _conflictsController =
      StreamController<List<SyncConflict>>.broadcast();

  final List<SyncConflict> _pendingConflicts = [];

  /// Stream of sync progress updates
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Stream of sync conflicts
  Stream<List<SyncConflict>> get conflictsStream => _conflictsController.stream;

  /// Pending conflicts
  List<SyncConflict> get pendingConflicts => _pendingConflicts;

  /// Synchronize libraries with target device
  Future<SyncResult> syncLibraries({
    required DeviceInfo targetDevice,
    required List<String> libraryIds,
    SyncDirection direction = SyncDirection.bidirectional,
    bool resolveConflictsAutomatically = true,
  }) async {
    final startTime = DateTime.now();
    final sessionId = 'lib_sync_${startTime.millisecondsSinceEpoch}';

    try {
      log('Starting library sync with ${targetDevice.name} for libraries: $libraryIds');

      // Step 1: Get local library data
      final localLibraries = await _getLocalLibraries(libraryIds);
      final localManga = await _getLocalManga(libraryIds);

      // Step 2: Get remote library data
      final remoteData = await _getRemoteLibraryData(targetDevice, libraryIds);

      // Step 3: Compare and identify differences
      final syncPlan = await _createSyncPlan(
        localLibraries: localLibraries,
        localManga: localManga,
        remoteLibraries: remoteData.libraries,
        remoteManga: remoteData.manga,
        direction: direction,
      );

      // Step 4: Handle conflicts
      if (syncPlan.conflicts.isNotEmpty) {
        _pendingConflicts.addAll(syncPlan.conflicts);
        _conflictsController.add(_pendingConflicts);

        if (resolveConflictsAutomatically) {
          await _resolveConflictsAutomatically(syncPlan.conflicts);
        } else {
          // Wait for manual conflict resolution
          return SyncResult(
            sessionId: sessionId,
            status: SyncStatus.conflicted,
            totalItems: syncPlan.totalItems,
            processedItems: 0,
            conflicts: syncPlan.conflicts,
            startTime: startTime,
            endTime: DateTime.now(),
          );
        }
      }

      // Step 5: Execute sync plan
      final result = await _executeSyncPlan(targetDevice, syncPlan, sessionId);

      log('Library sync completed: ${result.status}');
      return result;
    } catch (e, stackTrace) {
      log('Library sync failed: $e', stackTrace: stackTrace);
      return SyncResult(
        sessionId: sessionId,
        status: SyncStatus.failed,
        totalItems: 0,
        processedItems: 0,
        errorMessage: e.toString(),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Synchronize reading progress with target device
  Future<SyncResult> syncReadingProgress({
    required DeviceInfo targetDevice,
    required String mangaId,
    bool useLatestWins = true,
  }) async {
    final startTime = DateTime.now();
    final sessionId = 'progress_sync_${startTime.millisecondsSinceEpoch}';

    try {
      log('Starting reading progress sync for manga: $mangaId');

      // Get local progress
      final localProgress =
          await DriftDatabaseService.getReadingProgressByMangaId(mangaId);

      // Get remote progress
      final remoteProgress =
          await _communicationService.getReadingProgress(targetDevice, mangaId);

      // Resolve conflicts using latest-wins strategy
      ReadingProgress? finalProgress;
      if (localProgress != null && remoteProgress != null) {
        if (useLatestWins) {
          finalProgress =
              localProgress.lastReadAt.isAfter(remoteProgress.lastReadAt)
                  ? localProgress
                  : remoteProgress;
        } else {
          // Create conflict for manual resolution
          final conflict = SyncConflict(
            id: 'progress_conflict_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: sessionId,
            type: ConflictType.readingProgress,
            itemId: mangaId,
            itemType: 'reading_progress', // 添加必需的 itemType 参数
            sourceDeviceId: 'local',
            targetDeviceId: targetDevice.id,
            sourceData: localProgress.toJson(),
            targetData: remoteProgress.toJson(),
            sourceTimestamp: localProgress.lastReadAt,
            targetTimestamp: remoteProgress.lastReadAt,
            resolution: ConflictResolution.useLatest, // 添加必需的 resolution 参数
            detectedAt: DateTime.now(),
          );

          _pendingConflicts.add(conflict);
          _conflictsController.add(_pendingConflicts);

          return SyncResult(
            sessionId: sessionId,
            status: SyncStatus.conflicted,
            totalItems: 1,
            processedItems: 0,
            conflicts: [conflict],
            startTime: startTime,
            endTime: DateTime.now(),
          );
        }
      } else {
        finalProgress = localProgress ?? remoteProgress;
      }

      // Apply the final progress
      if (finalProgress != null) {
        await DriftDatabaseService.insertOrUpdateReadingProgress(finalProgress);
        await _communicationService.updateReadingProgress(
            targetDevice, finalProgress);
      }

      return SyncResult(
        sessionId: sessionId,
        status: SyncStatus.completed,
        totalItems: 1,
        processedItems: 1,
        startTime: startTime,
        endTime: DateTime.now(),
      );
    } catch (e, stackTrace) {
      log('Reading progress sync failed: $e', stackTrace: stackTrace);
      return SyncResult(
        sessionId: sessionId,
        status: SyncStatus.failed,
        totalItems: 1,
        processedItems: 0,
        errorMessage: e.toString(),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Get local libraries by IDs
  Future<List<MangaLibrary>> _getLocalLibraries(List<String> libraryIds) async {
    final libraries = <MangaLibrary>[];
    for (final id in libraryIds) {
      final library = await DriftDatabaseService.getLibraryById(id);
      if (library != null) {
        libraries.add(library);
      }
    }
    return libraries;
  }

  /// Get local manga for specified libraries
  Future<List<Manga>> _getLocalManga(List<String> libraryIds) async {
    final allManga = <Manga>[];
    for (final libraryId in libraryIds) {
      final manga = await DriftDatabaseService.getMangaByLibraryId(libraryId);
      allManga.addAll(manga);
    }
    return allManga;
  }

  /// Get remote library data from target device
  Future<RemoteLibraryData> _getRemoteLibraryData(
    DeviceInfo targetDevice,
    List<String> libraryIds,
  ) async {
    try {
      final libraries =
          await _communicationService.getLibraries(targetDevice, libraryIds);
      final manga =
          await _communicationService.getManga(targetDevice, libraryIds);

      return RemoteLibraryData(
        libraries: libraries,
        manga: manga,
      );
    } catch (e) {
      log('Failed to get remote library data: $e');
      return RemoteLibraryData(libraries: [], manga: []);
    }
  }

  /// Create synchronization plan by comparing local and remote data
  Future<SyncPlan> _createSyncPlan({
    required List<MangaLibrary> localLibraries,
    required List<Manga> localManga,
    required List<MangaLibrary> remoteLibraries,
    required List<Manga> remoteManga,
    required SyncDirection direction,
  }) async {
    final conflicts = <SyncConflict>[];
    final librariesToSync = <MangaLibrary>[];
    final mangaToSync = <Manga>[];
    final librariesToDelete = <String>[];
    final mangaToDelete = <String>[];

    // Create maps for efficient lookup
    final localLibraryMap = {for (var lib in localLibraries) lib.id: lib};
    final remoteLibraryMap = {for (var lib in remoteLibraries) lib.id: lib};
    final localMangaMap = {for (var manga in localManga) manga.id: manga};
    final remoteMangaMap = {for (var manga in remoteManga) manga.id: manga};

    // Compare libraries
    for (final remoteLib in remoteLibraries) {
      final localLib = localLibraryMap[remoteLib.id];

      if (localLib == null) {
        // New library from remote
        if (direction == SyncDirection.bidirectional ||
            direction == SyncDirection.fromRemote) {
          librariesToSync.add(remoteLib);
        }
      } else {
        // Library exists on both sides - check for conflicts
        if (_hasLibraryConflict(localLib, remoteLib)) {
          final conflict = _createLibraryConflict(localLib, remoteLib);
          conflicts.add(conflict);
        }
      }
    }

    // Compare manga
    for (final remoteManga in remoteManga) {
      final localMangaItem = localMangaMap[remoteManga.id];

      if (localMangaItem == null) {
        // New manga from remote
        if (direction == SyncDirection.bidirectional ||
            direction == SyncDirection.fromRemote) {
          mangaToSync.add(remoteManga);
        }
      } else {
        // Manga exists on both sides - check for conflicts
        if (_hasMangaConflict(localMangaItem, remoteManga)) {
          final conflict = _createMangaConflict(localMangaItem, remoteManga);
          conflicts.add(conflict);
        }
      }
    }

    // Handle local-only items for bidirectional or toRemote sync
    if (direction == SyncDirection.bidirectional ||
        direction == SyncDirection.toRemote) {
      for (final localLib in localLibraries) {
        if (!remoteLibraryMap.containsKey(localLib.id)) {
          librariesToSync.add(localLib);
        }
      }

      for (final localMangaItem in localManga) {
        if (!remoteMangaMap.containsKey(localMangaItem.id)) {
          mangaToSync.add(localMangaItem);
        }
      }
    }

    final totalItems = librariesToSync.length +
        mangaToSync.length +
        librariesToDelete.length +
        mangaToDelete.length;

    return SyncPlan(
      librariesToSync: librariesToSync,
      mangaToSync: mangaToSync,
      librariesToDelete: librariesToDelete,
      mangaToDelete: mangaToDelete,
      conflicts: conflicts,
      totalItems: totalItems,
    );
  }

  /// Check if there's a conflict between local and remote library
  bool _hasLibraryConflict(MangaLibrary local, MangaLibrary remote) {
    // Check for meaningful differences that constitute a conflict
    return local.name != remote.name ||
        local.path != remote.path ||
        local.type != remote.type ||
        local.isEnabled != remote.isEnabled;
  }

  /// Check if there's a conflict between local and remote manga
  bool _hasMangaConflict(Manga local, Manga remote) {
    // Check for meaningful differences
    return local.title != remote.title ||
        local.author != remote.author ||
        local.isFavorite != remote.isFavorite ||
        local.isCompleted != remote.isCompleted ||
        local.rating != remote.rating ||
        (local.lastReadAt != null &&
            remote.lastReadAt != null &&
            local.lastReadAt != remote.lastReadAt);
  }

  /// Create library conflict object
  SyncConflict _createLibraryConflict(MangaLibrary local, MangaLibrary remote) {
    return SyncConflict(
      id: 'lib_conflict_${local.id}_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: 'current_session',
      type: ConflictType.library,
      itemId: local.id,
      itemType: 'manga_library', // 添加必需的 itemType 参数
      sourceDeviceId: 'local',
      targetDeviceId: 'remote',
      sourceData: local.toJson(),
      targetData: remote.toJson(),
      sourceTimestamp: local.lastScanAt ?? local.createdAt,
      targetTimestamp: remote.lastScanAt ?? remote.createdAt,
      resolution: ConflictResolution.useLatest, // 添加必需的 resolution 参数
      detectedAt: DateTime.now(),
    );
  }

  /// Create manga conflict object
  SyncConflict _createMangaConflict(Manga local, Manga remote) {
    return SyncConflict(
      id: 'manga_conflict_${local.id}_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: 'current_session',
      type: ConflictType.manga,
      itemId: local.id,
      itemType: 'manga', // 添加必需的 itemType 参数
      sourceDeviceId: 'local',
      targetDeviceId: 'remote',
      sourceData: local.toJson(),
      targetData: remote.toJson(),
      sourceTimestamp: local.updatedAt ?? local.createdAt ?? DateTime.now(),
      targetTimestamp: remote.updatedAt ?? remote.createdAt ?? DateTime.now(),
      resolution: ConflictResolution.useLatest, // 添加必需的 resolution 参数
      detectedAt: DateTime.now(),
    );
  }

  /// Automatically resolve conflicts using latest-wins strategy
  Future<void> _resolveConflictsAutomatically(
      List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      try {
        final resolvedConflict = conflict.resolveWithLatestWins();

        // Apply the resolution
        await _applyConflictResolution(resolvedConflict);

        // Update conflict list
        final index = _pendingConflicts.indexWhere((c) => c.id == conflict.id);
        if (index != -1) {
          _pendingConflicts[index] = resolvedConflict;
        }
      } catch (e) {
        log('Failed to resolve conflict ${conflict.id}: $e');
      }
    }

    _conflictsController.add(_pendingConflicts);
  }

  /// Apply conflict resolution
  Future<void> _applyConflictResolution(SyncConflict resolvedConflict) async {
    if (!resolvedConflict.isResolved || resolvedConflict.resolvedData == null) {
      return;
    }

    try {
      switch (resolvedConflict.type) {
        case ConflictType.library:
          final library = MangaLibrary.fromJson(resolvedConflict.resolvedData!);
          await DriftDatabaseService.updateLibrary(library);
          break;

        case ConflictType.manga:
          final manga = Manga.fromJson(resolvedConflict.resolvedData!);
          await DriftDatabaseService.updateManga(manga);
          break;

        case ConflictType.readingProgress:
          final progress =
              ReadingProgress.fromJson(resolvedConflict.resolvedData!);
          await DriftDatabaseService.insertOrUpdateReadingProgress(progress);
          break;

        case ConflictType.libraryMetadata:
          // 处理库元数据冲突
          final library = MangaLibrary.fromJson(resolvedConflict.resolvedData!);
          await DriftDatabaseService.updateLibrary(library);
          break;

        case ConflictType.mangaMetadata:
          // 处理漫画元数据冲突
          final manga = Manga.fromJson(resolvedConflict.resolvedData!);
          await DriftDatabaseService.updateManga(manga);
          break;

        case ConflictType.duplicateId:
          // 处理重复ID冲突
          log('Duplicate ID conflict resolution not implemented yet');
          break;
      }
    } catch (e) {
      log('Failed to apply conflict resolution: $e');
      rethrow;
    }
  }

  /// Execute the synchronization plan
  Future<SyncResult> _executeSyncPlan(
    DeviceInfo targetDevice,
    SyncPlan plan,
    String sessionId,
  ) async {
    final startTime = DateTime.now();
    int processedItems = 0;
    int failedItems = 0;
    final errors = <String>[];

    try {
      // 使用分批处理同步库
      if (plan.librariesToSync.isNotEmpty) {
        final libraryBatchResult =
            await BatchSyncProcessor.processBatch<MangaLibrary>(
          items: plan.librariesToSync,
          processor: (batch) async {
            int batchProcessed = 0;
            int batchFailed = 0;

            for (final library in batch) {
              try {
                await _communicationService.syncLibrary(targetDevice, library);
                batchProcessed++;
              } catch (e) {
                batchFailed++;
                errors.add('Failed to sync library ${library.name}: $e');
                log('Failed to sync library ${library.id}: $e');
              }
            }

            return BatchProcessResult(
              processedItems: batchProcessed,
              failedItems: batchFailed,
            );
          },
          batchSize: BatchSyncProcessor.calculateOptimalBatchSize(
            totalItems: plan.librariesToSync.length,
            availableMemoryMB: 100, // 预留100MB内存
            estimatedItemSizeKB: 50, // 估计每个库50KB
          ),
          onProgress: (progress) {
            _progressController.add(SyncProgress(
              sessionId: sessionId,
              totalItems: plan.totalItems,
              processedItems: processedItems + progress.processedItems,
              currentItem:
                  'Libraries: ${progress.currentBatch}/${progress.totalBatches}',
            ));
          },
        );

        processedItems += libraryBatchResult.processedItems;
        failedItems += libraryBatchResult.failedItems;
      }

      // 使用分批处理同步漫画
      if (plan.mangaToSync.isNotEmpty) {
        final mangaBatchResult = await BatchSyncProcessor.processBatch<Manga>(
          items: plan.mangaToSync,
          processor: (batch) async {
            int batchProcessed = 0;
            int batchFailed = 0;

            for (final manga in batch) {
              try {
                await _communicationService.syncManga(targetDevice, manga);
                batchProcessed++;
              } catch (e) {
                batchFailed++;
                errors.add('Failed to sync manga ${manga.title}: $e');
                log('Failed to sync manga ${manga.id}: $e');
              }
            }

            return BatchProcessResult(
              processedItems: batchProcessed,
              failedItems: batchFailed,
            );
          },
          batchSize: BatchSyncProcessor.calculateOptimalBatchSize(
            totalItems: plan.mangaToSync.length,
            availableMemoryMB: 150, // 漫画数据较大，预留更多内存
            estimatedItemSizeKB: 200, // 估计每个漫画200KB
          ),
          onProgress: (progress) {
            _progressController.add(SyncProgress(
              sessionId: sessionId,
              totalItems: plan.totalItems,
              processedItems: processedItems + progress.processedItems,
              currentItem:
                  'Manga: ${progress.currentBatch}/${progress.totalBatches}',
            ));
          },
        );

        processedItems += mangaBatchResult.processedItems;
        failedItems += mangaBatchResult.failedItems;
      }

      final status = failedItems == 0
          ? SyncStatus.completed
          : processedItems > 0
              ? SyncStatus.partiallyCompleted
              : SyncStatus.failed;

      return SyncResult(
        sessionId: sessionId,
        status: status,
        totalItems: plan.totalItems,
        processedItems: processedItems,
        failedItems: failedItems,
        errorMessage: errors.isNotEmpty ? errors.join('; ') : null,
        startTime: startTime,
        endTime: DateTime.now(),
      );
    } catch (e, stackTrace) {
      log('Failed to execute sync plan: $e', stackTrace: stackTrace);
      return SyncResult(
        sessionId: sessionId,
        status: SyncStatus.failed,
        totalItems: plan.totalItems,
        processedItems: processedItems,
        failedItems: failedItems,
        errorMessage: e.toString(),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _progressController.close();
    await _conflictsController.close();
    _pendingConflicts.clear();
  }
}

/// Remote library data container
class RemoteLibraryData {
  final List<MangaLibrary> libraries;
  final List<Manga> manga;

  const RemoteLibraryData({
    required this.libraries,
    required this.manga,
  });
}

/// Synchronization plan
class SyncPlan {
  final List<MangaLibrary> librariesToSync;
  final List<Manga> mangaToSync;
  final List<String> librariesToDelete;
  final List<String> mangaToDelete;
  final List<SyncConflict> conflicts;
  final int totalItems;

  const SyncPlan({
    required this.librariesToSync,
    required this.mangaToSync,
    required this.librariesToDelete,
    required this.mangaToDelete,
    required this.conflicts,
    required this.totalItems,
  });
}

import 'package:json_annotation/json_annotation.dart';

part 'sync_conflict.g.dart';

/// Conflict resolution strategy
enum ConflictResolution {
  @JsonValue('latest_wins')
  latestWins,
  @JsonValue('manual')
  manual,
  @JsonValue('source_wins')
  sourceWins,
  @JsonValue('target_wins')
  targetWins,
  @JsonValue('use_source')
  useSource,
  @JsonValue('use_target')
  useTarget,
  @JsonValue('use_latest')
  useLatest,
  @JsonValue('merge')
  merge,
}

/// Conflict type
enum ConflictType {
  @JsonValue('reading_progress')
  readingProgress,
  @JsonValue('library_metadata')
  libraryMetadata,
  @JsonValue('manga_metadata')
  mangaMetadata,
  @JsonValue('duplicate_id')
  duplicateId,
  @JsonValue('library')
  library,
  @JsonValue('manga')
  manga,
}

/// Sync conflict information
@JsonSerializable()
class SyncConflict {
  final String id;
  final String sessionId;
  final ConflictType type;
  final String itemId; // Library ID, Manga ID, etc.
  final String itemType; // 'library', 'manga', 'reading_progress'
  final String sourceDeviceId; // 源设备ID
  final String targetDeviceId; // 目标设备ID
  final Map<String, dynamic> sourceData;
  final Map<String, dynamic> targetData;
  final DateTime sourceTimestamp; // 源数据时间戳
  final DateTime targetTimestamp; // 目标数据时间戳
  final ConflictResolution resolution;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy; // Device ID that resolved the conflict
  final Map<String, dynamic> resolvedData;
  final bool isResolved;

  const SyncConflict({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.itemId,
    required this.itemType,
    required this.sourceDeviceId,
    required this.targetDeviceId,
    required this.sourceData,
    required this.targetData,
    required this.sourceTimestamp,
    required this.targetTimestamp,
    required this.resolution,
    required this.detectedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolvedData = const {},
    this.isResolved = false,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictFromJson(json);
  Map<String, dynamic> toJson() => _$SyncConflictToJson(this);

  SyncConflict copyWith({
    String? id,
    String? sessionId,
    ConflictType? type,
    String? itemId,
    String? itemType,
    String? sourceDeviceId,
    String? targetDeviceId,
    Map<String, dynamic>? sourceData,
    Map<String, dynamic>? targetData,
    DateTime? sourceTimestamp,
    DateTime? targetTimestamp,
    ConflictResolution? resolution,
    DateTime? detectedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    Map<String, dynamic>? resolvedData,
    bool? isResolved,
  }) {
    return SyncConflict(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      sourceData: sourceData ?? this.sourceData,
      targetData: targetData ?? this.targetData,
      sourceTimestamp: sourceTimestamp ?? this.sourceTimestamp,
      targetTimestamp: targetTimestamp ?? this.targetTimestamp,
      resolution: resolution ?? this.resolution,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedData: resolvedData ?? this.resolvedData,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  /// Resolve conflict with latest wins strategy
  SyncConflict resolveWithLatestWins() {
    final sourceTime = _extractTimestamp(sourceData);
    final targetTime = _extractTimestamp(targetData);

    final useSource = sourceTime.isAfter(targetTime);
    final resolvedData = useSource ? sourceData : targetData;

    return copyWith(
      resolution: ConflictResolution.latestWins,
      resolvedAt: DateTime.now(),
      resolvedData: resolvedData,
      isResolved: true,
    );
  }

  /// Extract timestamp from data for comparison
  DateTime _extractTimestamp(Map<String, dynamic> data) {
    // Try different timestamp fields
    final timestampFields = [
      'updatedAt',
      'lastReadAt',
      'lastScanAt',
      'createdAt'
    ];

    for (final field in timestampFields) {
      if (data.containsKey(field) && data[field] != null) {
        if (data[field] is String) {
          return DateTime.tryParse(data[field]) ??
              DateTime.fromMillisecondsSinceEpoch(0);
        } else if (data[field] is DateTime) {
          return data[field];
        }
      }
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  String toString() {
    return 'SyncConflict{id: $id, type: $type, itemId: $itemId, isResolved: $isResolved}';
  }
}

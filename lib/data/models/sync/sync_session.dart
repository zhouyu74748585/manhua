import 'package:json_annotation/json_annotation.dart';

part 'sync_session.g.dart';

/// Sync session status
enum SyncStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('conflicted')
  conflicted,
  @JsonValue('partially_completed')
  partiallyCompleted,
}

/// Sync operation type
enum SyncType {
  @JsonValue('library_full')
  libraryFull,
  @JsonValue('library_partial')
  libraryPartial,
  @JsonValue('reading_progress')
  readingProgress,
  @JsonValue('metadata_only')
  metadataOnly,
  @JsonValue('library')
  library,
}

/// Sync direction
enum SyncDirection {
  @JsonValue('upload')
  upload,
  @JsonValue('download')
  download,
  @JsonValue('bidirectional')
  bidirectional,
  @JsonValue('from_remote')
  fromRemote,
  @JsonValue('to_remote')
  toRemote,
}

/// Sync session information
@JsonSerializable()
class SyncSession {
  final String id;
  final String sourceDeviceId;
  final String targetDeviceId;
  final SyncType type;
  final SyncDirection direction;
  final SyncStatus status;
  final List<String> libraryIds; // Libraries to sync
  final DateTime startTime;
  final DateTime? endTime;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final String? currentItem;
  final List<String> errors;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const SyncSession({
    required this.id,
    required this.sourceDeviceId,
    required this.targetDeviceId,
    required this.type,
    required this.direction,
    required this.status,
    required this.libraryIds,
    required this.startTime,
    this.endTime,
    this.totalItems = 0,
    this.processedItems = 0,
    this.failedItems = 0,
    this.currentItem,
    this.errors = const [],
    this.errorMessage,
    this.metadata = const {},
  });

  factory SyncSession.fromJson(Map<String, dynamic> json) =>
      _$SyncSessionFromJson(json);
  Map<String, dynamic> toJson() => _$SyncSessionToJson(this);

  SyncSession copyWith({
    String? id,
    String? sourceDeviceId,
    String? targetDeviceId,
    SyncType? type,
    SyncDirection? direction,
    SyncStatus? status,
    List<String>? libraryIds,
    DateTime? startTime,
    DateTime? endTime,
    int? totalItems,
    int? processedItems,
    int? failedItems,
    String? currentItem,
    List<String>? errors,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return SyncSession(
      id: id ?? this.id,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      libraryIds: libraryIds ?? this.libraryIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      failedItems: failedItems ?? this.failedItems,
      currentItem: currentItem ?? this.currentItem,
      errors: errors ?? this.errors,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calculate sync progress percentage
  double get progressPercentage {
    if (totalItems == 0) return 0.0;
    return (processedItems / totalItems) * 100.0;
  }

  /// Check if sync is active
  bool get isActive {
    return status == SyncStatus.pending || status == SyncStatus.inProgress;
  }

  /// Check if sync is completed successfully
  bool get isCompleted {
    return status == SyncStatus.completed;
  }

  /// Check if sync has failed
  bool get hasFailed {
    return status == SyncStatus.failed;
  }

  @override
  String toString() {
    return 'SyncSession{id: $id, type: $type, status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%}';
  }
}

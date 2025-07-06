// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncSession _$SyncSessionFromJson(Map<String, dynamic> json) => SyncSession(
      id: json['id'] as String,
      sourceDeviceId: json['sourceDeviceId'] as String,
      targetDeviceId: json['targetDeviceId'] as String,
      type: $enumDecode(_$SyncTypeEnumMap, json['type']),
      direction: $enumDecode(_$SyncDirectionEnumMap, json['direction']),
      status: $enumDecode(_$SyncStatusEnumMap, json['status']),
      libraryIds: (json['libraryIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      processedItems: (json['processedItems'] as num?)?.toInt() ?? 0,
      failedItems: (json['failedItems'] as num?)?.toInt() ?? 0,
      currentItem: json['currentItem'] as String?,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SyncSessionToJson(SyncSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceDeviceId': instance.sourceDeviceId,
      'targetDeviceId': instance.targetDeviceId,
      'type': _$SyncTypeEnumMap[instance.type]!,
      'direction': _$SyncDirectionEnumMap[instance.direction]!,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'libraryIds': instance.libraryIds,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'totalItems': instance.totalItems,
      'processedItems': instance.processedItems,
      'failedItems': instance.failedItems,
      'currentItem': instance.currentItem,
      'errors': instance.errors,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$SyncTypeEnumMap = {
  SyncType.libraryFull: 'library_full',
  SyncType.libraryPartial: 'library_partial',
  SyncType.readingProgress: 'reading_progress',
  SyncType.metadataOnly: 'metadata_only',
  SyncType.library: 'library',
};

const _$SyncDirectionEnumMap = {
  SyncDirection.upload: 'upload',
  SyncDirection.download: 'download',
  SyncDirection.bidirectional: 'bidirectional',
  SyncDirection.fromRemote: 'from_remote',
  SyncDirection.toRemote: 'to_remote',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.inProgress: 'in_progress',
  SyncStatus.completed: 'completed',
  SyncStatus.failed: 'failed',
  SyncStatus.cancelled: 'cancelled',
  SyncStatus.conflicted: 'conflicted',
  SyncStatus.partiallyCompleted: 'partially_completed',
};

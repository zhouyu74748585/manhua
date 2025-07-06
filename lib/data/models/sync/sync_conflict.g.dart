// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_conflict.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncConflict _$SyncConflictFromJson(Map<String, dynamic> json) => SyncConflict(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      type: $enumDecode(_$ConflictTypeEnumMap, json['type']),
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      sourceDeviceId: json['sourceDeviceId'] as String,
      targetDeviceId: json['targetDeviceId'] as String,
      sourceData: json['sourceData'] as Map<String, dynamic>,
      targetData: json['targetData'] as Map<String, dynamic>,
      sourceTimestamp: DateTime.parse(json['sourceTimestamp'] as String),
      targetTimestamp: DateTime.parse(json['targetTimestamp'] as String),
      resolution: $enumDecode(_$ConflictResolutionEnumMap, json['resolution']),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolvedData: json['resolvedData'] as Map<String, dynamic>? ?? const {},
      isResolved: json['isResolved'] as bool? ?? false,
    );

Map<String, dynamic> _$SyncConflictToJson(SyncConflict instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'type': _$ConflictTypeEnumMap[instance.type]!,
      'itemId': instance.itemId,
      'itemType': instance.itemType,
      'sourceDeviceId': instance.sourceDeviceId,
      'targetDeviceId': instance.targetDeviceId,
      'sourceData': instance.sourceData,
      'targetData': instance.targetData,
      'sourceTimestamp': instance.sourceTimestamp.toIso8601String(),
      'targetTimestamp': instance.targetTimestamp.toIso8601String(),
      'resolution': _$ConflictResolutionEnumMap[instance.resolution]!,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolvedData': instance.resolvedData,
      'isResolved': instance.isResolved,
    };

const _$ConflictTypeEnumMap = {
  ConflictType.readingProgress: 'reading_progress',
  ConflictType.libraryMetadata: 'library_metadata',
  ConflictType.mangaMetadata: 'manga_metadata',
  ConflictType.duplicateId: 'duplicate_id',
  ConflictType.library: 'library',
  ConflictType.manga: 'manga',
};

const _$ConflictResolutionEnumMap = {
  ConflictResolution.latestWins: 'latest_wins',
  ConflictResolution.manual: 'manual',
  ConflictResolution.sourceWins: 'source_wins',
  ConflictResolution.targetWins: 'target_wins',
  ConflictResolution.useSource: 'use_source',
  ConflictResolution.useTarget: 'use_target',
  ConflictResolution.useLatest: 'use_latest',
  ConflictResolution.merge: 'merge',
};

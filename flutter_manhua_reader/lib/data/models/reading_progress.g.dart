// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingProgress _$ReadingProgressFromJson(Map<String, dynamic> json) =>
    ReadingProgress(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReadingProgressToJson(ReadingProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'progressPercentage': instance.progressPercentage,
      'lastReadAt': instance.lastReadAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manga _$MangaFromJson(Map<String, dynamic> json) => Manga(
      id: json['id'] as String,
      title: json['title'] as String,
      libraryId: json['libraryId'] as String,
      path: json['path'] as String,
      type: $enumDecode(_$MangaTypeEnumMap, json['type']),
      totalPages: (json['totalPages'] as num).toInt(),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      subtitle: json['subtitle'] as String?,
      author: json['author'] as String?,
      description: json['description'] as String?,
      coverPath: json['coverPath'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      status: $enumDecodeNullable(_$MangaStatusEnumMap, json['status']) ??
          MangaStatus.unknown,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastReadAt: json['lastReadAt'] == null
          ? null
          : DateTime.parse(json['lastReadAt'] as String),
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      source: json['source'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MangaToJson(Manga instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'author': instance.author,
      'description': instance.description,
      'coverPath': instance.coverPath,
      'libraryId': instance.libraryId,
      'path': instance.path,
      'fileSize': instance.fileSize,
      'tags': instance.tags,
      'status': _$MangaStatusEnumMap[instance.status]!,
      'type': _$MangaTypeEnumMap[instance.type]!,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastReadAt': instance.lastReadAt?.toIso8601String(),
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'rating': instance.rating,
      'source': instance.source,
      'sourceUrl': instance.sourceUrl,
      'isFavorite': instance.isFavorite,
      'isCompleted': instance.isCompleted,
      'metadata': instance.metadata,
    };

const _$MangaTypeEnumMap = {
  MangaType.folder: 'folder',
  MangaType.archive: 'archive',
  MangaType.pdf: 'pdf',
  MangaType.online: 'online',
};

const _$MangaStatusEnumMap = {
  MangaStatus.ongoing: 'ongoing',
  MangaStatus.completed: 'completed',
  MangaStatus.hiatus: 'hiatus',
  MangaStatus.cancelled: 'cancelled',
  MangaStatus.unknown: 'unknown',
};

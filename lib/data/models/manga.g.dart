// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaAdapter extends TypeAdapter<Manga> {
  @override
  final int typeId = 2;

  @override
  Manga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Manga(
      id: fields[0] as String,
      title: fields[1] as String,
      libraryId: fields[6] as String,
      path: fields[7] as String,
      type: fields[11] as MangaType,
      totalPages: fields[15] as int,
      fileSize: fields[8] as int?,
      subtitle: fields[2] as String?,
      author: fields[3] as String?,
      description: fields[4] as String?,
      coverPath: fields[5] as String?,
      tags: (fields[9] as List).cast<String>(),
      status: fields[10] as MangaStatus,
      updatedAt: fields[12] as DateTime?,
      createdAt: fields[13] as DateTime?,
      lastReadAt: fields[14] as DateTime?,
      currentPage: fields[16] as int,
      rating: fields[17] as double?,
      source: fields[18] as String?,
      sourceUrl: fields[19] as String?,
      isFavorite: fields[20] as bool,
      isCompleted: fields[21] as bool,
      metadata: (fields[22] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Manga obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.coverPath)
      ..writeByte(6)
      ..write(obj.libraryId)
      ..writeByte(7)
      ..write(obj.path)
      ..writeByte(8)
      ..write(obj.fileSize)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.type)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.lastReadAt)
      ..writeByte(15)
      ..write(obj.totalPages)
      ..writeByte(16)
      ..write(obj.currentPage)
      ..writeByte(17)
      ..write(obj.rating)
      ..writeByte(18)
      ..write(obj.source)
      ..writeByte(19)
      ..write(obj.sourceUrl)
      ..writeByte(20)
      ..write(obj.isFavorite)
      ..writeByte(21)
      ..write(obj.isCompleted)
      ..writeByte(22)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MangaTypeAdapter extends TypeAdapter<MangaType> {
  @override
  final int typeId = 1;

  @override
  MangaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaType.folder;
      case 1:
        return MangaType.archive;
      case 2:
        return MangaType.pdf;
      case 3:
        return MangaType.online;
      default:
        return MangaType.folder;
    }
  }

  @override
  void write(BinaryWriter writer, MangaType obj) {
    switch (obj) {
      case MangaType.folder:
        writer.writeByte(0);
        break;
      case MangaType.archive:
        writer.writeByte(1);
        break;
      case MangaType.pdf:
        writer.writeByte(2);
        break;
      case MangaType.online:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MangaStatusAdapter extends TypeAdapter<MangaStatus> {
  @override
  final int typeId = 3;

  @override
  MangaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaStatus.ongoing;
      case 1:
        return MangaStatus.completed;
      case 2:
        return MangaStatus.hiatus;
      case 3:
        return MangaStatus.cancelled;
      case 4:
        return MangaStatus.unknown;
      default:
        return MangaStatus.ongoing;
    }
  }

  @override
  void write(BinaryWriter writer, MangaStatus obj) {
    switch (obj) {
      case MangaStatus.ongoing:
        writer.writeByte(0);
        break;
      case MangaStatus.completed:
        writer.writeByte(1);
        break;
      case MangaStatus.hiatus:
        writer.writeByte(2);
        break;
      case MangaStatus.cancelled:
        writer.writeByte(3);
        break;
      case MangaStatus.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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

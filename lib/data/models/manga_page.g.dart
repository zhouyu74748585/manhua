// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaPageAdapter extends TypeAdapter<MangaPage> {
  @override
  final int typeId = 9;

  @override
  MangaPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MangaPage(
      id: fields[0] as String,
      mangaId: fields[1] as String,
      pageIndex: fields[2] as int,
      localPath: fields[3] as String,
      largeThumbnail: fields[4] as String?,
      mediumThumbnail: fields[5] as String?,
      smallThumbnail: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MangaPage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mangaId)
      ..writeByte(2)
      ..write(obj._pageIndex)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.largeThumbnail)
      ..writeByte(5)
      ..write(obj.mediumThumbnail)
      ..writeByte(6)
      ..write(obj.smallThumbnail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaPage _$MangaPageFromJson(Map<String, dynamic> json) => MangaPage(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      pageIndex: (json['pageIndex'] as num).toInt(),
      localPath: json['localPath'] as String,
      largeThumbnail: json['largeThumbnail'] as String?,
      mediumThumbnail: json['mediumThumbnail'] as String?,
      smallThumbnail: json['smallThumbnail'] as String?,
    );

Map<String, dynamic> _$MangaPageToJson(MangaPage instance) => <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'localPath': instance.localPath,
      'largeThumbnail': instance.largeThumbnail,
      'mediumThumbnail': instance.mediumThumbnail,
      'smallThumbnail': instance.smallThumbnail,
      'pageIndex': instance.pageIndex,
    };

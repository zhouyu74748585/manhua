// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page.dart';

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
      'pageIndex': instance.pageIndex,
      'localPath': instance.localPath,
      'largeThumbnail': instance.largeThumbnail,
      'mediumThumbnail': instance.mediumThumbnail,
      'smallThumbnail': instance.smallThumbnail,
    };

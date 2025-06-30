// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaPage _$MangaPageFromJson(Map<String, dynamic> json) => MangaPage(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      imagePath: json['imagePath'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$MangaPageToJson(MangaPage instance) => <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'pageNumber': instance.pageNumber,
      'imagePath': instance.imagePath,
      'imageUrl': instance.imageUrl,
    };

import 'package:json_annotation/json_annotation.dart';

part 'manga_page.g.dart';

@JsonSerializable()
class MangaPage {
  final String id;
  final String mangaId;
  final int pageNumber;
  final String localPath;
  final String? largeThumbnail;
  final String? mediumThumbnail;
  final String? smallThumbnail;

  const MangaPage({
    required this.id,
    required this.mangaId,
    required this.pageNumber,
    required this.localPath,
    this.largeThumbnail,
    this.mediumThumbnail,
    this.smallThumbnail,
  });

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);
  Map<String, dynamic> toJson() => _$MangaPageToJson(this);

  // 从数据库Map创建MangaPage对象
  factory MangaPage.fromMap(Map<String, dynamic> map) {
    return MangaPage(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      pageNumber: map['page_index'] as int,
      localPath: map['local_path'] as String,
      largeThumbnail: map['large_thumbnail'] as String?,
      mediumThumbnail: map['medium_thumbnail'] as String?,
      smallThumbnail: map['small_thumbnail'] as String?,
    );
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'page_index': pageNumber,
      'local_path': localPath,
      'large_thumbnail': largeThumbnail,
      'medium_thumbnail': mediumThumbnail,
      'small_thumbnail': smallThumbnail,
    };
  }

  MangaPage copyWith({
    String? id,
    String? mangaId,
    int? pageNumber,
    String? localPath,
    String? largeThumbnail,
    String? mediumThumbnail,
    String? smallThumbnail,
  }) {
    return MangaPage(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      pageNumber: pageNumber ?? this.pageNumber,
      localPath: localPath ?? this.localPath,
      largeThumbnail: largeThumbnail ?? this.largeThumbnail,
      mediumThumbnail: mediumThumbnail ?? this.mediumThumbnail,
      smallThumbnail: smallThumbnail ?? this.smallThumbnail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MangaPage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MangaPage(id: $id, pageNumber: $pageNumber, localPath: $localPath)';
  }
}

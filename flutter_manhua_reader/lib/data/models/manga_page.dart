import 'package:json_annotation/json_annotation.dart';

part 'manga_page.g.dart';

@JsonSerializable()
class MangaPage {
  final String id;
  final String mangaId;
  final int pageNumber;
  final String imagePath;
  final String? imageUrl;

  const MangaPage({
    required this.id,
    required this.mangaId,
    required this.pageNumber,
    required this.imagePath,
    this.imageUrl,
  });

  factory MangaPage.fromJson(Map<String, dynamic> json) => _$MangaPageFromJson(json);
  Map<String, dynamic> toJson() => _$MangaPageToJson(this);

  // 从数据库Map创建MangaPage对象
  factory MangaPage.fromMap(Map<String, dynamic> map) {
    return MangaPage(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      pageNumber: map['page_index'] as int,
      imagePath: map['image_path'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'page_index': pageNumber,
      'local_path': imagePath,
      'image_url': imageUrl,
    };
  }

  MangaPage copyWith({
    String? id,
     String? mangaId,
    int? pageNumber,
    String? imagePath,
    String? imageUrl,
  }) {
    return MangaPage(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      pageNumber: pageNumber ?? this.pageNumber,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
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
    return 'MangaPage(id: $id, pageNumber: $pageNumber, imagePath: $imagePath)';
  }
}
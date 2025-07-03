import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'manga_page.g.dart';

@JsonSerializable()
@HiveType(typeId: 9)
class MangaPage {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String mangaId;
  @HiveField(2)
  final int _pageIndex;
  @HiveField(3)
  final String localPath;
  @HiveField(4)
  final String? largeThumbnail;
  @HiveField(5)
  final String? mediumThumbnail;
  @HiveField(6)
  final String? smallThumbnail;

  MangaPage({
    required this.id,
    required this.mangaId,
    required int pageIndex,
    required this.localPath,
    this.largeThumbnail,
    this.mediumThumbnail,
    this.smallThumbnail,
  }) : _pageIndex = pageIndex;

  // Getter
  int get pageIndex => _pageIndex;

  factory MangaPage.fromJson(Map<String, dynamic> json) =>
      _$MangaPageFromJson(json);

  Map<String, dynamic> toJson() => _$MangaPageToJson(this);

  // 从数据库Map创建MangaPage对象
  factory MangaPage.fromMap(Map<String, dynamic> map) {
    return MangaPage(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      pageIndex: map['page_index'] as int, // 使用命名参数调用构造函数
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
      'page_index': pageIndex, // 使用getter
      'local_path': localPath,
      'large_thumbnail': largeThumbnail,
      'medium_thumbnail': mediumThumbnail,
      'small_thumbnail': smallThumbnail,
    };
  }

  MangaPage copyWith({
    String? id,
    String? mangaId,
    int? pageIndex, // 保持copyWith参数不变
    String? localPath,
    String? largeThumbnail,
    String? mediumThumbnail,
    String? smallThumbnail,
  }) {
    return MangaPage(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      pageIndex: pageIndex ?? this.pageIndex, // 使用getter
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
    return 'MangaPage(id: $id, pageIndex: $pageIndex, localPath: $localPath)';
  }
}

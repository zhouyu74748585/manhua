import 'package:json_annotation/json_annotation.dart';

part 'manga_page.g.dart';

@JsonSerializable()
class MangaPage {
  final String id;
  final String mangaId;
  int _pageIndex; // 移除final并改为私有变量
  final String localPath;
  final String? largeThumbnail;
  final String? mediumThumbnail;
  final String? smallThumbnail;

  MangaPage({
    required this.id,
    required this.mangaId,
    required int pageIndex, // 构造函数参数保持不变
    required this.localPath,
    this.largeThumbnail,
    this.mediumThumbnail,
    this.smallThumbnail,
  }) : _pageIndex = pageIndex; // 初始化私有变量

  // Getter
  int get pageIndex => _pageIndex;

  // Setter - 控制页码更新并添加验证
  set pageIndex(int value) {
    if (value < 0) {
      throw ArgumentError('页码不能为负数');
    }
    _pageIndex = value;
  }

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

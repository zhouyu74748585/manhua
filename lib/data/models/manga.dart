import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'reading_progress.dart';

part 'manga.g.dart';

@HiveType(typeId: 1)
enum MangaType {
  @HiveField(0)
  @JsonValue('folder')
  folder,
  @HiveField(1)
  @JsonValue('archive')
  archive,
  @HiveField(2)
  @JsonValue('pdf')
  pdf,
  @HiveField(3)
  @JsonValue('online')
  online,
}

extension MangaTypeExtension on MangaType {
  String get displayName {
    switch (this) {
      case MangaType.folder:
        return '文件夹';
      case MangaType.archive:
        return '压缩包';
      case MangaType.pdf:
        return 'PDF文档';
      case MangaType.online:
        return '在线漫画';
    }
  }
}

@JsonSerializable()
@HiveType(typeId: 2)
class Manga {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? subtitle;
  @HiveField(3)
  final String? author;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final String? coverPath; // 本地封面路径
  @HiveField(6)
  final String libraryId; // 所属漫画库ID
  @HiveField(7)
  final String path; // 文件或文件夹路径
  @HiveField(8)
  final int? fileSize; // 文件大小
  @HiveField(9)
  final List<String> tags;
  @HiveField(10)
  final MangaStatus status;
  @HiveField(11)
  final MangaType type; // 漫画类型
  @HiveField(12)
  final DateTime? updatedAt;
  @HiveField(13)
  final DateTime? createdAt;
  @HiveField(14)
  final DateTime? lastReadAt; // 最后阅读时间
  @HiveField(15)
  final int totalPages; // 总页数
  @HiveField(16)
  final int currentPage; // 当前页数
  @HiveField(17)
  final double? rating;
  @HiveField(18)
  final String? source;
  @HiveField(19)
  final String? sourceUrl;
  @HiveField(20)
  final bool isFavorite;
  @HiveField(21)
  final bool isCompleted; // 是否已读完
  @HiveField(22)
  final Map<String, dynamic> metadata; // 元数据

  const Manga({
    required this.id,
    required this.title,
    required this.libraryId,
    required this.path,
    required this.type,
    required this.totalPages,
    this.fileSize, // 文件大小
    this.subtitle,
    this.author,
    this.description,
    this.coverPath,
    this.tags = const [],
    this.status = MangaStatus.unknown,
    this.updatedAt,
    this.createdAt,
    this.lastReadAt,
    this.currentPage = 0,
    this.rating,
    this.source,
    this.sourceUrl,
    this.isFavorite = false,
    this.isCompleted = false,
    this.metadata = const {},
  });

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
  Map<String, dynamic> toJson() => _$MangaToJson(this);

  Manga copyWith({
    String? id,
    String? title,
    String? libraryId,
    String? path,
    MangaType? type,
    String? subtitle,
    String? author,
    String? description,
    String? coverPath,
    List<String>? tags,
    MangaStatus? status,
    DateTime? updatedAt,
    DateTime? createdAt,
    DateTime? lastReadAt,
    int? fileSize,
    int? totalPages,
    int? currentPage,
    double? rating,
    String? source,
    String? sourceUrl,
    bool? isFavorite,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
    ReadingProgress? readingProgress,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      libraryId: libraryId ?? this.libraryId,
      path: path ?? this.path,
      type: type ?? this.type,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      fileSize: fileSize ?? this.fileSize,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Manga && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 3)
enum MangaStatus {
  @HiveField(0)
  ongoing,
  @HiveField(1)
  completed,
  @HiveField(2)
  hiatus,
  @HiveField(3)
  cancelled,
  @HiveField(4)
  unknown,
}

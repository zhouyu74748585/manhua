import 'package:json_annotation/json_annotation.dart';
import 'reading_progress.dart';

part 'manga.g.dart';

enum MangaType {
  @JsonValue('folder')
  folder,
  @JsonValue('archive')
  archive,
  @JsonValue('pdf')
  pdf,
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
class Manga {
  final String id;
  final String title;
  final String? subtitle;
  final String? author;
  final String? description;
  final String? coverPath; // 本地封面路径
  final String libraryId; // 所属漫画库ID
  final String path; // 文件或文件夹路径
  final int? fileSize; // 文件大小
  final List<String> tags;
  final MangaStatus status;
  final MangaType type; // 漫画类型
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? lastReadAt; // 最后阅读时间
  final int totalPages; // 总页数
  final int currentPage; // 当前页数
  final double? rating;
  final String? source;
  final String? sourceUrl;
  final bool isFavorite;
  final bool isCompleted; // 是否已读完
  final Map<String, dynamic> metadata; // 元数据
  final ReadingProgress? readingProgress;

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
    this.readingProgress,
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
      readingProgress: readingProgress ?? this.readingProgress,
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

enum MangaStatus {
  ongoing,
  completed,
  hiatus,
  cancelled,
  unknown,
}

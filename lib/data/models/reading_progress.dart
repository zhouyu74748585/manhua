import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'reading_progress.g.dart';

@JsonSerializable()
@HiveType(typeId: 8)
class ReadingProgress {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String mangaId;
  @HiveField(2)
  final String libraryId; // 所属漫画库ID
  @HiveField(3)
  final int currentPage;
  @HiveField(4)
  final int totalPages;
  @HiveField(5)
  final double progressPercentage;
  @HiveField(6)
  final DateTime lastReadAt;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime updatedAt;

  const ReadingProgress({
    required this.id,
    required this.mangaId,
    required this.libraryId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingProgressToJson(this);

  // 从数据库Map创建ReadingProgress对象
  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      libraryId: map['library_id'] as String,
      currentPage: map['current_page'] as int,
      totalPages: map['total_pages'] as int,
      progressPercentage: (map['progress_percentage'] as num).toDouble(),
      lastReadAt: DateTime.parse(map['last_read_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'manga_id': mangaId,
      'current_page': currentPage,
      'total_pages': totalPages,
      'progress_percentage': progressPercentage,
      'last_read_at': lastReadAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReadingProgress copyWith({
    String? id,
    String? mangaId,
    String? libraryId,
    int? currentPage,
    int? totalPages,
    double? progressPercentage,
    DateTime? lastReadAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      libraryId: libraryId ?? this.libraryId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // 判断是否已完成阅读
  bool get isCompleted => progressPercentage >= 1.0;

  @override
  String toString() {
    return 'ReadingProgress(id: $id, mangaId: $mangaId, currentPage: $currentPage, progressPercentage: $progressPercentage)';
  }
}

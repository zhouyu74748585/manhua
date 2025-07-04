import 'dart:developer';

import '../models/manga.dart';
import '../models/reading_progress.dart';
import 'drift_database_service.dart';

class ReadingProgressService {
  /// 为漫画创建初始化的阅读进度
  static Future<ReadingProgress> createInitialProgress(
      Manga manga, int totalPages) async {
    // 如果没有页面，设置总页数为1（避免除零错误）
    if (totalPages == 0) {
      totalPages = 1;
    }

    final now = DateTime.now();
    final progressId = 'progress_${manga.id}_${now.millisecondsSinceEpoch}';

    final progress = ReadingProgress(
      id: progressId,
      mangaId: manga.id,
      libraryId: manga.libraryId,
      currentPage: 1,
      totalPages: totalPages,
      progressPercentage: 0.0,
      lastReadAt: now,
      createdAt: now,
      updatedAt: now,
    );

    return progress;
  }

  /// 为单体漫画文件创建初始化的阅读进度
  static Future<ReadingProgress> createInitialProgressForSingleFile(
      Manga manga, int pageCount) async {
    final now = DateTime.now();
    final progressId = 'progress_${manga.id}_${now.millisecondsSinceEpoch}';

    final progress = ReadingProgress(
      id: progressId,
      mangaId: manga.id,
      libraryId: manga.libraryId,
      currentPage: 0,
      totalPages: pageCount > 0 ? pageCount : 1,
      progressPercentage: 0.0,
      lastReadAt: now,
      createdAt: now,
      updatedAt: now,
    );

    return progress;
  }

  /// 更新阅读进度
  static Future<ReadingProgress> updateProgress({
    required ReadingProgress currentProgress,
    int? currentPage,
  }) async {
    final now = DateTime.now();

    // 计算新的进度百分比
    double newProgressPercentage = currentProgress.progressPercentage;
    if (currentPage != null && currentProgress.totalPages > 0) {
      newProgressPercentage = currentPage / currentProgress.totalPages;
      // 确保进度不超过100%
      if (newProgressPercentage > 1.0) {
        newProgressPercentage = 1.0;
      }
    }

    final updatedProgress = currentProgress.copyWith(
      currentPage: currentPage ?? currentProgress.currentPage,
      progressPercentage: newProgressPercentage,
      lastReadAt: now,
      updatedAt: now,
    );

    return updatedProgress;
  }

  /// 标记为已完成
  static Future<ReadingProgress> markAsCompleted(
      ReadingProgress currentProgress) async {
    final now = DateTime.now();

    final completedProgress = currentProgress.copyWith(
      currentPage: currentProgress.totalPages,
      progressPercentage: 1.0,
      lastReadAt: now,
      updatedAt: now,
    );

    return completedProgress;
  }

  /// 重置阅读进度
  static Future<ReadingProgress> resetProgress(
      ReadingProgress currentProgress) async {
    final now = DateTime.now();

    final resetProgress = currentProgress.copyWith(
      currentPage: 1,
      progressPercentage: 0.0,
      lastReadAt: now,
      updatedAt: now,
    );

    return resetProgress;
  }

  /// 保存阅读进度到数据库
  static Future<void> saveProgress(ReadingProgress progress) async {
    try {
      await DriftDatabaseService.insertOrUpdateReadingProgress(progress);
    } catch (e, stackTrace) {
      log('保存阅读进度失败: ${progress.id}, 错误: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  /// 从数据库获取阅读进度
  static Future<ReadingProgress?> getProgress(String mangaId) async {
    try {
      return await DriftDatabaseService.getReadingProgressByMangaId(mangaId);
    } catch (e, stackTrace) {
      log('获取阅读进度失败: $mangaId, 错误: $e,堆栈:$stackTrace');
      return null;
    }
  }

  /// 删除阅读进度
  static Future<void> deleteProgress(String mangaId) async {
    try {
      await DriftDatabaseService.deleteReadingProgress(mangaId);
    } catch (e, stackTrace) {
      log('删除阅读进度失败: $mangaId, 错误: $e,堆栈:$stackTrace');
      rethrow;
    }
  }
}

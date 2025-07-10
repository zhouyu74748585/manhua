import 'dart:async';
import 'dart:developer';

import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/cover_isolate_service.dart';
import '../../core/services/task_tracker_service.dart';
import '../../data/models/manga.dart';
import '../../data/models/reading_progress.dart';
import '../../data/repositories/manga_repository.dart';

part 'manga_provider.g.dart';

// 漫画仓库提供者
final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return LocalMangaRepository();
});

// 所有漫画列表提供者
@riverpod
Future<List<Manga>> allManga(AllMangaRef ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getAllManga();
}

@riverpod
Future<Map<String, ReadingProgress>> allMangaProgress(
    AllMangaProgressRef ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  List<ReadingProgress> list = await repository.getAllMangaReadingProgress();
  Map<String, ReadingProgress> result = {};
  for (var element in list) {
    result[element.mangaId] = element;
  }
  return result;
}

// 收藏漫画列表提供者
@riverpod
Future<List<Manga>> favoriteManga(FavoriteMangaRef ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getFavoriteManga();
}

// 最近阅读漫画列表提供者
@riverpod
Future<List<Manga>> recentlyReadManga(RecentlyReadMangaRef ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getRecentlyReadManga();
}

// 最近更新漫画列表提供者
@riverpod
Future<List<Manga>> recentlyUpdatedManga(RecentlyUpdatedMangaRef ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getRecentlyUpdatedManga();
}

// 单个漫画详情提供者
@riverpod
Future<Manga?> mangaDetail(MangaDetailRef ref, String mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getMangaById(mangaId);
}

// 带回调的漫画详情提供者
@riverpod
Future<Manga?> mangaDetailWithCallback(
    MangaDetailWithCallbackRef ref, String mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);

  // 创建一个安全的回调函数
  void safeCallback() {
    // 使用scheduleMicrotask确保在安全的上下文中执行
    scheduleMicrotask(() {
      try {
        // 尝试刷新相关的provider
        ref.invalidate(mangaDetailProvider(mangaId));
        ref.invalidate(mangaPagesProvider(mangaId));
      } catch (e) {
        // 静默处理可能的错误（如provider已被销毁）
        // 这是正常情况，不需要记录错误
        log('刷新详情失败: $e');
      }
    });
  }

  // 创建分批处理回调函数
  void safeBatchCallback(List<MangaPage> batchPages) {
    scheduleMicrotask(() {
      try {
        // 刷新页面相关的provider
        ref.invalidate(mangaPagesProvider(mangaId));
      } catch (e) {
        // 静默处理可能的错误
        log('刷新页面失败: $e');
      }
    });
  }

  return repository.getMangaByIdWithCallback(
    mangaId,
    onThumbnailGenerated: safeCallback,
    onBatchProcessed: safeBatchCallback,
  );
}

@riverpod
Future<ReadingProgress?> mangaProgress(
    MangaProgressRef ref, String mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getReadingProgressById(mangaId);
}

@riverpod
Future<List<MangaPage>> mangaPages(MangaPagesRef ref, String mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getPageByMangaId(mangaId);
}

// 根据库ID获取漫画列表提供者
@riverpod
Future<List<Manga>> mangaByLibrary(
    MangaByLibraryRef ref, String libraryId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getMangaByLibraryId(libraryId);
}

// 搜索结果提供者
@riverpod
Future<List<Manga>> searchManga(SearchMangaRef ref, String query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(mangaRepositoryProvider);
  return repository.searchManga(query);
}

// 漫画操作提供者
@riverpod
class MangaActions extends _$MangaActions {
  @override
  void build() {}

  Future<void> toggleFavorite(String mangaId, bool isFavorite) async {
    final repository = ref.read(mangaRepositoryProvider);
    await repository.updateMangaFavoriteStatus(mangaId, isFavorite);

    // 刷新相关提供者
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(mangaDetailProvider(mangaId));
  }

  Future<void> updateReadingProgress(
      String mangaId, ReadingProgress progress) async {
    final repository = ref.read(mangaRepositoryProvider);
    await repository.updateReadingProgress(mangaId, progress);

    // 刷新相关提供者
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(mangaDetailProvider(mangaId));
  }

  Future<void> deleteManga(String mangaId) async {
    final repository = ref.read(mangaRepositoryProvider);
    await repository.deleteManga(mangaId);

    // 刷新所有相关提供者
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(recentlyUpdatedMangaProvider);
  }

  Future<void> refreshMangaData() async {
    // 刷新所有漫画相关数据
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(recentlyUpdatedMangaProvider);
  }

  /// 手动生成单个漫画的封面
  Future<void> generateCoverForManga(String mangaId) async {
    // 检查是否已有封面生成任务在运行
    if (TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId)) {
      throw TaskAlreadyRunningException(TaskType.coverGeneration, mangaId);
    }

    final repository = ref.read(mangaRepositoryProvider);
    final manga = await repository.getMangaById(mangaId);

    if (manga == null) {
      throw Exception('漫画不存在: $mangaId');
    }

    log('开始为漫画生成封面: ${manga.title}');

    // 使用任务包装器执行封面生成
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      mangaId,
      () async {
        await CoverIsolateService.generateCoversInIsolate(
          [manga],
          onComplete: (updatedManga) {
            log('封面生成完成: ${updatedManga.title}');
            // 刷新相关提供者
            ref.invalidate(mangaDetailProvider(mangaId));
            ref.invalidate(allMangaProvider);
          },
          onProgress: (current, total) {
            log('封面生成进度: $current/$total');
          },
        );
      },
    );
  }

  /// 批量生成多个漫画的封面
  Future<void> generateCoversForMangas(List<String> mangaIds) async {
    // 过滤掉已有封面生成任务的漫画
    final availableMangaIds = mangaIds
        .where((mangaId) => !TaskTrackerService.isTaskRunning(
            TaskType.coverGeneration, mangaId))
        .toList();

    if (availableMangaIds.isEmpty) {
      throw Exception('所有漫画都已有封面生成任务在运行');
    }

    if (availableMangaIds.length < mangaIds.length) {
      log('跳过 ${mangaIds.length - availableMangaIds.length} 个已在运行的封面生成任务');
    }

    final repository = ref.read(mangaRepositoryProvider);
    final List<Manga> mangas = [];

    // 获取所有可用的漫画对象
    for (final mangaId in availableMangaIds) {
      final manga = await repository.getMangaById(mangaId);
      if (manga != null) {
        mangas.add(manga);
      }
    }

    if (mangas.isEmpty) {
      throw Exception('没有找到有效的漫画');
    }

    log('开始批量生成封面，漫画数量: ${mangas.length}');

    // 为每个漫画标记任务开始
    final taskWrappers = <TaskWrapper>[];
    for (final manga in mangas) {
      final wrapper = TaskWrapper(TaskType.coverGeneration, manga.id);
      if (wrapper.tryStart()) {
        taskWrappers.add(wrapper);
      }
    }

    try {
      // 使用封面生成服务
      await CoverIsolateService.generateCoversInIsolate(
        mangas,
        onComplete: (updatedManga) {
          log('封面生成完成: ${updatedManga.title}');
          // 刷新相关提供者
          ref.invalidate(mangaDetailProvider(updatedManga.id));
        },
        onProgress: (current, total) {
          log('批量封面生成进度: $current/$total');
        },
      );

      // 标记所有任务完成
      for (final wrapper in taskWrappers) {
        wrapper.complete();
      }
    } catch (e) {
      // 出错时取消所有任务
      for (final wrapper in taskWrappers) {
        wrapper.cancel();
      }
      rethrow;
    }

    // 最后刷新所有相关数据
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(recentlyUpdatedMangaProvider);
  }

  /// 检查漫画是否有封面生成任务在运行
  bool isCoverGenerationRunning(String mangaId) {
    return TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId);
  }

  /// 检查漫画是否有缩略图生成任务在运行
  bool isThumbnailGenerationRunning(String mangaId) {
    return TaskTrackerService.isTaskRunning(
        TaskType.thumbnailGeneration, mangaId);
  }

  /// 获取漫画的所有运行中任务类型
  List<TaskType> getRunningTaskTypes(String mangaId) {
    return TaskTrackerService.getRunningTaskTypesForObject(mangaId);
  }

  /// 取消漫画的封面生成任务
  void cancelCoverGeneration(String mangaId) {
    TaskTrackerService.cancelTask(TaskType.coverGeneration, mangaId);
  }

  /// 取消漫画的缩略图生成任务
  void cancelThumbnailGeneration(String mangaId) {
    TaskTrackerService.cancelTask(TaskType.thumbnailGeneration, mangaId);
  }

  /// 获取任务统计信息
  Map<TaskType, int> getTaskStatistics() {
    return TaskTrackerService.getTaskStatistics();
  }
}

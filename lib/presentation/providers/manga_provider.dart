import 'dart:async';
import 'dart:developer';

import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
Future<List<Manga>> mangaByLibrary(MangaByLibraryRef ref, String libraryId) async {
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
}

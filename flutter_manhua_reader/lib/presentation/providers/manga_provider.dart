import 'package:flutter_riverpod/flutter_riverpod.dart';
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

@riverpod
Future<List<MangaPage>> mangaPages(MangaPagesRef ref, String mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return repository.getPageByMangaId(mangaId);
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

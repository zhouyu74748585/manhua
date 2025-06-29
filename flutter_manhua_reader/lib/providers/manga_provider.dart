import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/manga.dart';
import '../data/models/chapter.dart';
import '../data/models/reading_progress.dart';
import '../data/repositories/manga_repository.dart';
import '../data/services/database_service.dart';

// 数据库服务提供者
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// 漫画仓库提供者
final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return LocalMangaRepository(databaseService);
});

// 所有漫画列表提供者
final allMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getAllManga();
});

// 收藏漫画列表提供者
final favoriteMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getFavoriteManga();
});

// 最近阅读漫画列表提供者
final recentlyReadMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getRecentlyReadManga();
});

// 最近更新漫画列表提供者
final recentlyUpdatedMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getRecentlyUpdatedManga();
});

// 根据ID获取漫画提供者
final mangaByIdProvider = FutureProvider.family<Manga?, String>((ref, id) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getMangaById(id);
});

// 根据漫画ID获取章节列表提供者
final chaptersByMangaIdProvider = FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getChaptersByMangaId(mangaId);
});

// 搜索漫画提供者
final searchMangaProvider = FutureProvider.family<List<Manga>, String>((ref, query) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.searchManga(query);
});

// 按分类获取漫画提供者
final mangaByCategoryProvider = FutureProvider.family<List<Manga>, String>((ref, category) async {
  final repository = ref.watch(mangaRepositoryProvider);
  return await repository.getMangaByCategory(category);
});

// 漫画操作类
class MangaNotifier extends StateNotifier<AsyncValue<void>> {
  final MangaRepository _repository;
  final Ref _ref;

  MangaNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  // 保存漫画
  Future<void> saveManga(Manga manga) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveManga(manga);
      state = const AsyncValue.data(null);
      // 刷新相关提供者
      _ref.invalidate(allMangaProvider);
      _ref.invalidate(favoriteMangaProvider);
      _ref.invalidate(recentlyReadMangaProvider);
      _ref.invalidate(recentlyUpdatedMangaProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 删除漫画
  Future<void> deleteManga(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteManga(id);
      state = const AsyncValue.data(null);
      // 刷新相关提供者
      _ref.invalidate(allMangaProvider);
      _ref.invalidate(favoriteMangaProvider);
      _ref.invalidate(recentlyReadMangaProvider);
      _ref.invalidate(recentlyUpdatedMangaProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 更新收藏状态
  Future<void> updateFavoriteStatus(String id, bool isFavorite) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMangaFavoriteStatus(id, isFavorite);
      state = const AsyncValue.data(null);
      // 刷新相关提供者
      _ref.invalidate(allMangaProvider);
      _ref.invalidate(favoriteMangaProvider);
      _ref.invalidate(mangaByIdProvider(id));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 更新阅读进度
  Future<void> updateReadingProgress(String id, ReadingProgress progress) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateReadingProgress(id, progress);
      state = const AsyncValue.data(null);
      // 刷新相关提供者
      _ref.invalidate(allMangaProvider);
      _ref.invalidate(recentlyReadMangaProvider);
      _ref.invalidate(mangaByIdProvider(id));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 漫画操作提供者
final mangaNotifierProvider = StateNotifierProvider<MangaNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(mangaRepositoryProvider);
  return MangaNotifier(repository, ref);
});
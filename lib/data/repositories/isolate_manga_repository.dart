// ignore_for_file: override_on_non_overriding_member

import 'dart:developer';
import 'dart:ui';

import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/reading_progress.dart';
import '../services/drift_isolate_database_service.dart';
import 'manga_repository.dart';

/// Isolate-safe manga repository implementation
class IsolateMangaRepository implements MangaRepository {
  final DriftIsolateDatabaseService _databaseService;

  IsolateMangaRepository._internal(this._databaseService);

  static Future<IsolateMangaRepository> create() async {
    final databaseService = await DriftIsolateDatabaseService.create();
    return IsolateMangaRepository._internal(databaseService);
  }

  @override
  Future<List<Manga>> getAllManga() async {
    try {
      // For isolate, we'll implement a simplified version
      // that doesn't need to check library status
      log('IsolateMangaRepository: getAllManga not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询漫画失败: $e, 堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    try {
      log('IsolateMangaRepository: getAllMangaReadingProgress not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e, $stackTrace');
      return [];
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgressById(String id) async {
    try {
      log('IsolateMangaRepository: getReadingProgressById not implemented for isolates');
      return null;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e, $stackTrace');
      return null;
    }
  }

  @override
  Future<List<ReadingProgress>?> getReadingProgressByLibraryId(
      String libraryId) async {
    try {
      log('IsolateMangaRepository: getReadingProgressByLibraryId not implemented for isolates');
      return null;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e, $stackTrace');
      return null;
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      log('IsolateMangaRepository: saveReadingProgress not implemented for isolates');
    } catch (e, stackTrace) {
      log('保存漫画进度失败: $e, $stackTrace');
    }
  }

  @override
  Future<void> deleteReadingProgress(String mangaId) async {
    try {
      log('IsolateMangaRepository: deleteReadingProgress not implemented for isolates');
    } catch (e, stackTrace) {
      log('删除漫画进度失败: $e, $stackTrace');
    }
  }

  @override
  Future<List<Manga>> getFavoriteManga() async {
    try {
      log('IsolateMangaRepository: getFavoriteManga not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询收藏漫画失败: $e, $stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getRecentlyReadManga() async {
    try {
      log('IsolateMangaRepository: getRecentlyReadManga not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询最近阅读漫画失败: $e, $stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getRecentlyUpdatedManga() async {
    try {
      log('IsolateMangaRepository: getRecentlyUpdatedManga not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询最近更新漫画失败: $e, $stackTrace');
      return [];
    }
  }

  @override
  Future<void> saveManga(Manga manga) async {
    try {
      await _databaseService.insertManga(manga);
    } catch (e, stackTrace) {
      log('保存漫画失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<void> updateManga(Manga manga) async {
    try {
      await _databaseService.updateManga(manga);
    } catch (e, stackTrace) {
      log('更新漫画失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<void> deleteManga(String id) async {
    try {
      log('IsolateMangaRepository: deleteManga not implemented for isolates');
    } catch (e, stackTrace) {
      log('删除漫画失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<Manga?> getMangaById(String id) async {
    try {
      return await _databaseService.getMangaById(id);
    } catch (e, stackTrace) {
      log('查询漫画失败: $e, 堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<List<Manga>> getMangaByLibraryId(String libraryId) async {
    try {
      log('IsolateMangaRepository: getMangaByLibraryId not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('查询漫画失败: $e, 堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> searchManga(String query) async {
    try {
      log('IsolateMangaRepository: searchManga not implemented for isolates');
      return [];
    } catch (e, stackTrace) {
      log('搜索漫画失败: $e, 堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<MangaPage?> getPageById(String id) async {
    try {
      log('IsolateMangaRepository: getPageById not implemented for isolates');
      return null;
    } catch (e, stackTrace) {
      log('查询页面失败: $e, 堆栈: $stackTrace');
      return null;
    }
  }

  @override
  Future<List<MangaPage>> getPageByMangaId(String id) async {
    try {
      return await _databaseService.getPagesByMangaId(id);
    } catch (e, stackTrace) {
      log('查询页面失败: $e, 堆栈: $stackTrace');
      return [];
    }
  }

  @override
  Future<void> savePage(MangaPage page) async {
    try {
      await _databaseService.insertPage(page);
    } catch (e, stackTrace) {
      log('保存页面失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<void> updatePage(MangaPage page) async {
    try {
      await _databaseService.updatePage(page);
    } catch (e, stackTrace) {
      log('更新页面失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<void> deletePageByMangaId(String id) async {
    try {
      log('IsolateMangaRepository: deletePageByMangaId not implemented for isolates');
    } catch (e, stackTrace) {
      log('删除漫画页失败: $e, 堆栈: $stackTrace');
    }
  }

  @override
  Future<void> saveMangaList(List<Manga> mangaList) async {
    try {
      // Batch save to database
      for (final manga in mangaList) {
        await _databaseService.insertManga(manga);
      }
    } catch (e, stackTrace) {
      log('批量保存漫画失败: $e, 堆栈: $stackTrace');
      // If database operation fails, save individually
      await Future.delayed(const Duration(milliseconds: 200));
      for (final manga in mangaList) {
        await saveManga(manga);
      }
    }
  }

  @override
  Future<void> savePageList(List<MangaPage> pageList) async {
    try {
      await _databaseService.insertPageList(pageList);
    } catch (e, stackTrace) {
      log('批量保存页面失败: $e, 堆栈: $stackTrace');
      // Fallback to individual saves
      for (final page in pageList) {
        await savePage(page);
      }
    }
  }

  @override
  Future<void> updatePageList(List<MangaPage> pageList) async {
    try {
      await _databaseService.updatePageList(pageList);
    } catch (e, stackTrace) {
      log('批量更新页面失败: $e, 堆栈: $stackTrace');
      // Fallback to individual updates
      for (final page in pageList) {
        await updatePage(page);
      }
    }
  }

  /// Close database connection
  Future<void> close() async {
    await _databaseService.close();
  }

  @override
  Future<void> clearAllData() {
    // TODO: implement clearAllData
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProgressByMangaId(String id) {
    // TODO: implement deleteProgressByMangaId
    throw UnimplementedError();
  }

  @override
  Future<List<Manga>> getMangaByCategory(String category) {
    // TODO: implement getMangaByCategory
    throw UnimplementedError();
  }

  @override
  Future<Manga?> getMangaByIdWithCallback(String id,
      {VoidCallback? onThumbnailGenerated,
      Function(List<MangaPage> p1)? onBatchProcessed}) {
    // TODO: implement getMangaByIdWithCallback
    throw UnimplementedError();
  }

  @override
  Future<void> updateMangaFavoriteStatus(String id, bool isFavorite) {
    // TODO: implement updateMangaFavoriteStatus
    throw UnimplementedError();
  }

  @override
  Future<void> updateReadingProgress(String mangaId, ReadingProgress progress) {
    // TODO: implement updateReadingProgress
    throw UnimplementedError();
  }
}

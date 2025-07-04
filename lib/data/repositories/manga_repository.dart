import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:manhua_reader_flutter/core/services/thumbnail_isolate_service.dart';

import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/reading_progress.dart';
import '../services/drift_database_service.dart';

abstract class MangaRepository {
  // 漫画相关
  Future<List<Manga>> getAllManga();
  Future<Manga?> getMangaById(String id);
  Future<Manga?> getMangaByIdWithCallback(String id,
      {VoidCallback? onThumbnailGenerated,
      Function(List<MangaPage>)? onBatchProcessed});
  Future<ReadingProgress?> getReadingProgressById(String id);
  Future<List<ReadingProgress>> getAllMangaReadingProgress();
  Future<List<Manga>> searchManga(String query);
  Future<List<Manga>> getMangaByCategory(String category);
  Future<List<Manga>> getFavoriteManga();
  Future<List<Manga>> getRecentlyReadManga();
  Future<List<Manga>> getRecentlyUpdatedManga();
  Future<void> saveManga(Manga manga);
  Future<void> updateManga(Manga manga);
  Future<void> deleteManga(String id);
  Future<void> updateMangaFavoriteStatus(String id, bool isFavorite);
  Future<void> updateReadingProgress(String mangaId, ReadingProgress progress);
  Future<void> deleteProgressByMangaId(String id);

  // 页面相关
  Future<MangaPage?> getPageById(String id);
  Future<List<MangaPage>> getPageByMangaId(String id);
  Future<void> savePage(MangaPage page);
  Future<void> updatePage(MangaPage manga);
  Future<void> deletePageByMangaId(String id);

  // 批量操作
  Future<void> saveMangaList(List<Manga> mangaList);
  Future<void> savePageList(List<MangaPage> pageList);

  // 清理操作
  Future<void> clearCache();
  Future<void> clearAllData();
}

class LocalMangaRepository implements MangaRepository {
  @override
  Future<List<Manga>> getAllManga() async {
    try {
      final dbManga = await DriftDatabaseService.getAllManga();
      return dbManga;
    } catch (e, stackTrace) {
      log('查询漫画失败: $e,堆栈:$stackTrace');
      return List.empty();
    }
  }

  @override
  Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    try {
      final dbManga = await DriftDatabaseService.getAllMangaReadingProgress();
      return dbManga;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e,$stackTrace');
      return List.empty();
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgressById(String id) async {
    try {
      final dbManga =
          await DriftDatabaseService.getReadingProgressByMangaId(id);
      return dbManga;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e,$stackTrace');
      return null;
    }
  }

  @override
  Future<Manga?> getMangaById(String id) async {
    try {
      Manga? manga = await DriftDatabaseService.getMangaById(id);
      return manga;
    } catch (e, stackTrace) {
      log('查询漫画失败: $e,堆栈:$stackTrace');
      return null;
    }
  }

  @override
  Future<Manga?> getMangaByIdWithCallback(String id,
      {VoidCallback? onThumbnailGenerated,
      Function(List<MangaPage>)? onBatchProcessed}) async {
    try {
      Manga? manga = await DriftDatabaseService.getMangaById(id);
      if (manga != null) {
        bool hasThumbnail = false;
        String? thumbnailPath = manga.metadata['thumbnail'];
        if (thumbnailPath != null) {
          Directory directory = Directory(thumbnailPath);
          if (await directory.exists()) {
            hasThumbnail = true;
          }
        }
        if (!hasThumbnail) {
          generatePageAndThumbnails(manga,
              onComplete: onThumbnailGenerated,
              onBatchProcessed: onBatchProcessed);
        }
      }
      return manga;
    } catch (e, stackTrace) {
      log('查询漫画失败: $e,堆栈:$stackTrace');
      return null;
    }
  }

  Future<void> generatePageAndThumbnails(Manga manga,
      {VoidCallback? onComplete,
      Function(List<MangaPage>)? onBatchProcessed}) async {
    log('开始使用Isolate生成漫画[${manga.title}]的缩略图');

    // 使用Isolate处理缩略图生成
    await ThumbnailIsolateService.generateThumbnailsInIsolate(
      manga,
      onComplete: () {
        log('缩略图生成完成: ${manga.title}');
        if (onComplete != null) {
          try {
            // 使用Future.microtask确保回调在下一个事件循环中执行
            Future.microtask(() {
              onComplete();
            });
          } catch (e, stackTrace) {
            log('回调执行失败: $e,堆栈:$stackTrace');
          }
        }
      },
      onBatchProcessed: (batchPages) {
        log("生成[${manga.title}]的${batchPages.length}页的缩略图");
        // 触发外部回调
        if (onBatchProcessed != null) {
          onBatchProcessed(batchPages);
        }
      },
    );
  }

  @override
  Future<List<Manga>> searchManga(String query) async {
    return await DriftDatabaseService.searchManga(query);
  }

  @override
  Future<List<Manga>> getMangaByCategory(String category) async {
    return await DriftDatabaseService.getMangaByCategory(category);
  }

  @override
  Future<List<Manga>> getFavoriteManga() async {
    return await DriftDatabaseService.getFavoriteManga();
  }

  @override
  Future<List<Manga>> getRecentlyReadManga() async {
    return await DriftDatabaseService.getRecentlyReadManga();
  }

  @override
  Future<List<Manga>> getRecentlyUpdatedManga() async {
    return await DriftDatabaseService.getRecentlyUpdatedManga();
  }

  @override
  Future<void> saveManga(Manga manga) async {
    try {
      await DriftDatabaseService.insertManga(manga);
    } catch (e, stackTrace) {
      log('保存漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateManga(Manga manga) async {
    try {
      await DriftDatabaseService.updateManga(manga);
    } catch (e, stackTrace) {
      log('更新漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> deleteManga(String id) async {
    try {
      await DriftDatabaseService.deleteManga(id);
    } catch (e, stackTrace) {
      log('删除漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateMangaFavoriteStatus(String id, bool isFavorite) async {
    try {
      final manga = await DriftDatabaseService.getMangaById(id);
      if (manga != null) {
        final updatedManga = manga.copyWith(isFavorite: isFavorite);
        await DriftDatabaseService.updateManga(updatedManga);
      }
    } catch (e, stackTrace) {
      log('更新漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateReadingProgress(
      String mangaId, ReadingProgress progress) async {
    final manga = await getMangaById(mangaId);
    if (manga == null) return;

    final now = DateTime.now();
    await DriftDatabaseService.insertOrUpdateReadingProgress(progress);

    // 更新漫画的最后阅读时间
    await DriftDatabaseService.updateMangaLastReadAt(mangaId, now);
  }

  @override
  Future<void> deleteProgressByMangaId(String id) async {
    try {
      await DriftDatabaseService.deleteReadingProgress(id);
    } catch (e, stackTrace) {
      log('删除漫画进度失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<MangaPage?> getPageById(String id) async {
    return await DriftDatabaseService.getPageById(id);
  }

  @override
  Future<List<MangaPage>> getPageByMangaId(String id) async {
    return await DriftDatabaseService.getPagesByMangaId(id);
  }

  @override
  Future<void> savePage(MangaPage page) async {
    await DriftDatabaseService.insertPage(page);
  }

  @override
  Future<void> updatePage(MangaPage page) async {
    await DriftDatabaseService.updatePage(page);
  }

  @override
  Future<void> deletePageByMangaId(String id) async {
    try {
      await DriftDatabaseService.deletePagesByMangaId(id);
    } catch (e, stackTrace) {
      log('删除漫画页失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> saveMangaList(List<Manga> mangaList) async {
    try {
      await DriftDatabaseService.saveMangaList(mangaList);
    } catch (e, stackTrace) {
      log('批量保存漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> savePageList(List<MangaPage> pageList) async {
    try {
      await DriftDatabaseService.savePageList(pageList);
    } catch (e, stackTrace) {
      log('批量保存页面失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> clearCache() async {
    final db = DriftDatabaseService.database;
    // 清除页面缓存
    await db.delete(db.mangaPages).go();
    // 可以根据需要清除其他缓存数据
  }

  @override
  Future<void> clearAllData() async {
    await DriftDatabaseService.clearAllData();
  }
}

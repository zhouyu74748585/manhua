import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:manhua_reader_flutter/core/services/thumbnail_isolate_service.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/reading_progress.dart';
import '../services/database_service.dart';

abstract class MangaRepository {
  // 漫画相关
  Future<List<Manga>> getAllManga();
  Future<List<ReadingProgress>> getAllMangaReadingProgress();
  Future<Manga?> getMangaById(String id);
  Future<Manga?> getMangaByIdWithCallback(String id,
      {VoidCallback? onThumbnailGenerated,
      Function(List<MangaPage>)? onBatchProcessed});
  Future<ReadingProgress?> getReadingProgressById(String id);
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
      final dbManga = await DatabaseService.getAllManga();
      return dbManga;
    } catch (e,stackTrace) {
      log('查询漫画失败: $e,堆栈:$stackTrace');
      return List.empty();
    }
  }

  @override
  Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    try {
      final dbManga = await DatabaseService.getAllMangaReadingProgress();
      return dbManga;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e,$stackTrace');
      return List.empty();
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgressById(String id) async {
    try {
      final dbManga = await DatabaseService.getReadingProgressByMangaId(id);
      return dbManga;
    } catch (e, stackTrace) {
      log('查询漫画进度失败: $e,$stackTrace');
      return null;
    }
  }

  @override
  Future<Manga?> getMangaById(String id) async {
    try {
      Manga? manga = await DatabaseService.getMangaById(id);
      return manga;
    } catch (e,stackTrace) {
      log('查询漫画失败: $e,堆栈:$stackTrace');
      return null;
    }
  }

  @override
  Future<Manga?> getMangaByIdWithCallback(String id,
      {VoidCallback? onThumbnailGenerated,
      Function(List<MangaPage>)? onBatchProcessed}) async {
    try {
      Manga? manga = await DatabaseService.getMangaById(id);
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
    } catch (e,stackTrace) {
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
          } catch (e,stackTrace) {
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
    try {
      final allManga = await DatabaseService.getAllManga();
      return allManga.where((manga) => 
        manga.title.toLowerCase().contains(query.toLowerCase()) ||
        (manga.author?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (manga.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e, stackTrace) {
      log('搜索漫画失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getMangaByCategory(String category) async {
    try {
      final allManga = await DatabaseService.getAllManga();
      return allManga.where((manga) => 
        manga.tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()))
      ).toList();
    } catch (e, stackTrace) {
      log('按分类查询漫画失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getFavoriteManga() async {
    try {
      final allManga = await DatabaseService.getAllManga();
      return allManga.where((manga) => manga.isFavorite).toList();
    } catch (e, stackTrace) {
      log('查询收藏漫画失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getRecentlyReadManga() async {
    try {
      final allManga = await DatabaseService.getAllManga();
      final recentlyRead = allManga.where((manga) => manga.lastReadAt != null).toList();
      recentlyRead.sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!));
      return recentlyRead.take(20).toList();
    } catch (e, stackTrace) {
      log('查询最近阅读漫画失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<List<Manga>> getRecentlyUpdatedManga() async {
    try {
      final allManga = await DatabaseService.getAllManga();
      allManga.sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
      return allManga.take(20).toList();
    } catch (e, stackTrace) {
      log('查询最近更新漫画失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<void> saveManga(Manga manga) async {
    try {
      await DatabaseService.insertManga(manga);
    } catch (e,stackTrace) {
      log('保存漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateManga(Manga manga) async {
    try {
      await DatabaseService.updateManga(manga);
    } catch (e,stackTrace) {
      log('更新漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> deleteManga(String id) async {
    try {
      await DatabaseService.deleteManga(id);
    } catch (e,stackTrace) {
      log('删除漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateMangaFavoriteStatus(String id, bool isFavorite) async {
    try {
      final manga = await DatabaseService.getMangaById(id);
      if (manga != null) {
        final updatedManga = manga.copyWith(isFavorite: isFavorite);
        await DatabaseService.updateManga(updatedManga);
      }
    } catch (e,stackTrace) {
      log('更新漫画失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> updateReadingProgress(
      String mangaId, ReadingProgress progress) async {
        try{
        final manga = await getMangaById(mangaId);
            if (manga == null) return;

            final now = DateTime.now();
            await DatabaseService.insertOrUpdateReadingProgress(progress);

            // 更新漫画的最后阅读时间
            final updatedManga = manga.copyWith(lastReadAt: now);
            await DatabaseService.updateManga(updatedManga);
        }catch(e,stackTrace){
          log("更新漫画阅读进度失败:$e,堆栈:$stackTrace");
        }
    
  }

  @override
  Future<void> deleteProgressByMangaId(String id) async {
    try {
      await DatabaseService.deleteReadingProgress(id);
    } catch (e,stackTrace) {
      log('删除漫画进度失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<MangaPage?> getPageById(String id) async {
    try {
      return await DatabaseService.getPageById(id);
    } catch (e, stackTrace) {
      log('查询页面失败: $e,堆栈:$stackTrace');
      return null;
    }
  }

  @override
  Future<List<MangaPage>> getPageByMangaId(String id) async {
    try {
      return await DatabaseService.getPagesByMangaId(id);
    } catch (e, stackTrace) {
      log('查询漫画页面失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<void> savePage(MangaPage page) async {
    await DatabaseService.insertPage(page);
  }

  @override
  Future<void> updatePage(MangaPage page) async {
    await DatabaseService.updatePage(page);
  }

  @override
  Future<void> deletePageByMangaId(String id) async {
    try {
      await DatabaseService.deletePageByMangaId(id);
    } catch (e,stackTrace) {
      log('删除漫画页失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> saveMangaList(List<Manga> mangaList) async {
    try {
      // 批量保存到数据库
      for (final manga in mangaList) {
        await DatabaseService.insertManga(manga);
      }
    } catch (e,stackTrace) {
      // 如果数据库操作失败，逐个保存
      await Future.delayed(const Duration(milliseconds: 200));
      for (final manga in mangaList) {
        await saveManga(manga);
      }
    }
  }

  @override
  Future<void> savePageList(List<MangaPage> pageList) async {
    try {
      for (final page in pageList) {
        await DatabaseService.insertPage(page);
      }
    } catch (e, stackTrace) {
      log('批量保存页面失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // 清除页面缓存 - 这里可以根据需要实现具体的缓存清理逻辑
      log('清除缓存完成');
    } catch (e, stackTrace) {
      log('清除缓存失败: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
  }


}

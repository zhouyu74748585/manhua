import 'dart:developer';

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/reading_progress.dart';
import '../services/database_service.dart';

abstract class MangaRepository {
  // 漫画相关
  Future<List<Manga>> getAllManga();
  Future<Manga?> getMangaById(String id);
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
  
  // 页面相关
  Future<MangaPage?> getPageById(String id);
  Future<List<MangaPage>> getPageByMangaId(String id);
  Future<void> savePage(MangaPage page);
  Future<void> deletePage(String id);
  
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
    } catch (e) {
      log('查询漫画失败: $e');
      return List.empty();
    }
  }
  
  @override
  Future<Manga?> getMangaById(String id) async {
    try {
      return await DatabaseService.getMangaById(id);
    } catch (e) {
      log('查询漫画失败: $e');
      return null;
    }
  }
  
  @override
  Future<List<Manga>> searchManga(String query) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      where: 'title LIKE ? OR author LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    
    return maps.map((map) => _mapToManga(map)).toList();
  }
  
  @override
  Future<List<Manga>> getMangaByCategory(String category) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      where: 'tags LIKE ?',
      whereArgs: ['%$category%'],
      orderBy: 'title ASC',
    );
    
    return maps.map((map) => _mapToManga(map)).toList();
  }
  
  @override
  Future<List<Manga>> getFavoriteManga() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'title ASC',
    );
    
    return maps.map((map) => _mapToManga(map)).toList();
  }
  
  @override
  Future<List<Manga>> getRecentlyReadManga() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      where: 'last_read_at IS NOT NULL',
      orderBy: 'last_read_at DESC',
      limit: 20,
    );
    
    return maps.map((map) => _mapToManga(map)).toList();
  }
  
  @override
  Future<List<Manga>> getRecentlyUpdatedManga() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      orderBy: 'updated_at DESC',
      limit: 20,
    );
    
    return maps.map((map) => _mapToManga(map)).toList();
  }
  
  @override
  Future<void> saveManga(Manga manga) async {
    try {
      await DatabaseService.insertManga(manga);
    } catch (e) {
       log('保存漫画失败: $e');
    }
  }

    @override
  Future<void> updateManga(Manga manga) async {
     try {
        await DatabaseService.updateManga(manga);
    } catch (e) {
      log('更新漫画失败: $e');
    }
  }
  
  @override
  Future<void> deleteManga(String id) async {
    try {
      await DatabaseService.deleteManga(id);
    } catch (e) {
      log('删除漫画失败: $e');
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
    } catch (e) {
      log('更新漫画失败: $e');
    }
  }
  
  @override
  Future<void> updateReadingProgress(String mangaId, ReadingProgress progress) async {
    final manga = await getMangaById(mangaId);
    if (manga == null) return;
    
    final now = DateTime.now();
    await DatabaseService.insertOrUpdateReadingProgress(progress);
    
    // 更新漫画的最后阅读时间
    final db = await DatabaseService.database;
    await db.update(
      'manga',
      {'last_read_at': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [mangaId],
    );
  }


  @override
  Future<MangaPage?> getPageById(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga_page',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return MangaPage.fromMap(maps.first);
  }
 @override
    Future<List<MangaPage>> getPageByMangaId(String id) async{
    final db = await DatabaseService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'manga_page',
          where: 'manga_id = ?',
          whereArgs: [id]
        );
        
        if (maps.isEmpty) return [];
        return maps.map((map) => _mapToMangaPage(map)).toList();
    }
  
  @override
  Future<void> savePage(MangaPage page) async {
    await DatabaseService.insertPage(page);
  }
  
  @override
  Future<void> deletePage(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 简化实现
  }
  
  @override
  Future<void> saveMangaList(List<Manga> mangaList) async {
    try {
      // 批量保存到数据库
      for (final manga in mangaList) {
        await DatabaseService.insertManga(manga);
      }
    } catch (e) {
      // 如果数据库操作失败，逐个保存
      await Future.delayed(const Duration(milliseconds: 200));
      for (final manga in mangaList) {
        await saveManga(manga);
      }
    }
  }
  
 
  
  @override
  Future<void> savePageList(List<MangaPage> pageList) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    
    for (final page in pageList) {
      batch.insert(
        'manga_page',
        page.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }
  
  @override
  Future<void> clearCache() async {
    final db = await DatabaseService.database;
    // 清除页面缓存
    await db.delete('manga_page');
    // 可以根据需要清除其他缓存数据
  }
  
  @override
  Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
  }

  // 将数据库Map转换为Manga对象
  Manga _mapToManga(Map<String, dynamic> map) {
    return Manga(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      author: map['author'] as String?,
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      coverPath: map['cover_path'] as String?,
      libraryId: map['library_id'] as String,
      path: map['path'] as String,
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      status: MangaStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MangaStatus.unknown,
      ),
      type: MangaType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MangaType.folder,
      ),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      lastReadAt: map['last_read_at'] != null ? DateTime.parse(map['last_read_at']) : null,
      totalPages: map['total_pages'] as int? ?? 0,
      currentPage: map['current_page'] as int? ?? 0,
      rating: map['rating'] as double?,
      source: map['source'] as String?,
      sourceUrl: map['source_url'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      isCompleted: (map['is_completed'] as int?) == 1,
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(jsonDecode(map['metadata'])) : {},
    );
  }

  MangaPage _mapToMangaPage(Map<String, dynamic> map) {
    return MangaPage(
      id: map['id'] as String,
      mangaId: map['manga_id'] as String,
      pageNumber: map['page_index'] as int,
      localPath: map['local_path'] as String,
      largeThumbnail: map['large_thumbnail'] as String?,
      mediumThumbnail: map['medium_thumbnail'] as String?,
      smallThumbnail: map['small_thumbnail'] as String?,
    );
  }
}
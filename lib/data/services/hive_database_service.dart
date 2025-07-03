import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/library.dart';
import '../models/reading_progress.dart';
import '../adapters/duration_adapter.dart';

class HiveDatabaseService {
  static const String _mangaBoxName = 'manga';
  static const String _pageBoxName = 'manga_page';
  static const String _libraryBoxName = 'library';
  static const String _readingProgressBoxName = 'reading_progress';

  static Box<Manga>? _mangaBox;
  static Box<MangaPage>? _pageBox;
  static Box<MangaLibrary>? _libraryBox;
  static Box<ReadingProgress>? _readingProgressBox;

  static bool _isInitialized = false;

  /// 初始化Hive数据库
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 初始化Hive
      await Hive.initFlutter();

      // 注册适配器
      _registerAdapters();

      // 打开所有Box
      await _openBoxes();

      _isInitialized = true;
      log('Hive数据库初始化成功');
    } catch (e, stackTrace) {
      log('Hive数据库初始化失败: $e, 堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 为Isolate环境初始化Hive数据库
  static Future<void> initForIsolate(String dbPath) async {
    if (_isInitialized) return;

    try {
      // 在Isolate中使用Hive.init()而不是Hive.initFlutter()
      Hive.init(dbPath);

      // 注册适配器
      _registerAdapters();

      // 打开所有Box
      await _openBoxes();

      _isInitialized = true;
      log('Hive数据库(Isolate)初始化成功');
    } catch (e, stackTrace) {
      log('Hive数据库(Isolate)初始化失败: $e, 堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 注册Hive适配器
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MangaTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MangaAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MangaStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MangaLibraryAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(LibraryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(LibrarySettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(CoverDisplayModeAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ReadingProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MangaPageAdapter());
    }
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(DurationAdapter());
    }
  }

  /// 打开所有Box
  static Future<void> _openBoxes() async {
    _libraryBox = await Hive.openBox<MangaLibrary>(_libraryBoxName);
    _mangaBox = await Hive.openBox<Manga>(_mangaBoxName);
    _pageBox = await Hive.openBox<MangaPage>(_pageBoxName);
    _readingProgressBox = await Hive.openBox<ReadingProgress>(_readingProgressBoxName);
  }

  /// 确保数据库已初始化
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // ==================== 漫画库操作 ====================

  /// 插入漫画库
  static Future<void> insertLibrary(MangaLibrary library) async {
    await _ensureInitialized();
    await _libraryBox!.put(library.id, library);
    log('插入漫画库: ${library.name}');
  }

  /// 获取所有漫画库
  static Future<List<MangaLibrary>> getAllLibraries() async {
    await _ensureInitialized();
    return _libraryBox!.values.toList();
  }

  /// 根据ID获取漫画库
  static Future<MangaLibrary?> getLibraryById(String id) async {
    await _ensureInitialized();
    return _libraryBox!.get(id);
  }

  /// 更新漫画库
  static Future<void> updateLibrary(MangaLibrary library) async {
    await _ensureInitialized();
    await _libraryBox!.put(library.id, library);
    log('更新漫画库: ${library.name}');
  }

  /// 删除漫画库
  static Future<void> deleteLibrary(String id) async {
    await _ensureInitialized();
    await _libraryBox!.delete(id);
    
    // 删除该库下的所有漫画
    final mangasToDelete = _mangaBox!.values
        .where((manga) => manga.libraryId == id)
        .map((manga) => manga.id)
        .toList();
    
    for (final mangaId in mangasToDelete) {
      await deleteManga(mangaId);
    }
    
    log('删除漫画库: $id');
  }

  // ==================== 漫画操作 ====================

  /// 插入漫画
  static Future<void> insertManga(Manga manga) async {
    await _ensureInitialized();
    await _mangaBox!.put(manga.id, manga);
    log('插入漫画: ${manga.title}');
  }

  /// 获取所有漫画（只返回启用库中的漫画）
  static Future<List<Manga>> getAllManga() async {
    await _ensureInitialized();
    final enabledLibraries = _libraryBox!.values
        .where((library) => library.isEnabled)
        .map((library) => library.id)
        .toSet();
    
    return _mangaBox!.values
        .where((manga) => enabledLibraries.contains(manga.libraryId))
        .toList();
  }

  /// 根据库ID获取漫画
  static Future<List<Manga>> getMangaByLibraryId(String libraryId) async {
    await _ensureInitialized();
    return _mangaBox!.values
        .where((manga) => manga.libraryId == libraryId)
        .toList();
  }

  /// 根据ID获取漫画
  static Future<Manga?> getMangaById(String id) async {
    try {
      await _ensureInitialized();
      
      if (id.isEmpty) {
        log('getMangaById: 输入的id为空');
        return null;
      }
      
      final manga = _mangaBox!.get(id);
      if (manga != null) {
        log('成功获取漫画: ${manga.title}');
      } else {
        log('未找到漫画: $id');
      }
      
      return manga;
    } catch (e, stackTrace) {
      log('getMangaById 查询失败: $e, 堆栈: $stackTrace');
      return null;
    }
  }

  /// 更新漫画
  static Future<void> updateManga(Manga manga) async {
    await _ensureInitialized();
    await _mangaBox!.put(manga.id, manga);
    log('更新漫画: ${manga.title}');
  }

  /// 删除漫画
  static Future<void> deleteManga(String id) async {
    await _ensureInitialized();
    await _mangaBox!.delete(id);
    
    // 删除相关的页面和阅读进度
    await deletePageByMangaId(id);
    await deleteReadingProgress(id);
    
    log('删除漫画: $id');
  }

  // ==================== 页面操作 ====================

  /// 插入页面
  static Future<void> insertPage(MangaPage page) async {
    await _ensureInitialized();
    await _pageBox!.put(page.id, page);
  }

  /// 更新页面
  static Future<void> updatePage(MangaPage page) async {
    await _ensureInitialized();
    await _pageBox!.put(page.id, page);
  }

  /// 根据漫画ID删除页面
  static Future<void> deletePageByMangaId(String mangaId) async {
    await _ensureInitialized();
    final pagesToDelete = _pageBox!.values
        .where((page) => page.mangaId == mangaId)
        .map((page) => page.id)
        .toList();
    
    for (final pageId in pagesToDelete) {
      await _pageBox!.delete(pageId);
    }
  }

  /// 根据ID获取页面
  static Future<MangaPage?> getPageById(String id) async {
    await _ensureInitialized();
    return _pageBox!.get(id);
  }

  /// 根据漫画ID获取页面列表
  static Future<List<MangaPage>> getPagesByMangaId(String mangaId) async {
    await _ensureInitialized();
    return _pageBox!.values
        .where((page) => page.mangaId == mangaId)
        .toList();
  }

  // ==================== 阅读进度操作 ====================

  /// 插入或更新阅读进度
  static Future<void> insertOrUpdateReadingProgress(ReadingProgress progress) async {
    await _ensureInitialized();
    await _readingProgressBox!.put(progress.id, progress);
    log('更新阅读进度: ${progress.mangaId}, 页面: ${progress.currentPage}/${progress.totalPages}');
  }

  /// 根据漫画ID获取阅读进度
  static Future<ReadingProgress?> getReadingProgressByMangaId(String mangaId) async {
    await _ensureInitialized();
    return _readingProgressBox!.values
        .where((progress) => progress.mangaId == mangaId)
        .firstOrNull;
  }

  /// 获取所有阅读进度
  static Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    await _ensureInitialized();
    return _readingProgressBox!.values.toList();
  }

  /// 根据库ID获取阅读进度
  static Future<List<ReadingProgress>?> getReadingProgressByLibraryId(String libraryId) async {
    await _ensureInitialized();
    final progressList = _readingProgressBox!.values
        .where((progress) => progress.libraryId == libraryId)
        .toList();
    
    return progressList.isEmpty ? null : progressList;
  }

  /// 删除阅读进度
  static Future<void> deleteReadingProgress(String mangaId) async {
    await _ensureInitialized();
    final progressToDelete = _readingProgressBox!.values
        .where((progress) => progress.mangaId == mangaId)
        .map((progress) => progress.id)
        .toList();
    
    for (final progressId in progressToDelete) {
      await _readingProgressBox!.delete(progressId);
    }
  }

  // ==================== 数据管理 ====================

  /// 清理所有数据
  static Future<void> clearAllData() async {
    await _ensureInitialized();
    await _readingProgressBox!.clear();
    await _pageBox!.clear();
    await _mangaBox!.clear();
    await _libraryBox!.clear();
    log('清理所有数据完成');
  }

  /// 关闭数据库
  static Future<void> close() async {
    if (_isInitialized) {
      await _libraryBox?.close();
      await _mangaBox?.close();
      await _pageBox?.close();
      await _readingProgressBox?.close();
      
      _libraryBox = null;
      _mangaBox = null;
      _pageBox = null;
      _readingProgressBox = null;
      
      _isInitialized = false;
      log('Hive数据库已关闭');
    }
  }

  /// 获取数据库统计信息
  static Future<Map<String, int>> getDatabaseStats() async {
    await _ensureInitialized();
    return {
      'libraries': _libraryBox!.length,
      'manga': _mangaBox!.length,
      'pages': _pageBox!.length,
      'reading_progress': _readingProgressBox!.length,
    };
  }

  /// 数据迁移：从旧的SQLite数据迁移到Hive
  static Future<void> migrateFromSQLite({
    required List<MangaLibrary> libraries,
    required List<Manga> mangas,
    required List<MangaPage> pages,
    required List<ReadingProgress> readingProgresses,
  }) async {
    await _ensureInitialized();
    
    log('开始数据迁移...');
    
    // 清空现有数据
    await clearAllData();
    
    // 迁移漫画库
    for (final library in libraries) {
      await insertLibrary(library);
    }
    
    // 迁移漫画
    for (final manga in mangas) {
      await insertManga(manga);
    }
    
    // 迁移页面
    for (final page in pages) {
      await insertPage(page);
    }
    
    // 迁移阅读进度
    for (final progress in readingProgresses) {
      await insertOrUpdateReadingProgress(progress);
    }
    
    log('数据迁移完成: ${libraries.length}个库, ${mangas.length}个漫画, ${pages.length}个页面, ${readingProgresses.length}个阅读进度');
  }
}

/// 扩展方法，为Iterable添加firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
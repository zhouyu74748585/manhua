import 'dart:async';
import 'dart:developer';
import 'hive_database_service.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/library.dart';
import '../models/reading_progress.dart';

/// 统一的数据库服务接口
/// 内部使用Hive作为存储引擎，并处理从SQLite的数据迁移
class DatabaseService {
  static bool _isInitialized = false;

  /// 初始化数据库服务
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      log('初始化数据库服务...');
      
      // 初始化Hive数据库
      await HiveDatabaseService.init();
      
      _isInitialized = true;
      log('数据库服务初始化完成');
    } catch (e, stackTrace) {
      log('数据库服务初始化失败: $e, 堆栈: $stackTrace');
      rethrow;
    }
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
    return HiveDatabaseService.insertLibrary(library);
  }

  /// 获取所有漫画库
  static Future<List<MangaLibrary>> getAllLibraries() async {
    await _ensureInitialized();
    return HiveDatabaseService.getAllLibraries();
  }

  /// 根据ID获取漫画库
  static Future<MangaLibrary?> getLibraryById(String id) async {
    await _ensureInitialized();
    return HiveDatabaseService.getLibraryById(id);
  }

  /// 更新漫画库
  static Future<void> updateLibrary(MangaLibrary library) async {
    await _ensureInitialized();
    return HiveDatabaseService.updateLibrary(library);
  }

  /// 删除漫画库
  static Future<void> deleteLibrary(String id) async {
    await _ensureInitialized();
    return HiveDatabaseService.deleteLibrary(id);
  }

  // ==================== 漫画操作 ====================

  /// 插入漫画
  static Future<void> insertManga(Manga manga) async {
    await _ensureInitialized();
    return HiveDatabaseService.insertManga(manga);
  }

  /// 获取所有漫画（只返回启用库中的漫画）
  static Future<List<Manga>> getAllManga() async {
    await _ensureInitialized();
    return HiveDatabaseService.getAllManga();
  }

  /// 根据库ID获取漫画
  static Future<List<Manga>> getMangaByLibraryId(String libraryId) async {
    await _ensureInitialized();
    return HiveDatabaseService.getMangaByLibraryId(libraryId);
  }

  /// 根据ID获取漫画
  static Future<Manga?> getMangaById(String id) async {
    await _ensureInitialized();
    return HiveDatabaseService.getMangaById(id);
  }

  /// 更新漫画
  static Future<void> updateManga(Manga manga) async {
    await _ensureInitialized();
    return HiveDatabaseService.updateManga(manga);
  }

  /// 删除漫画
  static Future<void> deleteManga(String id) async {
    await _ensureInitialized();
    return HiveDatabaseService.deleteManga(id);
  }

  // ==================== 页面操作 ====================

  /// 插入页面
  static Future<void> insertPage(MangaPage page) async {
    await _ensureInitialized();
    return HiveDatabaseService.insertPage(page);
  }

  /// 更新页面
  static Future<void> updatePage(MangaPage page) async {
    await _ensureInitialized();
    return HiveDatabaseService.updatePage(page);
  }

  /// 根据漫画ID删除页面
  static Future<void> deletePageByMangaId(String mangaId) async {
    await _ensureInitialized();
    return HiveDatabaseService.deletePageByMangaId(mangaId);
  }

  /// 根据ID获取页面
  static Future<MangaPage?> getPageById(String id) async {
    await _ensureInitialized();
    return HiveDatabaseService.getPageById(id);
  }

  /// 根据漫画ID获取页面列表
  static Future<List<MangaPage>> getPagesByMangaId(String mangaId) async {
    await _ensureInitialized();
    return HiveDatabaseService.getPagesByMangaId(mangaId);
  }

  // ==================== 阅读进度操作 ====================

  /// 插入或更新阅读进度
  static Future<void> insertOrUpdateReadingProgress(ReadingProgress progress) async {
    await _ensureInitialized();
    return HiveDatabaseService.insertOrUpdateReadingProgress(progress);
  }

  /// 根据漫画ID获取阅读进度
  static Future<ReadingProgress?> getReadingProgressByMangaId(String mangaId) async {
    await _ensureInitialized();
    return HiveDatabaseService.getReadingProgressByMangaId(mangaId);
  }

  /// 获取所有阅读进度
  static Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    await _ensureInitialized();
    return HiveDatabaseService.getAllMangaReadingProgress();
  }

  /// 根据库ID获取阅读进度
  static Future<List<ReadingProgress>?> getReadingProgressByLibraryId(String libraryId) async {
    await _ensureInitialized();
    return HiveDatabaseService.getReadingProgressByLibraryId(libraryId);
  }

  /// 删除阅读进度
  static Future<void> deleteReadingProgress(String mangaId) async {
    await _ensureInitialized();
    return HiveDatabaseService.deleteReadingProgress(mangaId);
  }

  // ==================== 数据管理 ====================

  /// 清理所有数据
  static Future<void> clearAllData() async {
    await _ensureInitialized();
    return HiveDatabaseService.clearAllData();
  }

  /// 关闭数据库
  static Future<void> close() async {
    if (_isInitialized) {
      await HiveDatabaseService.close();
      _isInitialized = false;
      log('数据库服务已关闭');
    }
  }

  /// 获取数据库统计信息
  static Future<Map<String, int>> getDatabaseStats() async {
    await _ensureInitialized();
    return HiveDatabaseService.getDatabaseStats();
  }

  // ==================== 兼容性方法 ====================
  // 这些方法保持与原SQLite实现的兼容性

  /// 为Isolate环境设置数据库路径（Hive中不需要，保持兼容性）
  static void setIsolateDbPath(String dbPath) {
    log('setIsolateDbPath调用（Hive实现中忽略）: $dbPath');
    // Hive不需要手动设置路径，此方法保持兼容性但不执行任何操作
  }

  /// 获取数据库实例（保持兼容性，实际返回统计信息）
  static Future<Map<String, dynamic>> get database async {
    await _ensureInitialized();
    final stats = await getDatabaseStats();
    return {
      'type': 'hive',
      'stats': stats,
      'initialized': _isInitialized,
    };
  }
}
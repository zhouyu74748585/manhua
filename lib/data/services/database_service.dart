import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/library.dart';
import '../models/reading_progress.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'manhua_reader.db';
  static const int _databaseVersion = 1;

  // 表名
  static const String _mangaTable = 'manga';
  static const String _pageTable = 'manga_page';
  static const String _libraryTable = 'library';
  static const String _readingProgressTable = 'reading_progress';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 创建漫画库表
    await db.execute('''
      CREATE TABLE $_libraryTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        path TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        last_scan_at INTEGER,
        manga_count INTEGER NOT NULL DEFAULT 0,
        settings TEXT
      )
    ''');

    // 创建漫画表
    await db.execute('''
      CREATE TABLE $_mangaTable (
        id TEXT PRIMARY KEY,
        library_id TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT,
        author TEXT,
        description TEXT,
        cover_path TEXT,
        tags TEXT,
        status TEXT,
        type TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        current_page INTEGER NOT NULL DEFAULT 0,
        rating REAL,
        source TEXT,
        source_url TEXT,
        last_read_at TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        reading_progress TEXT,
        file_path TEXT,
        file_size INTEGER,
        metadata TEXT,
        FOREIGN KEY (library_id) REFERENCES $_libraryTable (id) ON DELETE CASCADE
      )
    ''');

    // 创建页面表
    await db.execute('''
      CREATE TABLE $_pageTable (
        id TEXT PRIMARY KEY,
        manga_id TEXT NOT NULL,
        page_index INTEGER NOT NULL,
        local_path TEXT,
        large_thumbnail TEXT,
        medium_thumbnail TEXT,
        small_thumbnail TEXT,
        FOREIGN KEY (manga_id) REFERENCES $_mangaTable (id) ON DELETE CASCADE
      )
    ''');

    // 创建阅读进度表
    await db.execute('''
       CREATE TABLE $_readingProgressTable (
         id TEXT PRIMARY KEY,
         manga_id TEXT NOT NULL,
         library_id TEXT NOT NULL,
         current_apeg INTEGER NOT NULL DEFAULT 1,
         current_page INTEGER NOT NULL DEFAULT 1,
         total_pages INTEGER NOT NULL DEFAULT 1,
         progress_percentage REAL NOT NULL DEFAULT 0.0,
         last_read_at INTEGER NOT NULL,
         created_at INTEGER NOT NULL,
         updated_at INTEGER NOT NULL,
         FOREIGN KEY (manga_id) REFERENCES $_mangaTable (id) ON DELETE CASCADE
       )
     ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_manga_library_id ON $_mangaTable (library_id)');
    await db.execute('CREATE INDEX idx_manga_title ON $_mangaTable (title)');
    await db.execute(
        'CREATE INDEX idx_manga_is_favorite ON $_mangaTable (is_favorite)');
    await db
        .execute('CREATE INDEX idx_page_manga_id ON $_pageTable (manga_id)');
    await db.execute(
        'CREATE INDEX idx_reading_progress_manga_id ON $_readingProgressTable (manga_id)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < newVersion) {
      // 根据版本进行相应的升级操作
    }
  }

  // 漫画库操作
  static Future<void> insertLibrary(MangaLibrary library) async {
    final db = await database;
    await db.insert(
      _libraryTable,
      {
        'id': library.id,
        'name': library.name,
        'path': library.path,
        'type': library.type.toString(),
        'is_enabled': library.isEnabled ? 1 : 0,
        'created_at': library.createdAt.millisecondsSinceEpoch,
        'last_scan_at': library.lastScanAt?.millisecondsSinceEpoch,
        'manga_count': library.mangaCount,
        'settings': jsonEncode(library.settings),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<MangaLibrary>> getAllLibraries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_libraryTable);

    return List.generate(maps.length, (i) {
      LibrarySettings settings = const LibrarySettings();
      if (maps[i]['settings'] != null &&
          maps[i]['settings'].toString().isNotEmpty) {
        try {
          settings = LibrarySettings.fromJson(jsonDecode(maps[i]['settings']));
        } catch (e, stack) {
          log('从数据库获取漫画库失败: $e $stack');
          // 如果解析失败，使用空的设置
          settings = const LibrarySettings();
        }
      }

      return MangaLibrary(
        id: maps[i]['id'],
        name: maps[i]['name'],
        path: maps[i]['path'],
        type: LibraryType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'],
          orElse: () => LibraryType.local,
        ),
        isEnabled: maps[i]['is_enabled'] == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
        lastScanAt: maps[i]['last_scan_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(maps[i]['last_scan_at'])
            : null,
        mangaCount: maps[i]['manga_count'],
        settings: settings,
      );
    });
  }

  static Future<MangaLibrary?> getLibraryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _libraryTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    LibrarySettings settings = const LibrarySettings();
    if (map['settings'] != null && map['settings'].toString().isNotEmpty) {
      try {
        settings = LibrarySettings.fromJson(jsonDecode(map['settings']));
      } catch (e) {
        // 如果解析失败，使用空的设置
        settings = const LibrarySettings();
      }
    }

    return MangaLibrary(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      type: LibraryType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => LibraryType.local,
      ),
      isEnabled: map['is_enabled'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastScanAt: map['last_scan_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_scan_at'])
          : null,
      mangaCount: map['manga_count'],
      settings: settings,
    );
  }

  static Future<void> updateLibrary(MangaLibrary library) async {
    final db = await database;
    await db.update(
      _libraryTable,
      {
        'name': library.name,
        'path': library.path,
        'type': library.type.toString(),
        'is_enabled': library.isEnabled ? 1 : 0,
        'last_scan_at': library.lastScanAt?.millisecondsSinceEpoch,
        'manga_count': library.mangaCount,
        'settings': jsonEncode(library.settings),
      },
      where: 'id = ?',
      whereArgs: [library.id],
    );
  }

  static Future<void> deleteLibrary(String id) async {
    final db = await database;
    await db.delete(
      _libraryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 漫画操作
  static Future<void> insertManga(Manga manga) async {
    final db = await database;
    await db.insert(
      _mangaTable,
      {
        'id': manga.id,
        'library_id': manga.libraryId,
        'title': manga.title,
        'subtitle': manga.subtitle,
        'author': manga.author,
        'description': manga.description,
        'cover_path': manga.coverPath,
        'tags': manga.tags.join(','),
        'status': manga.status.name,
        'type': manga.type.name,
        'is_favorite': manga.isFavorite ? 1 : 0,
        'is_completed': manga.isCompleted ? 1 : 0,
        'total_pages': manga.totalPages,
        'current_page': manga.currentPage,
        'rating': manga.rating,
        'source': manga.source,
        'source_url': manga.sourceUrl,
        'last_read_at': manga.lastReadAt?.toIso8601String(),
        'created_at': manga.createdAt?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
        'updated_at': manga.updatedAt?.millisecondsSinceEpoch,
        'file_path': manga.path,
        'file_size': manga.fileSize,
        'metadata': jsonEncode(manga.metadata),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Manga>> getAllManga() async {
    final db = await database;
    // 只查询启用库中的漫画
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.* FROM $_mangaTable m
      INNER JOIN $_libraryTable l ON m.library_id = l.id
      WHERE l.is_enabled = 1
    ''');

    return List.generate(maps.length, (i) {
      return _mapToManga(maps[i]);
    });
  }

  static Future<List<Manga>> getMangaByLibraryId(String libraryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _mangaTable,
      where: 'library_id = ?',
      whereArgs: [libraryId],
    );

    return List.generate(maps.length, (i) {
      return _mapToManga(maps[i]);
    });
  }

  static Future<Manga?> getMangaById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _mangaTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToManga(maps.first);
  }

  static Future<void> updateManga(Manga manga) async {
    final db = await database;
    await db.update(
      _mangaTable,
      {
        'library_id': manga.libraryId,
        'title': manga.title,
        'subtitle': manga.subtitle,
        'author': manga.author,
        'description': manga.description,
        'cover_path': manga.coverPath,
        'tags': manga.tags.join(','),
        'status': manga.status.name,
        'type': manga.type.name,
        'is_favorite': manga.isFavorite ? 1 : 0,
        'is_completed': manga.isCompleted ? 1 : 0,
        'total_pages': manga.totalPages,
        'current_page': manga.currentPage,
        'rating': manga.rating,
        'source': manga.source,
        'source_url': manga.sourceUrl,
        'last_read_at': manga.lastReadAt?.toIso8601String(),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'file_path': manga.path,
        'metadata': jsonEncode(manga.metadata),
      },
      where: 'id = ?',
      whereArgs: [manga.id],
    );
  }

  static Future<void> deleteManga(String id) async {
    final db = await database;
    await db.delete(
      _mangaTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Manga _mapToManga(Map<String, dynamic> map) {
    return Manga(
      id: map['id'],
      libraryId: map['library_id'],
      title: map['title'],
      path: map['file_path'] ?? '',
      type: map['type'] != null
          ? MangaType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => MangaType.folder,
            )
          : MangaType.folder,
      totalPages: (map['total_pages'] as int?) ?? 0,
      currentPage: (map['current_page'] as int?) ?? 0,
      subtitle: map['subtitle'],
      author: map['author'],
      description: map['description'],
      coverPath: map['cover_path'],
      tags: map['tags']
              ?.split(',')
              .where((tag) => tag.toString().isNotEmpty)
              .toList() ??
          [],
      status: map['status'] != null
          ? MangaStatus.values.firstWhere(
              (e) => e.name == map['status'],
              orElse: () => MangaStatus.unknown,
            )
          : MangaStatus.unknown,
      isFavorite: map['is_favorite'] == 1,
      isCompleted: map['is_completed'] == 1,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      source: map['source'],
      sourceUrl: map['source_url'],
      lastReadAt: map['last_read_at'] != null
          ? DateTime.parse(map['last_read_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(jsonDecode(map['metadata']))
          : {},
    );
  }

  // 页面操作
  static Future<void> insertPage(MangaPage page) async {
    final db = await database;
    await db.insert(
      _pageTable,
      {
        'id': page.id,
        'manga_id': page.mangaId,
        'page_index': page.pageIndex,
        'local_path': page.localPath,
        'large_thumbnail': page.largeThumbnail,
        'medium_thumbnail': page.mediumThumbnail,
        'small_thumbnail': page.smallThumbnail,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updatePage(MangaPage page) async {
    final db = await database;
    await db.update(
      _pageTable,
      {
        'page_index': page.pageIndex,
        'local_path': page.localPath,
        'large_thumbnail': page.largeThumbnail,
        'medium_thumbnail': page.mediumThumbnail,
        'small_thumbnail': page.smallThumbnail,
      },
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  // 阅读进度操作
  static Future<void> insertOrUpdateReadingProgress(
      ReadingProgress progress) async {
    final db = await database;
    await db.insert(
      _readingProgressTable,
      {
        'id': progress.id,
        'manga_id': progress.mangaId,
        'library_id': progress.libraryId,
        'current_page': progress.currentPage,
        'total_pages': progress.totalPages,
        'progress_percentage': progress.progressPercentage,
        'last_read_at': progress.lastReadAt.millisecondsSinceEpoch,
        'created_at': progress.createdAt.millisecondsSinceEpoch,
        'updated_at': progress.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<ReadingProgress?> getReadingProgressByMangaId(
      String mangaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _readingProgressTable,
      where: 'manga_id = ?',
      whereArgs: [mangaId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return ReadingProgress(
      id: map['id'],
      mangaId: map['manga_id'],
      libraryId: map['library_id'],
      currentPage: map['current_page'],
      totalPages: map['total_pages'],
      progressPercentage: (map['progress_percentage'] as num).toDouble(),
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['last_read_at']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  static Future<List<ReadingProgress>> getAllMangaReadingProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _readingProgressTable,
    );

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      Map map = maps[i];
      return ReadingProgress(
        id: map['id'],
        mangaId: map['manga_id'],
        libraryId: map['library_id'],
        currentPage: map['current_page'],
        totalPages: map['total_pages'],
        progressPercentage: (map['progress_percentage'] as num).toDouble(),
        lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['last_read_at']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      );
    });
  }

  static Future<List<ReadingProgress>?> getReadingProgressByLibraryId(
      String libraryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _readingProgressTable,
      where: 'library_id = ?',
      whereArgs: [libraryId],
    );

    if (maps.isEmpty) return null;

    return List.generate(maps.length, (i) {
      Map map = maps[i];
      return ReadingProgress(
        id: map['id'],
        mangaId: map['manga_id'],
        libraryId: map['library_id'],
        currentPage: map['current_page'],
        totalPages: map['total_pages'],
        progressPercentage: (map['progress_percentage'] as num).toDouble(),
        lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['last_read_at']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      );
    });
  }

  static Future<void> deleteReadingProgress(String mangaId) async {
    final db = await database;
    await db.delete(
      _readingProgressTable,
      where: 'manga_id = ?',
      whereArgs: [mangaId],
    );
  }

  static Future<void> deletePageByMangaId(String mangaId) async {
    final db = await database;
    await db.delete(
      _pageTable,
      where: 'manga_id = ?',
      whereArgs: [mangaId],
    );
  }

  // 清理数据
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_readingProgressTable);
    await db.delete(_pageTable);
    await db.delete(_mangaTable);
    await db.delete(_libraryTable);
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

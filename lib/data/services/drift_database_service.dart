import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/library.dart';
import '../models/manga.dart' as model;
import '../models/manga_page.dart' as page_model;
import '../models/reading_progress.dart' as rp_model;

/// Drift-based database service for isolate-safe database operations
class DriftDatabaseService {
  static AppDatabase? _database;

  /// Get the main database instance
  static AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Create database instance for isolates
  static Future<AppDatabase> createIsolateDatabase() async {
    return await AppDatabase.createForIsolate();
  }

  /// Close database connection
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // ==================== Library Operations ====================

  /// Insert a new library
  static Future<void> insertLibrary(MangaLibrary library) async {
    final db = database;
    await db.into(db.libraries).insert(
          LibrariesCompanion(
            id: Value(library.id),
            name: Value(library.name),
            path: Value(library.path),
            type: Value(library.type.toString()),
            isEnabled: Value(library.isEnabled),
            createdAt: Value(library.createdAt),
            lastScanAt: Value(library.lastScanAt),
            mangaCount: Value(library.mangaCount),
            settings: Value(jsonEncode(library.settings.toJson())),
            isScanning: Value(library.isScanning),
            isPrivate: Value(library.isPrivate),
            isPrivateActivated: Value(library.isPrivateActivated),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Get all libraries
  static Future<List<MangaLibrary>> getAllLibraries() async {
    final db = database;
    final libraries = await db.select(db.libraries).get();
    return libraries.map(_libraryFromDrift).toList();
  }

  /// Get library by ID
  static Future<MangaLibrary?> getLibraryById(String id) async {
    final db = database;
    final query = db.select(db.libraries)..where((tbl) => tbl.id.equals(id));
    final library = await query.getSingleOrNull();
    return library != null ? _libraryFromDrift(library) : null;
  }

  /// Update library
  static Future<void> updateLibrary(MangaLibrary library) async {
    final db = database;
    await (db.update(db.libraries)..where((tbl) => tbl.id.equals(library.id)))
        .write(LibrariesCompanion(
      name: Value(library.name),
      path: Value(library.path),
      type: Value(library.type.toString()),
      isEnabled: Value(library.isEnabled),
      lastScanAt: Value(library.lastScanAt),
      mangaCount: Value(library.mangaCount),
      settings: Value(jsonEncode(library.settings.toJson())),
      isScanning: Value(library.isScanning),
      isPrivate: Value(library.isPrivate),
      isPrivateActivated: Value(library.isPrivateActivated),
    ));
  }

  /// Delete library
  static Future<void> deleteLibrary(String id) async {
    final db = database;
    await (db.delete(db.libraries)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ==================== Manga Operations ====================

  /// Insert a new manga
  static Future<void> insertManga(model.Manga manga) async {
    final db = database;
    await db.into(db.mangas).insert(
          MangasCompanion(
            id: Value(manga.id),
            libraryId: Value(manga.libraryId),
            title: Value(manga.title),
            subtitle: Value(manga.subtitle),
            author: Value(manga.author),
            description: Value(manga.description),
            coverPath: Value(manga.coverPath),
            tags: Value(jsonEncode(manga.tags)),
            status: Value(manga.status.toString()),
            type: Value(manga.type.toString()),
            isFavorite: Value(manga.isFavorite),
            isCompleted: Value(manga.isCompleted),
            totalPages: Value(manga.totalPages),
            currentPage: Value(manga.currentPage),
            rating: Value(manga.rating),
            source: Value(manga.source),
            sourceUrl: Value(manga.sourceUrl),
            lastReadAt: Value(manga.lastReadAt?.toIso8601String()),
            createdAt: Value(manga.createdAt ?? DateTime.now()),
            updatedAt: Value(manga.updatedAt),
            filePath: Value(manga.path),
            fileSize: Value(manga.fileSize),
            metadata: Value(jsonEncode(manga.metadata)),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Update manga
  static Future<void> updateManga(model.Manga manga) async {
    final db = database;
    await (db.update(db.mangas)..where((tbl) => tbl.id.equals(manga.id)))
        .write(MangasCompanion(
      title: Value(manga.title),
      subtitle: Value(manga.subtitle),
      author: Value(manga.author),
      description: Value(manga.description),
      coverPath: Value(manga.coverPath),
      tags: Value(jsonEncode(manga.tags)),
      status: Value(manga.status.toString()),
      type: Value(manga.type.toString()),
      isFavorite: Value(manga.isFavorite),
      isCompleted: Value(manga.isCompleted),
      totalPages: Value(manga.totalPages),
      currentPage: Value(manga.currentPage),
      rating: Value(manga.rating),
      source: Value(manga.source),
      sourceUrl: Value(manga.sourceUrl),
      lastReadAt: Value(manga.lastReadAt?.toIso8601String()),
      updatedAt: Value(manga.updatedAt ?? DateTime.now()),
      filePath: Value(manga.path),
      fileSize: Value(manga.fileSize),
      metadata: Value(jsonEncode(manga.metadata)),
    ));
  }

  /// Delete manga
  static Future<void> deleteManga(String id) async {
    final db = database;
    await (db.delete(db.mangas)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Get all manga from enabled libraries
  static Future<List<model.Manga>> getAllManga() async {
    final db = database;
    final query = db.select(db.mangas).join([
      leftOuterJoin(
          db.libraries, db.libraries.id.equalsExp(db.mangas.libraryId)),
    ])
      ..where(db.libraries.isEnabled.equals(true));

    final results = await query.get();
    return results
        .map((row) => _mangaFromDrift(row.readTable(db.mangas)))
        .toList();
  }

  /// Get manga by library ID
  static Future<List<model.Manga>> getMangaByLibraryId(String libraryId) async {
    final db = database;
    final query = db.select(db.mangas)
      ..where((tbl) => tbl.libraryId.equals(libraryId));
    final mangas = await query.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Update manga's last read at timestamp
  static Future<void> updateMangaLastReadAt(String mangaId, DateTime? lastReadAt) async {
    final db = database;
    await (db.update(db.mangas)..where((tbl) => tbl.id.equals(mangaId)))
        .write(MangasCompanion(lastReadAt: Value(lastReadAt?.toIso8601String())));
  }

  /// Get manga by ID
  static Future<model.Manga?> getMangaById(String id) async {
    final db = database;
    final query = db.select(db.mangas)..where((tbl) => tbl.id.equals(id));
    final manga = await query.getSingleOrNull();
    return manga != null ? _mangaFromDrift(manga) : null;
  }

  /// Search for manga
  static Future<List<model.Manga>> searchManga(String query) async {
    final db = database;
    final select = db.select(db.mangas)
      ..where((tbl) =>
          tbl.title.like('%$query%') |
          tbl.author.like('%$query%') |
          tbl.description.like('%$query%'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]);
    final mangas = await select.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Get manga by category
  static Future<List<model.Manga>> getMangaByCategory(String category) async {
    final db = database;
    final query = db.select(db.mangas)
      ..where((tbl) => tbl.tags.like('%"$category"%'))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]);
    final mangas = await query.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Get favorite manga
  static Future<List<model.Manga>> getFavoriteManga() async {
    final db = database;
    final query = db.select(db.mangas)
      ..where((tbl) => tbl.isFavorite.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]);
    final mangas = await query.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Get recently read manga
  static Future<List<model.Manga>> getRecentlyReadManga() async {
    final db = database;
    final query = db.select(db.mangas)
      ..where((tbl) => tbl.lastReadAt.isNotNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.lastReadAt)])
      ..limit(20);
    final mangas = await query.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Get recently updated manga
  static Future<List<model.Manga>> getRecentlyUpdatedManga() async {
    final db = database;
    final query = db.select(db.mangas)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
      ..limit(20);
    final mangas = await query.get();
    return mangas.map(_mangaFromDrift).toList();
  }

  /// Batch insert mangas
  static Future<void> saveMangaList(List<model.Manga> mangas) async {
    final db = database;
    await db.batch((batch) {
      batch.insertAll(
        db.mangas,
        mangas.map(
          (manga) => MangasCompanion(
            id: Value(manga.id),
            libraryId: Value(manga.libraryId),
            title: Value(manga.title),
            subtitle: Value(manga.subtitle),
            author: Value(manga.author),
            description: Value(manga.description),
            coverPath: Value(manga.coverPath),
            tags: Value(jsonEncode(manga.tags)),
            status: Value(manga.status.toString()),
            type: Value(manga.type.toString()),
            isFavorite: Value(manga.isFavorite),
            isCompleted: Value(manga.isCompleted),
            totalPages: Value(manga.totalPages),
            currentPage: Value(manga.currentPage),
            rating: Value(manga.rating),
            source: Value(manga.source),
            sourceUrl: Value(manga.sourceUrl),
            lastReadAt: Value(manga.lastReadAt?.toIso8601String()),
            createdAt: Value(manga.createdAt ?? DateTime.now()),
            updatedAt: Value(manga.updatedAt),
            filePath: Value(manga.path),
            fileSize: Value(manga.fileSize),
            metadata: Value(jsonEncode(manga.metadata)),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Batch insert pages
  static Future<void> savePageList(List<page_model.MangaPage> pages) async {
    final db = database;
    await db.batch((batch) {
      batch.insertAll(
        db.mangaPages,
        pages.map(
          (page) => MangaPagesCompanion(
            id: Value(page.id),
            mangaId: Value(page.mangaId),
            pageIndex: Value(page.pageIndex),
            localPath: Value(page.localPath),
            largeThumbnail: Value(page.largeThumbnail),
            mediumThumbnail: Value(page.mediumThumbnail),
            smallThumbnail: Value(page.smallThumbnail),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== Reading Progress Operations ====================

  /// Insert or update reading progress
  static Future<void> insertOrUpdateReadingProgress(
      rp_model.ReadingProgress progress) async {
    final db = database;
    await db.into(db.readingProgresses).insert(
          ReadingProgressesCompanion(
            id: Value(progress.id),
            mangaId: Value(progress.mangaId),
            libraryId: Value(progress.libraryId),
            currentPage: Value(progress.currentPage),
            totalPages: Value(progress.totalPages),
            progressPercentage: Value(progress.progressPercentage),
            lastReadAt: Value(progress.lastReadAt),
            createdAt: Value(progress.createdAt),
            updatedAt: Value(progress.updatedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Get reading progress by manga ID
  static Future<rp_model.ReadingProgress?> getReadingProgressByMangaId(
      String mangaId) async {
    final db = database;
    final query = db.select(db.readingProgresses)
      ..where((tbl) => tbl.mangaId.equals(mangaId));
    final progress = await query.getSingleOrNull();
    return progress != null ? _readingProgressFromDrift(progress) : null;
  }

  /// Delete reading progress by manga ID
  static Future<void> deleteReadingProgress(String mangaId) async {
    final db = database;
    await (db.delete(db.readingProgresses)
          ..where((tbl) => tbl.mangaId.equals(mangaId)))
        .go();
  }

  /// Get reading progress by library ID
  static Future<List<rp_model.ReadingProgress>> getReadingProgressByLibraryId(
      String libraryId) async {
    final db = database;
    final query = db.select(db.readingProgresses)
      ..where((tbl) => tbl.libraryId.equals(libraryId));
    final progresses = await query.get();
    return progresses.map(_readingProgressFromDrift).toList();
  }

  /// Get all manga reading progress
  static Future<List<rp_model.ReadingProgress>> getAllMangaReadingProgress() async {
    final db = database;
    final query = db.select(db.readingProgresses)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.lastReadAt)]);
    final progresses = await query.get();
    return progresses.map(_readingProgressFromDrift).toList();
  }

  // ==================== Page Operations ====================


  /// Get page by ID
  static Future<page_model.MangaPage?> getPageById(String id) async {
    final db = database;
    final query = db.select(db.mangaPages)..where((tbl) => tbl.id.equals(id));
    final page = await query.getSingleOrNull();
    return page != null ? _pageFromDrift(page) : null;
  }

  /// Get pages by manga ID
  static Future<List<page_model.MangaPage>> getPagesByMangaId(
      String mangaId) async {
    final db = database;
    final query = db.select(db.mangaPages)
      ..where((tbl) => tbl.mangaId.equals(mangaId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.pageIndex)]);
    final pages = await query.get();
    return pages.map(_pageFromDrift).toList();
  }

  /// Insert a new page
  static Future<void> insertPage(page_model.MangaPage page) async {
    final db = database;
    await db.into(db.mangaPages).insert(
          MangaPagesCompanion(
            id: Value(page.id),
            mangaId: Value(page.mangaId),
            pageIndex: Value(page.pageIndex),
            localPath: Value(page.localPath),
            largeThumbnail: Value(page.largeThumbnail),
            mediumThumbnail: Value(page.mediumThumbnail),
            smallThumbnail: Value(page.smallThumbnail),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Update a page
  static Future<void> updatePage(page_model.MangaPage page) async {
    final db = database;
    await (db.update(db.mangaPages)..where((tbl) => tbl.id.equals(page.id)))
        .write(
      MangaPagesCompanion(
        pageIndex: Value(page.pageIndex),
        localPath: Value(page.localPath),
        largeThumbnail: Value(page.largeThumbnail),
        mediumThumbnail: Value(page.mediumThumbnail),
        smallThumbnail: Value(page.smallThumbnail),
      ),
    );
  }

  /// Delete pages by manga ID
  static Future<void> deletePagesByMangaId(String mangaId) async {
    final db = database;
    await (db.delete(db.mangaPages)..where((tbl) => tbl.mangaId.equals(mangaId)))
        .go();
  }

  // ==================== Clear Operations ====================


  /// Clear all data from the database
  static Future<void> clearAllData() async {
    final db = database;
    await db.transaction(() async {
      await db.delete(db.readingProgresses).go();
      await db.delete(db.mangaPages).go();
      await db.delete(db.mangas).go();
      await db.delete(db.libraries).go();
    });
  }

  // ==================== Helper Methods ====================


  /// Convert Drift Library to domain model
  static MangaLibrary _libraryFromDrift(Library library) {
    LibrarySettings settings = const LibrarySettings();
    if (library.settings != null && library.settings!.isNotEmpty) {
      try {
        settings = LibrarySettings.fromJson(jsonDecode(library.settings!));
      } catch (e) {
        log('Failed to parse library settings: $e');
      }
    }

    return MangaLibrary(
      id: library.id,
      name: library.name,
      path: library.path,
      type: LibraryType.values.firstWhere(
        (e) => e.toString() == library.type,
        orElse: () => LibraryType.local,
      ),
      isEnabled: library.isEnabled,
      createdAt: library.createdAt,
      lastScanAt: library.lastScanAt,
      mangaCount: library.mangaCount,
      settings: settings,
      isScanning: library.isScanning,
      isPrivate: library.isPrivate,
      isPrivateActivated: library.isPrivateActivated,
    );
  }

  /// Convert Drift Manga to domain model
  static model.Manga _mangaFromDrift(Manga manga) {
    List<String> tags = [];
    if (manga.tags != null && manga.tags!.isNotEmpty) {
      try {
        tags = List<String>.from(jsonDecode(manga.tags!));
      } catch (e) {
        log('Failed to parse manga tags: $e');
      }
    }

    Map<String, dynamic> metadata = {};
    if (manga.metadata != null && manga.metadata!.isNotEmpty) {
      try {
        metadata = Map<String, dynamic>.from(jsonDecode(manga.metadata!));
      } catch (e) {
        log('Failed to parse manga metadata: $e');
      }
    }

    return model.Manga(
      id: manga.id,
      title: manga.title,
      libraryId: manga.libraryId,
      path: manga.filePath ?? '',
      type: model.MangaType.values.firstWhere(
        (e) => e.toString() == manga.type,
        orElse: () => model.MangaType.folder,
      ),
      subtitle: manga.subtitle,
      author: manga.author,
      description: manga.description,
      coverPath: manga.coverPath,
      tags: tags,
      status: model.MangaStatus.values.firstWhere(
        (e) => e.toString() == manga.status,
        orElse: () => model.MangaStatus.unknown,
      ),
      totalPages: manga.totalPages,
      currentPage: manga.currentPage,
      rating: manga.rating,
      source: manga.source,
      sourceUrl: manga.sourceUrl,
      lastReadAt: manga.lastReadAt != null
          ? DateTime.tryParse(manga.lastReadAt!)
          : null,
      createdAt: manga.createdAt,
      updatedAt: manga.updatedAt,
      isFavorite: manga.isFavorite,
      isCompleted: manga.isCompleted,
      fileSize: manga.fileSize,
      metadata: metadata,
    );
  }

  /// Convert Drift ReadingProgress to domain model
  static rp_model.ReadingProgress _readingProgressFromDrift(
      ReadingProgressesData progress) {
    return rp_model.ReadingProgress(
      id: progress.id,
      mangaId: progress.mangaId,
      libraryId: progress.libraryId,
      currentPage: progress.currentPage,
      totalPages: progress.totalPages,
      progressPercentage: progress.progressPercentage,
      lastReadAt: progress.lastReadAt,
      createdAt: progress.createdAt,
      updatedAt: progress.updatedAt,
    );
  }

  /// Convert Drift MangaPage to domain model
  static page_model.MangaPage _pageFromDrift(MangaPage page) {
    return page_model.MangaPage(
      id: page.id,
      mangaId: page.mangaId,
      pageIndex: page.pageIndex,
      localPath: page.localPath ?? '',
      largeThumbnail: page.largeThumbnail,
      mediumThumbnail: page.mediumThumbnail,
      smallThumbnail: page.smallThumbnail,
    );
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/library.dart';
import '../models/manga.dart' as model;
import '../models/manga_page.dart' as model;

/// Isolate-specific database service using Drift
class DriftIsolateDatabaseService {
  final AppDatabase _database;

  DriftIsolateDatabaseService(this._database);

  /// Create instance for isolate use
  static Future<DriftIsolateDatabaseService> create() async {
    final database = await AppDatabase.createForIsolate();
    return DriftIsolateDatabaseService(database);
  }

  /// Close database connection
  Future<void> close() async {
    await _database.close();
  }

  // ==================== Library Operations ====================

  /// Get library by ID
  Future<MangaLibrary?> getLibraryById(String id) async {
    try {
      final query = _database.select(_database.libraries)
        ..where((tbl) => tbl.id.equals(id));
      final library = await query.getSingleOrNull();
      return library != null ? _libraryFromDrift(library) : null;
    } catch (e) {
      log('Error getting library by ID in isolate: $e');
      rethrow;
    }
  }

  // ==================== Manga Operations ====================

  /// Get manga by ID
  Future<model.Manga?> getMangaById(String id) async {
    try {
      final query = _database.select(_database.mangas)
        ..where((tbl) => tbl.id.equals(id));
      final manga = await query.getSingleOrNull();
      return manga != null ? _mangaFromDrift(manga) : null;
    } catch (e) {
      log('Error getting manga by ID in isolate: $e');
      rethrow;
    }
  }

  /// Update manga
  Future<void> updateManga(model.Manga manga) async {
    try {
      await (_database.update(_database.mangas)
            ..where((tbl) => tbl.id.equals(manga.id)))
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
    } catch (e) {
      log('Error updating manga in isolate: $e');
      rethrow;
    }
  }

  // ==================== Page Operations ====================

  /// Insert manga
  Future<void> insertManga(model.Manga manga) async {
    try {
      await _database.into(_database.mangas).insert(
            MangasCompanion.insert(
              id: manga.id,
              title: manga.title,
              author: Value(manga.author),
              description: Value(manga.description),
              coverPath: Value(manga.coverPath),
              filePath: Value(manga
                  .path), // Use 'path' field from domain model and wrap in Value
              type: Value(manga.type.index
                  .toString()), // Convert to string and wrap in Value
              libraryId: manga.libraryId,
              totalPages: Value(manga.totalPages),
              currentPage: Value(manga.currentPage),
              lastReadAt: Value(manga.lastReadAt
                  ?.toIso8601String()), // Convert DateTime to ISO string
              isFavorite: Value(manga.isFavorite),
              tags: Value(manga.tags
                  .join(',')), // Remove null check since tags is non-nullable
              rating: Value(manga.rating),
              createdAt: manga.createdAt ??
                  DateTime.now(), // Remove Value wrapper for DateTimeColumn
              updatedAt: Value(manga.updatedAt ??
                  DateTime
                      .now()), // Keep Value wrapper for nullable DateTimeColumn
            ),
          );
    } catch (e) {
      log('Error inserting manga in isolate: $e');
      rethrow;
    }
  }

  /// Insert manga page
  Future<void> insertPage(model.MangaPage page) async {
    try {
      await _database.into(_database.mangaPages).insert(
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
    } catch (e) {
      log('Error inserting page in isolate: $e');
      rethrow;
    }
  }

  /// Update page thumbnails
  Future<void> updatePageThumbnails(
    String pageId, {
    String? largeThumbnail,
    String? mediumThumbnail,
    String? smallThumbnail,
  }) async {
    try {
      await (_database.update(_database.mangaPages)
            ..where((tbl) => tbl.id.equals(pageId)))
          .write(MangaPagesCompanion(
        largeThumbnail: Value(largeThumbnail),
        mediumThumbnail: Value(mediumThumbnail),
        smallThumbnail: Value(smallThumbnail),
      ));
    } catch (e) {
      log('Error updating page thumbnails in isolate: $e');
      rethrow;
    }
  }

  /// Update page
  Future<void> updatePage(model.MangaPage page) async {
    try {
      await (_database.update(_database.mangaPages)
            ..where((tbl) => tbl.id.equals(page.id)))
          .write(MangaPagesCompanion(
        mangaId: Value(page.mangaId),
        pageIndex: Value(page.pageIndex), // Use pageIndex instead of pageNumber
        localPath: Value(page.localPath), // Use localPath instead of filePath
        largeThumbnail: Value(page.largeThumbnail),
        mediumThumbnail: Value(page.mediumThumbnail),
        smallThumbnail: Value(page.smallThumbnail),
      ));
    } catch (e) {
      log('Error updating page in isolate: $e');
      rethrow;
    }
  }

  /// Insert page list
  Future<void> insertPageList(List<model.MangaPage> pages) async {
    try {
      await _database.batch((batch) {
        for (final page in pages) {
          batch.insert(
            _database.mangaPages,
            MangaPagesCompanion(
              id: Value(page.id),
              mangaId: Value(page.mangaId),
              pageIndex:
                  Value(page.pageIndex), // Use pageIndex instead of pageNumber
              localPath:
                  Value(page.localPath), // Use localPath instead of filePath
              largeThumbnail: Value(page.largeThumbnail),
              mediumThumbnail: Value(page.mediumThumbnail),
              smallThumbnail: Value(page.smallThumbnail),
            ),
          );
        }
      });
    } catch (e) {
      log('Error inserting page list in isolate: $e');
      rethrow;
    }
  }

  /// Update page list
  Future<void> updatePageList(List<model.MangaPage> pages) async {
    try {
      await _database.batch((batch) {
        for (final page in pages) {
          batch.update(
            _database.mangaPages,
            MangaPagesCompanion(
              mangaId: Value(page.mangaId),
              pageIndex:
                  Value(page.pageIndex), // Use pageIndex instead of pageNumber
              localPath:
                  Value(page.localPath), // Use localPath instead of filePath
              largeThumbnail: Value(page.largeThumbnail),
              mediumThumbnail: Value(page.mediumThumbnail),
              smallThumbnail: Value(page.smallThumbnail),
            ),
            where: (tbl) => tbl.id.equals(page.id),
          );
        }
      });
    } catch (e) {
      log('Error updating page list in isolate: $e');
      rethrow;
    }
  }

  /// Get pages by manga ID
  Future<List<model.MangaPage>> getPagesByMangaId(String mangaId) async {
    try {
      final query = _database.select(_database.mangaPages)
        ..where((tbl) => tbl.mangaId.equals(mangaId))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.pageIndex)]);

      final pages = await query.get();
      return pages.map(_pageFromDrift).toList();
    } catch (e) {
      log('Error getting pages by manga ID in isolate: $e');
      rethrow;
    }
  }

  /// Batch insert pages
  Future<void> batchInsertPages(List<model.MangaPage> pages) async {
    try {
      await _database.batch((batch) {
        for (final page in pages) {
          batch.insert(
            _database.mangaPages,
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
      });
    } catch (e) {
      log('Error batch inserting pages in isolate: $e');
    }
  }

  // ==================== Helper Methods ====================

  /// Convert Drift Library to domain model
  MangaLibrary _libraryFromDrift(Library library) {
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
    );
  }

  /// Convert Drift Manga to domain model
  model.Manga _mangaFromDrift(Manga manga) {
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

  /// Convert Drift MangaPage to domain model
  model.MangaPage _pageFromDrift(MangaPage page) {
    return model.MangaPage(
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

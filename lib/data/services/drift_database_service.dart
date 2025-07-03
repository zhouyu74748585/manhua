import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/library.dart';
import '../models/manga.dart' as model;

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

  /// Get manga by ID
  static Future<model.Manga?> getMangaById(String id) async {
    final db = database;
    final query = db.select(db.mangas)..where((tbl) => tbl.id.equals(id));
    final manga = await query.getSingleOrNull();
    return manga != null ? _mangaFromDrift(manga) : null;
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
}

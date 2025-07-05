import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Libraries,
  Mangas,
  MangaPages,
  ReadingProgresses,
  Devices,
  SyncSessions,
  SyncConflicts
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forIsolate(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2 && to >= 2) {
          // Add new columns for version 2
          await m.addColumn(libraries, libraries.isScanning);
          await m.addColumn(libraries, libraries.isPrivate);
          await m.addColumn(libraries, libraries.isPrivateActivated);
        }
        if (from < 3 && to >= 3) {
          // Add new tables for version 3 (multi-device sharing)
          await m.createTable(devices);
          await m.createTable(syncSessions);
          await m.createTable(syncConflicts);
        }
      },
    );
  }

  /// Create database indexes for better performance
  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_manga_library_id ON mangas (library_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_manga_title ON mangas (title)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_manga_is_favorite ON mangas (is_favorite)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_page_manga_id ON manga_pages (manga_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_reading_progress_manga_id ON reading_progresses (manga_id)');
  }

  /// Get database path for sharing across isolates
  static Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return p.join(documentsDirectory.path, 'manhua_reader.db');
  }

  /// Create a database connection that can be shared across isolates
  static Future<DatabaseConnection> createConnection() async {
    final dbPath = await getDatabasePath();
    return DatabaseConnection.delayed(Future(() async {
      // Ensure sqlite3 is properly initialized on all platforms
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Open database with WAL mode and concurrency settings
      final database = sqlite3.open(
        dbPath,
        mode: OpenMode.readWriteCreate,
      );

      // Configure for concurrent access
      database.execute('PRAGMA journal_mode = WAL');
      database.execute('PRAGMA busy_timeout = 60000');
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA synchronous = NORMAL');
      database.execute('PRAGMA cache_size = 10000');
      database.execute('PRAGMA temp_store = memory');
      database.execute('PRAGMA wal_autocheckpoint = 1000');

      return DatabaseConnection(NativeDatabase.opened(database));
    }));
  }

  /// Create database instance for isolates
  static Future<AppDatabase> createForIsolate() async {
    final connection = await createConnection();
    return AppDatabase.forIsolate(connection);
  }
}

/// Open database connection for main thread
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final connection = await AppDatabase.createConnection();
    return connection;
  });
}

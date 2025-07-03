import 'package:drift/drift.dart';

/// Library table definition
class Libraries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get path => text().unique()();
  TextColumn get type => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastScanAt => dateTime().nullable()();
  IntColumn get mangaCount => integer().withDefault(const Constant(0))();
  TextColumn get settings => text().nullable()();
  BoolColumn get isScanning => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrivateActivated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Manga table definition
class Mangas extends Table {
  TextColumn get id => text()();
  TextColumn get libraryId => text().references(Libraries, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON string
  TextColumn get status => text().nullable()();
  TextColumn get type => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  RealColumn get rating => real().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get lastReadAt => text().nullable()(); // ISO string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get readingProgress => text().nullable()(); // JSON string
  TextColumn get filePath => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON string

  @override
  Set<Column> get primaryKey => {id};
}

/// Manga pages table definition
class MangaPages extends Table {
  TextColumn get id => text()();
  TextColumn get mangaId => text().references(Mangas, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageIndex => integer()();
  TextColumn get localPath => text().nullable()();
  TextColumn get largeThumbnail => text().nullable()();
  TextColumn get mediumThumbnail => text().nullable()();
  TextColumn get smallThumbnail => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reading progress table definition
class ReadingProgresses extends Table {
  TextColumn get id => text()();
  TextColumn get mangaId => text().references(Mangas, #id, onDelete: KeyAction.cascade)();
  TextColumn get libraryId => text()();
  IntColumn get currentPage => integer().withDefault(const Constant(1))();
  IntColumn get totalPages => integer().withDefault(const Constant(1))();
  RealColumn get progressPercentage => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastReadAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

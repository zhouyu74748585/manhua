// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibrariesTable extends Libraries
    with TableInfo<$LibrariesTable, Library> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibrariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastScanAtMeta =
      const VerificationMeta('lastScanAt');
  @override
  late final GeneratedColumn<DateTime> lastScanAt = GeneratedColumn<DateTime>(
      'last_scan_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _mangaCountMeta =
      const VerificationMeta('mangaCount');
  @override
  late final GeneratedColumn<int> mangaCount = GeneratedColumn<int>(
      'manga_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _settingsMeta =
      const VerificationMeta('settings');
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
      'settings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isScanningMeta =
      const VerificationMeta('isScanning');
  @override
  late final GeneratedColumn<bool> isScanning = GeneratedColumn<bool>(
      'is_scanning', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_scanning" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPrivateMeta =
      const VerificationMeta('isPrivate');
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
      'is_private', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_private" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPrivateActivatedMeta =
      const VerificationMeta('isPrivateActivated');
  @override
  late final GeneratedColumn<bool> isPrivateActivated = GeneratedColumn<bool>(
      'is_private_activated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_private_activated" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        path,
        type,
        isEnabled,
        createdAt,
        lastScanAt,
        mangaCount,
        settings,
        isScanning,
        isPrivate,
        isPrivateActivated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'libraries';
  @override
  VerificationContext validateIntegrity(Insertable<Library> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_scan_at')) {
      context.handle(
          _lastScanAtMeta,
          lastScanAt.isAcceptableOrUnknown(
              data['last_scan_at']!, _lastScanAtMeta));
    }
    if (data.containsKey('manga_count')) {
      context.handle(
          _mangaCountMeta,
          mangaCount.isAcceptableOrUnknown(
              data['manga_count']!, _mangaCountMeta));
    }
    if (data.containsKey('settings')) {
      context.handle(_settingsMeta,
          settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta));
    }
    if (data.containsKey('is_scanning')) {
      context.handle(
          _isScanningMeta,
          isScanning.isAcceptableOrUnknown(
              data['is_scanning']!, _isScanningMeta));
    }
    if (data.containsKey('is_private')) {
      context.handle(_isPrivateMeta,
          isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta));
    }
    if (data.containsKey('is_private_activated')) {
      context.handle(
          _isPrivateActivatedMeta,
          isPrivateActivated.isAcceptableOrUnknown(
              data['is_private_activated']!, _isPrivateActivatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Library map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Library(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastScanAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_scan_at']),
      mangaCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}manga_count'])!,
      settings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings']),
      isScanning: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_scanning'])!,
      isPrivate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_private'])!,
      isPrivateActivated: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_private_activated'])!,
    );
  }

  @override
  $LibrariesTable createAlias(String alias) {
    return $LibrariesTable(attachedDatabase, alias);
  }
}

class Library extends DataClass implements Insertable<Library> {
  final String id;
  final String name;
  final String path;
  final String type;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastScanAt;
  final int mangaCount;
  final String? settings;
  final bool isScanning;
  final bool isPrivate;
  final bool isPrivateActivated;
  const Library(
      {required this.id,
      required this.name,
      required this.path,
      required this.type,
      required this.isEnabled,
      required this.createdAt,
      this.lastScanAt,
      required this.mangaCount,
      this.settings,
      required this.isScanning,
      required this.isPrivate,
      required this.isPrivateActivated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['type'] = Variable<String>(type);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastScanAt != null) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt);
    }
    map['manga_count'] = Variable<int>(mangaCount);
    if (!nullToAbsent || settings != null) {
      map['settings'] = Variable<String>(settings);
    }
    map['is_scanning'] = Variable<bool>(isScanning);
    map['is_private'] = Variable<bool>(isPrivate);
    map['is_private_activated'] = Variable<bool>(isPrivateActivated);
    return map;
  }

  LibrariesCompanion toCompanion(bool nullToAbsent) {
    return LibrariesCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      type: Value(type),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      lastScanAt: lastScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanAt),
      mangaCount: Value(mangaCount),
      settings: settings == null && nullToAbsent
          ? const Value.absent()
          : Value(settings),
      isScanning: Value(isScanning),
      isPrivate: Value(isPrivate),
      isPrivateActivated: Value(isPrivateActivated),
    );
  }

  factory Library.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Library(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      type: serializer.fromJson<String>(json['type']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastScanAt: serializer.fromJson<DateTime?>(json['lastScanAt']),
      mangaCount: serializer.fromJson<int>(json['mangaCount']),
      settings: serializer.fromJson<String?>(json['settings']),
      isScanning: serializer.fromJson<bool>(json['isScanning']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      isPrivateActivated: serializer.fromJson<bool>(json['isPrivateActivated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'type': serializer.toJson<String>(type),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastScanAt': serializer.toJson<DateTime?>(lastScanAt),
      'mangaCount': serializer.toJson<int>(mangaCount),
      'settings': serializer.toJson<String?>(settings),
      'isScanning': serializer.toJson<bool>(isScanning),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'isPrivateActivated': serializer.toJson<bool>(isPrivateActivated),
    };
  }

  Library copyWith(
          {String? id,
          String? name,
          String? path,
          String? type,
          bool? isEnabled,
          DateTime? createdAt,
          Value<DateTime?> lastScanAt = const Value.absent(),
          int? mangaCount,
          Value<String?> settings = const Value.absent(),
          bool? isScanning,
          bool? isPrivate,
          bool? isPrivateActivated}) =>
      Library(
        id: id ?? this.id,
        name: name ?? this.name,
        path: path ?? this.path,
        type: type ?? this.type,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        lastScanAt: lastScanAt.present ? lastScanAt.value : this.lastScanAt,
        mangaCount: mangaCount ?? this.mangaCount,
        settings: settings.present ? settings.value : this.settings,
        isScanning: isScanning ?? this.isScanning,
        isPrivate: isPrivate ?? this.isPrivate,
        isPrivateActivated: isPrivateActivated ?? this.isPrivateActivated,
      );
  Library copyWithCompanion(LibrariesCompanion data) {
    return Library(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      type: data.type.present ? data.type.value : this.type,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastScanAt:
          data.lastScanAt.present ? data.lastScanAt.value : this.lastScanAt,
      mangaCount:
          data.mangaCount.present ? data.mangaCount.value : this.mangaCount,
      settings: data.settings.present ? data.settings.value : this.settings,
      isScanning:
          data.isScanning.present ? data.isScanning.value : this.isScanning,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      isPrivateActivated: data.isPrivateActivated.present
          ? data.isPrivateActivated.value
          : this.isPrivateActivated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Library(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastScanAt: $lastScanAt, ')
          ..write('mangaCount: $mangaCount, ')
          ..write('settings: $settings, ')
          ..write('isScanning: $isScanning, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isPrivateActivated: $isPrivateActivated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      path,
      type,
      isEnabled,
      createdAt,
      lastScanAt,
      mangaCount,
      settings,
      isScanning,
      isPrivate,
      isPrivateActivated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Library &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.type == this.type &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.lastScanAt == this.lastScanAt &&
          other.mangaCount == this.mangaCount &&
          other.settings == this.settings &&
          other.isScanning == this.isScanning &&
          other.isPrivate == this.isPrivate &&
          other.isPrivateActivated == this.isPrivateActivated);
}

class LibrariesCompanion extends UpdateCompanion<Library> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> path;
  final Value<String> type;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastScanAt;
  final Value<int> mangaCount;
  final Value<String?> settings;
  final Value<bool> isScanning;
  final Value<bool> isPrivate;
  final Value<bool> isPrivateActivated;
  final Value<int> rowid;
  const LibrariesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.type = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastScanAt = const Value.absent(),
    this.mangaCount = const Value.absent(),
    this.settings = const Value.absent(),
    this.isScanning = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.isPrivateActivated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibrariesCompanion.insert({
    required String id,
    required String name,
    required String path,
    required String type,
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    this.lastScanAt = const Value.absent(),
    this.mangaCount = const Value.absent(),
    this.settings = const Value.absent(),
    this.isScanning = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.isPrivateActivated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        path = Value(path),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Library> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? type,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastScanAt,
    Expression<int>? mangaCount,
    Expression<String>? settings,
    Expression<bool>? isScanning,
    Expression<bool>? isPrivate,
    Expression<bool>? isPrivateActivated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (type != null) 'type': type,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (lastScanAt != null) 'last_scan_at': lastScanAt,
      if (mangaCount != null) 'manga_count': mangaCount,
      if (settings != null) 'settings': settings,
      if (isScanning != null) 'is_scanning': isScanning,
      if (isPrivate != null) 'is_private': isPrivate,
      if (isPrivateActivated != null)
        'is_private_activated': isPrivateActivated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibrariesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? path,
      Value<String>? type,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastScanAt,
      Value<int>? mangaCount,
      Value<String?>? settings,
      Value<bool>? isScanning,
      Value<bool>? isPrivate,
      Value<bool>? isPrivateActivated,
      Value<int>? rowid}) {
    return LibrariesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      mangaCount: mangaCount ?? this.mangaCount,
      settings: settings ?? this.settings,
      isScanning: isScanning ?? this.isScanning,
      isPrivate: isPrivate ?? this.isPrivate,
      isPrivateActivated: isPrivateActivated ?? this.isPrivateActivated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastScanAt.present) {
      map['last_scan_at'] = Variable<DateTime>(lastScanAt.value);
    }
    if (mangaCount.present) {
      map['manga_count'] = Variable<int>(mangaCount.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (isScanning.present) {
      map['is_scanning'] = Variable<bool>(isScanning.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (isPrivateActivated.present) {
      map['is_private_activated'] = Variable<bool>(isPrivateActivated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibrariesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastScanAt: $lastScanAt, ')
          ..write('mangaCount: $mangaCount, ')
          ..write('settings: $settings, ')
          ..write('isScanning: $isScanning, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isPrivateActivated: $isPrivateActivated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangasTable extends Mangas with TableInfo<$MangasTable, Manga> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _libraryIdMeta =
      const VerificationMeta('libraryId');
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
      'library_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES libraries (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentPageMeta =
      const VerificationMeta('currentPage');
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
      'current_page', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<String> lastReadAt = GeneratedColumn<String>(
      'last_read_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _readingProgressMeta =
      const VerificationMeta('readingProgress');
  @override
  late final GeneratedColumn<String> readingProgress = GeneratedColumn<String>(
      'reading_progress', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        libraryId,
        title,
        subtitle,
        author,
        description,
        coverPath,
        tags,
        status,
        type,
        isFavorite,
        isCompleted,
        totalPages,
        currentPage,
        rating,
        source,
        sourceUrl,
        lastReadAt,
        createdAt,
        updatedAt,
        readingProgress,
        filePath,
        fileSize,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mangas';
  @override
  VerificationContext validateIntegrity(Insertable<Manga> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(_libraryIdMeta,
          libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta));
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('current_page')) {
      context.handle(
          _currentPageMeta,
          currentPage.isAcceptableOrUnknown(
              data['current_page']!, _currentPageMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('reading_progress')) {
      context.handle(
          _readingProgressMeta,
          readingProgress.isAcceptableOrUnknown(
              data['reading_progress']!, _readingProgressMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manga map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manga(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      libraryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}library_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      currentPage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_page'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_read_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      readingProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reading_progress']),
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $MangasTable createAlias(String alias) {
    return $MangasTable(attachedDatabase, alias);
  }
}

class Manga extends DataClass implements Insertable<Manga> {
  final String id;
  final String libraryId;
  final String title;
  final String? subtitle;
  final String? author;
  final String? description;
  final String? coverPath;
  final String? tags;
  final String? status;
  final String? type;
  final bool isFavorite;
  final bool isCompleted;
  final int totalPages;
  final int currentPage;
  final double? rating;
  final String? source;
  final String? sourceUrl;
  final String? lastReadAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? readingProgress;
  final String? filePath;
  final int? fileSize;
  final String? metadata;
  const Manga(
      {required this.id,
      required this.libraryId,
      required this.title,
      this.subtitle,
      this.author,
      this.description,
      this.coverPath,
      this.tags,
      this.status,
      this.type,
      required this.isFavorite,
      required this.isCompleted,
      required this.totalPages,
      required this.currentPage,
      this.rating,
      this.source,
      this.sourceUrl,
      this.lastReadAt,
      required this.createdAt,
      this.updatedAt,
      this.readingProgress,
      this.filePath,
      this.fileSize,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['library_id'] = Variable<String>(libraryId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['total_pages'] = Variable<int>(totalPages);
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<String>(lastReadAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || readingProgress != null) {
      map['reading_progress'] = Variable<String>(readingProgress);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  MangasCompanion toCompanion(bool nullToAbsent) {
    return MangasCompanion(
      id: Value(id),
      libraryId: Value(libraryId),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      isFavorite: Value(isFavorite),
      isCompleted: Value(isCompleted),
      totalPages: Value(totalPages),
      currentPage: Value(currentPage),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      readingProgress: readingProgress == null && nullToAbsent
          ? const Value.absent()
          : Value(readingProgress),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory Manga.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manga(
      id: serializer.fromJson<String>(json['id']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      tags: serializer.fromJson<String?>(json['tags']),
      status: serializer.fromJson<String?>(json['status']),
      type: serializer.fromJson<String?>(json['type']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      rating: serializer.fromJson<double?>(json['rating']),
      source: serializer.fromJson<String?>(json['source']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      lastReadAt: serializer.fromJson<String?>(json['lastReadAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      readingProgress: serializer.fromJson<String?>(json['readingProgress']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'libraryId': serializer.toJson<String>(libraryId),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'coverPath': serializer.toJson<String?>(coverPath),
      'tags': serializer.toJson<String?>(tags),
      'status': serializer.toJson<String?>(status),
      'type': serializer.toJson<String?>(type),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'totalPages': serializer.toJson<int>(totalPages),
      'currentPage': serializer.toJson<int>(currentPage),
      'rating': serializer.toJson<double?>(rating),
      'source': serializer.toJson<String?>(source),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'lastReadAt': serializer.toJson<String?>(lastReadAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'readingProgress': serializer.toJson<String?>(readingProgress),
      'filePath': serializer.toJson<String?>(filePath),
      'fileSize': serializer.toJson<int?>(fileSize),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  Manga copyWith(
          {String? id,
          String? libraryId,
          String? title,
          Value<String?> subtitle = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<String?> type = const Value.absent(),
          bool? isFavorite,
          bool? isCompleted,
          int? totalPages,
          int? currentPage,
          Value<double?> rating = const Value.absent(),
          Value<String?> source = const Value.absent(),
          Value<String?> sourceUrl = const Value.absent(),
          Value<String?> lastReadAt = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<String?> readingProgress = const Value.absent(),
          Value<String?> filePath = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          Value<String?> metadata = const Value.absent()}) =>
      Manga(
        id: id ?? this.id,
        libraryId: libraryId ?? this.libraryId,
        title: title ?? this.title,
        subtitle: subtitle.present ? subtitle.value : this.subtitle,
        author: author.present ? author.value : this.author,
        description: description.present ? description.value : this.description,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        tags: tags.present ? tags.value : this.tags,
        status: status.present ? status.value : this.status,
        type: type.present ? type.value : this.type,
        isFavorite: isFavorite ?? this.isFavorite,
        isCompleted: isCompleted ?? this.isCompleted,
        totalPages: totalPages ?? this.totalPages,
        currentPage: currentPage ?? this.currentPage,
        rating: rating.present ? rating.value : this.rating,
        source: source.present ? source.value : this.source,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        readingProgress: readingProgress.present
            ? readingProgress.value
            : this.readingProgress,
        filePath: filePath.present ? filePath.value : this.filePath,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  Manga copyWithCompanion(MangasCompanion data) {
    return Manga(
      id: data.id.present ? data.id.value : this.id,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      author: data.author.present ? data.author.value : this.author,
      description:
          data.description.present ? data.description.value : this.description,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      tags: data.tags.present ? data.tags.value : this.tags,
      status: data.status.present ? data.status.value : this.status,
      type: data.type.present ? data.type.value : this.type,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      currentPage:
          data.currentPage.present ? data.currentPage.value : this.currentPage,
      rating: data.rating.present ? data.rating.value : this.rating,
      source: data.source.present ? data.source.value : this.source,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      readingProgress: data.readingProgress.present
          ? data.readingProgress.value
          : this.readingProgress,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manga(')
          ..write('id: $id, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('rating: $rating, ')
          ..write('source: $source, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readingProgress: $readingProgress, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        libraryId,
        title,
        subtitle,
        author,
        description,
        coverPath,
        tags,
        status,
        type,
        isFavorite,
        isCompleted,
        totalPages,
        currentPage,
        rating,
        source,
        sourceUrl,
        lastReadAt,
        createdAt,
        updatedAt,
        readingProgress,
        filePath,
        fileSize,
        metadata
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manga &&
          other.id == this.id &&
          other.libraryId == this.libraryId &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.author == this.author &&
          other.description == this.description &&
          other.coverPath == this.coverPath &&
          other.tags == this.tags &&
          other.status == this.status &&
          other.type == this.type &&
          other.isFavorite == this.isFavorite &&
          other.isCompleted == this.isCompleted &&
          other.totalPages == this.totalPages &&
          other.currentPage == this.currentPage &&
          other.rating == this.rating &&
          other.source == this.source &&
          other.sourceUrl == this.sourceUrl &&
          other.lastReadAt == this.lastReadAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.readingProgress == this.readingProgress &&
          other.filePath == this.filePath &&
          other.fileSize == this.fileSize &&
          other.metadata == this.metadata);
}

class MangasCompanion extends UpdateCompanion<Manga> {
  final Value<String> id;
  final Value<String> libraryId;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> coverPath;
  final Value<String?> tags;
  final Value<String?> status;
  final Value<String?> type;
  final Value<bool> isFavorite;
  final Value<bool> isCompleted;
  final Value<int> totalPages;
  final Value<int> currentPage;
  final Value<double?> rating;
  final Value<String?> source;
  final Value<String?> sourceUrl;
  final Value<String?> lastReadAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> readingProgress;
  final Value<String?> filePath;
  final Value<int?> fileSize;
  final Value<String?> metadata;
  final Value<int> rowid;
  const MangasCompanion({
    this.id = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.rating = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readingProgress = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangasCompanion.insert({
    required String id,
    required String libraryId,
    required String title,
    this.subtitle = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.rating = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.readingProgress = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        libraryId = Value(libraryId),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Manga> custom({
    Expression<String>? id,
    Expression<String>? libraryId,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? coverPath,
    Expression<String>? tags,
    Expression<String>? status,
    Expression<String>? type,
    Expression<bool>? isFavorite,
    Expression<bool>? isCompleted,
    Expression<int>? totalPages,
    Expression<int>? currentPage,
    Expression<double>? rating,
    Expression<String>? source,
    Expression<String>? sourceUrl,
    Expression<String>? lastReadAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? readingProgress,
    Expression<String>? filePath,
    Expression<int>? fileSize,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (libraryId != null) 'library_id': libraryId,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (coverPath != null) 'cover_path': coverPath,
      if (tags != null) 'tags': tags,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (totalPages != null) 'total_pages': totalPages,
      if (currentPage != null) 'current_page': currentPage,
      if (rating != null) 'rating': rating,
      if (source != null) 'source': source,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (readingProgress != null) 'reading_progress': readingProgress,
      if (filePath != null) 'file_path': filePath,
      if (fileSize != null) 'file_size': fileSize,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangasCompanion copyWith(
      {Value<String>? id,
      Value<String>? libraryId,
      Value<String>? title,
      Value<String?>? subtitle,
      Value<String?>? author,
      Value<String?>? description,
      Value<String?>? coverPath,
      Value<String?>? tags,
      Value<String?>? status,
      Value<String?>? type,
      Value<bool>? isFavorite,
      Value<bool>? isCompleted,
      Value<int>? totalPages,
      Value<int>? currentPage,
      Value<double?>? rating,
      Value<String?>? source,
      Value<String?>? sourceUrl,
      Value<String?>? lastReadAt,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String?>? readingProgress,
      Value<String?>? filePath,
      Value<int?>? fileSize,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return MangasCompanion(
      id: id ?? this.id,
      libraryId: libraryId ?? this.libraryId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readingProgress: readingProgress ?? this.readingProgress,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<String>(lastReadAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (readingProgress.present) {
      map['reading_progress'] = Variable<String>(readingProgress.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangasCompanion(')
          ..write('id: $id, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('rating: $rating, ')
          ..write('source: $source, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readingProgress: $readingProgress, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaPagesTable extends MangaPages
    with TableInfo<$MangaPagesTable, MangaPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mangas (id) ON DELETE CASCADE'));
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _largeThumbnailMeta =
      const VerificationMeta('largeThumbnail');
  @override
  late final GeneratedColumn<String> largeThumbnail = GeneratedColumn<String>(
      'large_thumbnail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediumThumbnailMeta =
      const VerificationMeta('mediumThumbnail');
  @override
  late final GeneratedColumn<String> mediumThumbnail = GeneratedColumn<String>(
      'medium_thumbnail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _smallThumbnailMeta =
      const VerificationMeta('smallThumbnail');
  @override
  late final GeneratedColumn<String> smallThumbnail = GeneratedColumn<String>(
      'small_thumbnail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mangaId,
        pageIndex,
        localPath,
        largeThumbnail,
        mediumThumbnail,
        smallThumbnail
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_pages';
  @override
  VerificationContext validateIntegrity(Insertable<MangaPage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('large_thumbnail')) {
      context.handle(
          _largeThumbnailMeta,
          largeThumbnail.isAcceptableOrUnknown(
              data['large_thumbnail']!, _largeThumbnailMeta));
    }
    if (data.containsKey('medium_thumbnail')) {
      context.handle(
          _mediumThumbnailMeta,
          mediumThumbnail.isAcceptableOrUnknown(
              data['medium_thumbnail']!, _mediumThumbnailMeta));
    }
    if (data.containsKey('small_thumbnail')) {
      context.handle(
          _smallThumbnailMeta,
          smallThumbnail.isAcceptableOrUnknown(
              data['small_thumbnail']!, _smallThumbnailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaPage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      largeThumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}large_thumbnail']),
      mediumThumbnail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medium_thumbnail']),
      smallThumbnail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}small_thumbnail']),
    );
  }

  @override
  $MangaPagesTable createAlias(String alias) {
    return $MangaPagesTable(attachedDatabase, alias);
  }
}

class MangaPage extends DataClass implements Insertable<MangaPage> {
  final String id;
  final String mangaId;
  final int pageIndex;
  final String? localPath;
  final String? largeThumbnail;
  final String? mediumThumbnail;
  final String? smallThumbnail;
  const MangaPage(
      {required this.id,
      required this.mangaId,
      required this.pageIndex,
      this.localPath,
      this.largeThumbnail,
      this.mediumThumbnail,
      this.smallThumbnail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['manga_id'] = Variable<String>(mangaId);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || largeThumbnail != null) {
      map['large_thumbnail'] = Variable<String>(largeThumbnail);
    }
    if (!nullToAbsent || mediumThumbnail != null) {
      map['medium_thumbnail'] = Variable<String>(mediumThumbnail);
    }
    if (!nullToAbsent || smallThumbnail != null) {
      map['small_thumbnail'] = Variable<String>(smallThumbnail);
    }
    return map;
  }

  MangaPagesCompanion toCompanion(bool nullToAbsent) {
    return MangaPagesCompanion(
      id: Value(id),
      mangaId: Value(mangaId),
      pageIndex: Value(pageIndex),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      largeThumbnail: largeThumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(largeThumbnail),
      mediumThumbnail: mediumThumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(mediumThumbnail),
      smallThumbnail: smallThumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(smallThumbnail),
    );
  }

  factory MangaPage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaPage(
      id: serializer.fromJson<String>(json['id']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      largeThumbnail: serializer.fromJson<String?>(json['largeThumbnail']),
      mediumThumbnail: serializer.fromJson<String?>(json['mediumThumbnail']),
      smallThumbnail: serializer.fromJson<String?>(json['smallThumbnail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mangaId': serializer.toJson<String>(mangaId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'localPath': serializer.toJson<String?>(localPath),
      'largeThumbnail': serializer.toJson<String?>(largeThumbnail),
      'mediumThumbnail': serializer.toJson<String?>(mediumThumbnail),
      'smallThumbnail': serializer.toJson<String?>(smallThumbnail),
    };
  }

  MangaPage copyWith(
          {String? id,
          String? mangaId,
          int? pageIndex,
          Value<String?> localPath = const Value.absent(),
          Value<String?> largeThumbnail = const Value.absent(),
          Value<String?> mediumThumbnail = const Value.absent(),
          Value<String?> smallThumbnail = const Value.absent()}) =>
      MangaPage(
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
        pageIndex: pageIndex ?? this.pageIndex,
        localPath: localPath.present ? localPath.value : this.localPath,
        largeThumbnail:
            largeThumbnail.present ? largeThumbnail.value : this.largeThumbnail,
        mediumThumbnail: mediumThumbnail.present
            ? mediumThumbnail.value
            : this.mediumThumbnail,
        smallThumbnail:
            smallThumbnail.present ? smallThumbnail.value : this.smallThumbnail,
      );
  MangaPage copyWithCompanion(MangaPagesCompanion data) {
    return MangaPage(
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      largeThumbnail: data.largeThumbnail.present
          ? data.largeThumbnail.value
          : this.largeThumbnail,
      mediumThumbnail: data.mediumThumbnail.present
          ? data.mediumThumbnail.value
          : this.mediumThumbnail,
      smallThumbnail: data.smallThumbnail.present
          ? data.smallThumbnail.value
          : this.smallThumbnail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaPage(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('localPath: $localPath, ')
          ..write('largeThumbnail: $largeThumbnail, ')
          ..write('mediumThumbnail: $mediumThumbnail, ')
          ..write('smallThumbnail: $smallThumbnail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mangaId, pageIndex, localPath,
      largeThumbnail, mediumThumbnail, smallThumbnail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaPage &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.pageIndex == this.pageIndex &&
          other.localPath == this.localPath &&
          other.largeThumbnail == this.largeThumbnail &&
          other.mediumThumbnail == this.mediumThumbnail &&
          other.smallThumbnail == this.smallThumbnail);
}

class MangaPagesCompanion extends UpdateCompanion<MangaPage> {
  final Value<String> id;
  final Value<String> mangaId;
  final Value<int> pageIndex;
  final Value<String?> localPath;
  final Value<String?> largeThumbnail;
  final Value<String?> mediumThumbnail;
  final Value<String?> smallThumbnail;
  final Value<int> rowid;
  const MangaPagesCompanion({
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.localPath = const Value.absent(),
    this.largeThumbnail = const Value.absent(),
    this.mediumThumbnail = const Value.absent(),
    this.smallThumbnail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaPagesCompanion.insert({
    required String id,
    required String mangaId,
    required int pageIndex,
    this.localPath = const Value.absent(),
    this.largeThumbnail = const Value.absent(),
    this.mediumThumbnail = const Value.absent(),
    this.smallThumbnail = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mangaId = Value(mangaId),
        pageIndex = Value(pageIndex);
  static Insertable<MangaPage> custom({
    Expression<String>? id,
    Expression<String>? mangaId,
    Expression<int>? pageIndex,
    Expression<String>? localPath,
    Expression<String>? largeThumbnail,
    Expression<String>? mediumThumbnail,
    Expression<String>? smallThumbnail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (localPath != null) 'local_path': localPath,
      if (largeThumbnail != null) 'large_thumbnail': largeThumbnail,
      if (mediumThumbnail != null) 'medium_thumbnail': mediumThumbnail,
      if (smallThumbnail != null) 'small_thumbnail': smallThumbnail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaPagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? mangaId,
      Value<int>? pageIndex,
      Value<String?>? localPath,
      Value<String?>? largeThumbnail,
      Value<String?>? mediumThumbnail,
      Value<String?>? smallThumbnail,
      Value<int>? rowid}) {
    return MangaPagesCompanion(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      pageIndex: pageIndex ?? this.pageIndex,
      localPath: localPath ?? this.localPath,
      largeThumbnail: largeThumbnail ?? this.largeThumbnail,
      mediumThumbnail: mediumThumbnail ?? this.mediumThumbnail,
      smallThumbnail: smallThumbnail ?? this.smallThumbnail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (largeThumbnail.present) {
      map['large_thumbnail'] = Variable<String>(largeThumbnail.value);
    }
    if (mediumThumbnail.present) {
      map['medium_thumbnail'] = Variable<String>(mediumThumbnail.value);
    }
    if (smallThumbnail.present) {
      map['small_thumbnail'] = Variable<String>(smallThumbnail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaPagesCompanion(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('localPath: $localPath, ')
          ..write('largeThumbnail: $largeThumbnail, ')
          ..write('mediumThumbnail: $mediumThumbnail, ')
          ..write('smallThumbnail: $smallThumbnail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressesTable extends ReadingProgresses
    with TableInfo<$ReadingProgressesTable, ReadingProgressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mangas (id) ON DELETE CASCADE'));
  static const VerificationMeta _libraryIdMeta =
      const VerificationMeta('libraryId');
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
      'library_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentPageMeta =
      const VerificationMeta('currentPage');
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
      'current_page', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _progressPercentageMeta =
      const VerificationMeta('progressPercentage');
  @override
  late final GeneratedColumn<double> progressPercentage =
      GeneratedColumn<double>('progress_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
      'last_read_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mangaId,
        libraryId,
        currentPage,
        totalPages,
        progressPercentage,
        lastReadAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progresses';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingProgressesData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(_libraryIdMeta,
          libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta));
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('current_page')) {
      context.handle(
          _currentPageMeta,
          currentPage.isAcceptableOrUnknown(
              data['current_page']!, _currentPageMeta));
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('progress_percentage')) {
      context.handle(
          _progressPercentageMeta,
          progressPercentage.isAcceptableOrUnknown(
              data['progress_percentage']!, _progressPercentageMeta));
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    } else if (isInserting) {
      context.missing(_lastReadAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingProgressesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
      libraryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}library_id'])!,
      currentPage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_page'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      progressPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}progress_percentage'])!,
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_read_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingProgressesTable createAlias(String alias) {
    return $ReadingProgressesTable(attachedDatabase, alias);
  }
}

class ReadingProgressesData extends DataClass
    implements Insertable<ReadingProgressesData> {
  final String id;
  final String mangaId;
  final String libraryId;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime lastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReadingProgressesData(
      {required this.id,
      required this.mangaId,
      required this.libraryId,
      required this.currentPage,
      required this.totalPages,
      required this.progressPercentage,
      required this.lastReadAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['manga_id'] = Variable<String>(mangaId);
    map['library_id'] = Variable<String>(libraryId);
    map['current_page'] = Variable<int>(currentPage);
    map['total_pages'] = Variable<int>(totalPages);
    map['progress_percentage'] = Variable<double>(progressPercentage);
    map['last_read_at'] = Variable<DateTime>(lastReadAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressesCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressesCompanion(
      id: Value(id),
      mangaId: Value(mangaId),
      libraryId: Value(libraryId),
      currentPage: Value(currentPage),
      totalPages: Value(totalPages),
      progressPercentage: Value(progressPercentage),
      lastReadAt: Value(lastReadAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressesData(
      id: serializer.fromJson<String>(json['id']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      progressPercentage:
          serializer.fromJson<double>(json['progressPercentage']),
      lastReadAt: serializer.fromJson<DateTime>(json['lastReadAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mangaId': serializer.toJson<String>(mangaId),
      'libraryId': serializer.toJson<String>(libraryId),
      'currentPage': serializer.toJson<int>(currentPage),
      'totalPages': serializer.toJson<int>(totalPages),
      'progressPercentage': serializer.toJson<double>(progressPercentage),
      'lastReadAt': serializer.toJson<DateTime>(lastReadAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressesData copyWith(
          {String? id,
          String? mangaId,
          String? libraryId,
          int? currentPage,
          int? totalPages,
          double? progressPercentage,
          DateTime? lastReadAt,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ReadingProgressesData(
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
        libraryId: libraryId ?? this.libraryId,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        progressPercentage: progressPercentage ?? this.progressPercentage,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReadingProgressesData copyWithCompanion(ReadingProgressesCompanion data) {
    return ReadingProgressesData(
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      currentPage:
          data.currentPage.present ? data.currentPage.value : this.currentPage,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      progressPercentage: data.progressPercentage.present
          ? data.progressPercentage.value
          : this.progressPercentage,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressesData(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('libraryId: $libraryId, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalPages: $totalPages, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mangaId, libraryId, currentPage,
      totalPages, progressPercentage, lastReadAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressesData &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.libraryId == this.libraryId &&
          other.currentPage == this.currentPage &&
          other.totalPages == this.totalPages &&
          other.progressPercentage == this.progressPercentage &&
          other.lastReadAt == this.lastReadAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressesCompanion
    extends UpdateCompanion<ReadingProgressesData> {
  final Value<String> id;
  final Value<String> mangaId;
  final Value<String> libraryId;
  final Value<int> currentPage;
  final Value<int> totalPages;
  final Value<double> progressPercentage;
  final Value<DateTime> lastReadAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingProgressesCompanion({
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressesCompanion.insert({
    required String id,
    required String mangaId,
    required String libraryId,
    this.currentPage = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    required DateTime lastReadAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mangaId = Value(mangaId),
        libraryId = Value(libraryId),
        lastReadAt = Value(lastReadAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ReadingProgressesData> custom({
    Expression<String>? id,
    Expression<String>? mangaId,
    Expression<String>? libraryId,
    Expression<int>? currentPage,
    Expression<int>? totalPages,
    Expression<double>? progressPercentage,
    Expression<DateTime>? lastReadAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (libraryId != null) 'library_id': libraryId,
      if (currentPage != null) 'current_page': currentPage,
      if (totalPages != null) 'total_pages': totalPages,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressesCompanion copyWith(
      {Value<String>? id,
      Value<String>? mangaId,
      Value<String>? libraryId,
      Value<int>? currentPage,
      Value<int>? totalPages,
      Value<double>? progressPercentage,
      Value<DateTime>? lastReadAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReadingProgressesCompanion(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      libraryId: libraryId ?? this.libraryId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (progressPercentage.present) {
      map['progress_percentage'] = Variable<double>(progressPercentage.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressesCompanion(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('libraryId: $libraryId, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalPages: $totalPages, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ipAddressMeta =
      const VerificationMeta('ipAddress');
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
      'ip_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
      'port', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastSeenMeta =
      const VerificationMeta('lastSeen');
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
      'last_seen', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isOnlineMeta =
      const VerificationMeta('isOnline');
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
      'is_online', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_online" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _capabilitiesMeta =
      const VerificationMeta('capabilities');
  @override
  late final GeneratedColumn<String> capabilities = GeneratedColumn<String>(
      'capabilities', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        platform,
        version,
        ipAddress,
        port,
        lastSeen,
        isOnline,
        capabilities
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('ip_address')) {
      context.handle(_ipAddressMeta,
          ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta));
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta));
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('is_online')) {
      context.handle(_isOnlineMeta,
          isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta));
    }
    if (data.containsKey('capabilities')) {
      context.handle(
          _capabilitiesMeta,
          capabilities.isAcceptableOrUnknown(
              data['capabilities']!, _capabilitiesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      ipAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip_address'])!,
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port'])!,
      lastSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen'])!,
      isOnline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_online'])!,
      capabilities: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capabilities']),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String name;
  final String platform;
  final String version;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;
  final bool isOnline;
  final String? capabilities;
  const Device(
      {required this.id,
      required this.name,
      required this.platform,
      required this.version,
      required this.ipAddress,
      required this.port,
      required this.lastSeen,
      required this.isOnline,
      this.capabilities});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    map['version'] = Variable<String>(version);
    map['ip_address'] = Variable<String>(ipAddress);
    map['port'] = Variable<int>(port);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || capabilities != null) {
      map['capabilities'] = Variable<String>(capabilities);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      platform: Value(platform),
      version: Value(version),
      ipAddress: Value(ipAddress),
      port: Value(port),
      lastSeen: Value(lastSeen),
      isOnline: Value(isOnline),
      capabilities: capabilities == null && nullToAbsent
          ? const Value.absent()
          : Value(capabilities),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      version: serializer.fromJson<String>(json['version']),
      ipAddress: serializer.fromJson<String>(json['ipAddress']),
      port: serializer.fromJson<int>(json['port']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      capabilities: serializer.fromJson<String?>(json['capabilities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'version': serializer.toJson<String>(version),
      'ipAddress': serializer.toJson<String>(ipAddress),
      'port': serializer.toJson<int>(port),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
      'isOnline': serializer.toJson<bool>(isOnline),
      'capabilities': serializer.toJson<String?>(capabilities),
    };
  }

  Device copyWith(
          {String? id,
          String? name,
          String? platform,
          String? version,
          String? ipAddress,
          int? port,
          DateTime? lastSeen,
          bool? isOnline,
          Value<String?> capabilities = const Value.absent()}) =>
      Device(
        id: id ?? this.id,
        name: name ?? this.name,
        platform: platform ?? this.platform,
        version: version ?? this.version,
        ipAddress: ipAddress ?? this.ipAddress,
        port: port ?? this.port,
        lastSeen: lastSeen ?? this.lastSeen,
        isOnline: isOnline ?? this.isOnline,
        capabilities:
            capabilities.present ? capabilities.value : this.capabilities,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      version: data.version.present ? data.version.value : this.version,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      port: data.port.present ? data.port.value : this.port,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      capabilities: data.capabilities.present
          ? data.capabilities.value
          : this.capabilities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('version: $version, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('port: $port, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isOnline: $isOnline, ')
          ..write('capabilities: $capabilities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, platform, version, ipAddress, port,
      lastSeen, isOnline, capabilities);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.version == this.version &&
          other.ipAddress == this.ipAddress &&
          other.port == this.port &&
          other.lastSeen == this.lastSeen &&
          other.isOnline == this.isOnline &&
          other.capabilities == this.capabilities);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> platform;
  final Value<String> version;
  final Value<String> ipAddress;
  final Value<int> port;
  final Value<DateTime> lastSeen;
  final Value<bool> isOnline;
  final Value<String?> capabilities;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.version = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.port = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    required String platform,
    required String version,
    required String ipAddress,
    required int port,
    required DateTime lastSeen,
    this.isOnline = const Value.absent(),
    this.capabilities = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        platform = Value(platform),
        version = Value(version),
        ipAddress = Value(ipAddress),
        port = Value(port),
        lastSeen = Value(lastSeen);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? version,
    Expression<String>? ipAddress,
    Expression<int>? port,
    Expression<DateTime>? lastSeen,
    Expression<bool>? isOnline,
    Expression<String>? capabilities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (version != null) 'version': version,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (port != null) 'port': port,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (isOnline != null) 'is_online': isOnline,
      if (capabilities != null) 'capabilities': capabilities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? platform,
      Value<String>? version,
      Value<String>? ipAddress,
      Value<int>? port,
      Value<DateTime>? lastSeen,
      Value<bool>? isOnline,
      Value<String?>? capabilities,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      capabilities: capabilities ?? this.capabilities,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (capabilities.present) {
      map['capabilities'] = Variable<String>(capabilities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('version: $version, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('port: $port, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isOnline: $isOnline, ')
          ..write('capabilities: $capabilities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncSessionsTable extends SyncSessions
    with TableInfo<$SyncSessionsTable, SyncSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceDeviceIdMeta =
      const VerificationMeta('sourceDeviceId');
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
      'source_device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetDeviceIdMeta =
      const VerificationMeta('targetDeviceId');
  @override
  late final GeneratedColumn<String> targetDeviceId = GeneratedColumn<String>(
      'target_device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _libraryIdsMeta =
      const VerificationMeta('libraryIds');
  @override
  late final GeneratedColumn<String> libraryIds = GeneratedColumn<String>(
      'library_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _totalItemsMeta =
      const VerificationMeta('totalItems');
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
      'total_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _processedItemsMeta =
      const VerificationMeta('processedItems');
  @override
  late final GeneratedColumn<int> processedItems = GeneratedColumn<int>(
      'processed_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _failedItemsMeta =
      const VerificationMeta('failedItems');
  @override
  late final GeneratedColumn<int> failedItems = GeneratedColumn<int>(
      'failed_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceDeviceId,
        targetDeviceId,
        type,
        direction,
        status,
        libraryIds,
        startTime,
        endTime,
        totalItems,
        processedItems,
        failedItems,
        errorMessage,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SyncSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
          _sourceDeviceIdMeta,
          sourceDeviceId.isAcceptableOrUnknown(
              data['source_device_id']!, _sourceDeviceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceDeviceIdMeta);
    }
    if (data.containsKey('target_device_id')) {
      context.handle(
          _targetDeviceIdMeta,
          targetDeviceId.isAcceptableOrUnknown(
              data['target_device_id']!, _targetDeviceIdMeta));
    } else if (isInserting) {
      context.missing(_targetDeviceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('library_ids')) {
      context.handle(
          _libraryIdsMeta,
          libraryIds.isAcceptableOrUnknown(
              data['library_ids']!, _libraryIdsMeta));
    } else if (isInserting) {
      context.missing(_libraryIdsMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('total_items')) {
      context.handle(
          _totalItemsMeta,
          totalItems.isAcceptableOrUnknown(
              data['total_items']!, _totalItemsMeta));
    }
    if (data.containsKey('processed_items')) {
      context.handle(
          _processedItemsMeta,
          processedItems.isAcceptableOrUnknown(
              data['processed_items']!, _processedItemsMeta));
    }
    if (data.containsKey('failed_items')) {
      context.handle(
          _failedItemsMeta,
          failedItems.isAcceptableOrUnknown(
              data['failed_items']!, _failedItemsMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_device_id'])!,
      targetDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_device_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      libraryIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}library_ids'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      totalItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items'])!,
      processedItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}processed_items'])!,
      failedItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_items'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $SyncSessionsTable createAlias(String alias) {
    return $SyncSessionsTable(attachedDatabase, alias);
  }
}

class SyncSession extends DataClass implements Insertable<SyncSession> {
  final String id;
  final String sourceDeviceId;
  final String targetDeviceId;
  final String type;
  final String direction;
  final String status;
  final String libraryIds;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final String? errorMessage;
  final String? metadata;
  const SyncSession(
      {required this.id,
      required this.sourceDeviceId,
      required this.targetDeviceId,
      required this.type,
      required this.direction,
      required this.status,
      required this.libraryIds,
      required this.startTime,
      this.endTime,
      required this.totalItems,
      required this.processedItems,
      required this.failedItems,
      this.errorMessage,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_device_id'] = Variable<String>(sourceDeviceId);
    map['target_device_id'] = Variable<String>(targetDeviceId);
    map['type'] = Variable<String>(type);
    map['direction'] = Variable<String>(direction);
    map['status'] = Variable<String>(status);
    map['library_ids'] = Variable<String>(libraryIds);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['total_items'] = Variable<int>(totalItems);
    map['processed_items'] = Variable<int>(processedItems);
    map['failed_items'] = Variable<int>(failedItems);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  SyncSessionsCompanion toCompanion(bool nullToAbsent) {
    return SyncSessionsCompanion(
      id: Value(id),
      sourceDeviceId: Value(sourceDeviceId),
      targetDeviceId: Value(targetDeviceId),
      type: Value(type),
      direction: Value(direction),
      status: Value(status),
      libraryIds: Value(libraryIds),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      totalItems: Value(totalItems),
      processedItems: Value(processedItems),
      failedItems: Value(failedItems),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory SyncSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncSession(
      id: serializer.fromJson<String>(json['id']),
      sourceDeviceId: serializer.fromJson<String>(json['sourceDeviceId']),
      targetDeviceId: serializer.fromJson<String>(json['targetDeviceId']),
      type: serializer.fromJson<String>(json['type']),
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String>(json['status']),
      libraryIds: serializer.fromJson<String>(json['libraryIds']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      processedItems: serializer.fromJson<int>(json['processedItems']),
      failedItems: serializer.fromJson<int>(json['failedItems']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceDeviceId': serializer.toJson<String>(sourceDeviceId),
      'targetDeviceId': serializer.toJson<String>(targetDeviceId),
      'type': serializer.toJson<String>(type),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String>(status),
      'libraryIds': serializer.toJson<String>(libraryIds),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'totalItems': serializer.toJson<int>(totalItems),
      'processedItems': serializer.toJson<int>(processedItems),
      'failedItems': serializer.toJson<int>(failedItems),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  SyncSession copyWith(
          {String? id,
          String? sourceDeviceId,
          String? targetDeviceId,
          String? type,
          String? direction,
          String? status,
          String? libraryIds,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          int? totalItems,
          int? processedItems,
          int? failedItems,
          Value<String?> errorMessage = const Value.absent(),
          Value<String?> metadata = const Value.absent()}) =>
      SyncSession(
        id: id ?? this.id,
        sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
        targetDeviceId: targetDeviceId ?? this.targetDeviceId,
        type: type ?? this.type,
        direction: direction ?? this.direction,
        status: status ?? this.status,
        libraryIds: libraryIds ?? this.libraryIds,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        totalItems: totalItems ?? this.totalItems,
        processedItems: processedItems ?? this.processedItems,
        failedItems: failedItems ?? this.failedItems,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  SyncSession copyWithCompanion(SyncSessionsCompanion data) {
    return SyncSession(
      id: data.id.present ? data.id.value : this.id,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      targetDeviceId: data.targetDeviceId.present
          ? data.targetDeviceId.value
          : this.targetDeviceId,
      type: data.type.present ? data.type.value : this.type,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      libraryIds:
          data.libraryIds.present ? data.libraryIds.value : this.libraryIds,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      totalItems:
          data.totalItems.present ? data.totalItems.value : this.totalItems,
      processedItems: data.processedItems.present
          ? data.processedItems.value
          : this.processedItems,
      failedItems:
          data.failedItems.present ? data.failedItems.value : this.failedItems,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncSession(')
          ..write('id: $id, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('targetDeviceId: $targetDeviceId, ')
          ..write('type: $type, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('libraryIds: $libraryIds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalItems: $totalItems, ')
          ..write('processedItems: $processedItems, ')
          ..write('failedItems: $failedItems, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sourceDeviceId,
      targetDeviceId,
      type,
      direction,
      status,
      libraryIds,
      startTime,
      endTime,
      totalItems,
      processedItems,
      failedItems,
      errorMessage,
      metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncSession &&
          other.id == this.id &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.targetDeviceId == this.targetDeviceId &&
          other.type == this.type &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.libraryIds == this.libraryIds &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.totalItems == this.totalItems &&
          other.processedItems == this.processedItems &&
          other.failedItems == this.failedItems &&
          other.errorMessage == this.errorMessage &&
          other.metadata == this.metadata);
}

class SyncSessionsCompanion extends UpdateCompanion<SyncSession> {
  final Value<String> id;
  final Value<String> sourceDeviceId;
  final Value<String> targetDeviceId;
  final Value<String> type;
  final Value<String> direction;
  final Value<String> status;
  final Value<String> libraryIds;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> totalItems;
  final Value<int> processedItems;
  final Value<int> failedItems;
  final Value<String?> errorMessage;
  final Value<String?> metadata;
  final Value<int> rowid;
  const SyncSessionsCompanion({
    this.id = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.targetDeviceId = const Value.absent(),
    this.type = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.libraryIds = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.processedItems = const Value.absent(),
    this.failedItems = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncSessionsCompanion.insert({
    required String id,
    required String sourceDeviceId,
    required String targetDeviceId,
    required String type,
    required String direction,
    required String status,
    required String libraryIds,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.processedItems = const Value.absent(),
    this.failedItems = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceDeviceId = Value(sourceDeviceId),
        targetDeviceId = Value(targetDeviceId),
        type = Value(type),
        direction = Value(direction),
        status = Value(status),
        libraryIds = Value(libraryIds),
        startTime = Value(startTime);
  static Insertable<SyncSession> custom({
    Expression<String>? id,
    Expression<String>? sourceDeviceId,
    Expression<String>? targetDeviceId,
    Expression<String>? type,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<String>? libraryIds,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? totalItems,
    Expression<int>? processedItems,
    Expression<int>? failedItems,
    Expression<String>? errorMessage,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (targetDeviceId != null) 'target_device_id': targetDeviceId,
      if (type != null) 'type': type,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (libraryIds != null) 'library_ids': libraryIds,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (totalItems != null) 'total_items': totalItems,
      if (processedItems != null) 'processed_items': processedItems,
      if (failedItems != null) 'failed_items': failedItems,
      if (errorMessage != null) 'error_message': errorMessage,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceDeviceId,
      Value<String>? targetDeviceId,
      Value<String>? type,
      Value<String>? direction,
      Value<String>? status,
      Value<String>? libraryIds,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int>? totalItems,
      Value<int>? processedItems,
      Value<int>? failedItems,
      Value<String?>? errorMessage,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return SyncSessionsCompanion(
      id: id ?? this.id,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      libraryIds: libraryIds ?? this.libraryIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      failedItems: failedItems ?? this.failedItems,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (targetDeviceId.present) {
      map['target_device_id'] = Variable<String>(targetDeviceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (libraryIds.present) {
      map['library_ids'] = Variable<String>(libraryIds.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (processedItems.present) {
      map['processed_items'] = Variable<int>(processedItems.value);
    }
    if (failedItems.present) {
      map['failed_items'] = Variable<int>(failedItems.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('targetDeviceId: $targetDeviceId, ')
          ..write('type: $type, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('libraryIds: $libraryIds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalItems: $totalItems, ')
          ..write('processedItems: $processedItems, ')
          ..write('failedItems: $failedItems, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sync_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemTypeMeta =
      const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
      'item_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceDataMeta =
      const VerificationMeta('sourceData');
  @override
  late final GeneratedColumn<String> sourceData = GeneratedColumn<String>(
      'source_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetDataMeta =
      const VerificationMeta('targetData');
  @override
  late final GeneratedColumn<String> targetData = GeneratedColumn<String>(
      'target_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resolutionMeta =
      const VerificationMeta('resolution');
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
      'resolution', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detectedAtMeta =
      const VerificationMeta('detectedAt');
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
      'detected_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _resolvedByMeta =
      const VerificationMeta('resolvedBy');
  @override
  late final GeneratedColumn<String> resolvedBy = GeneratedColumn<String>(
      'resolved_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolvedDataMeta =
      const VerificationMeta('resolvedData');
  @override
  late final GeneratedColumn<String> resolvedData = GeneratedColumn<String>(
      'resolved_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isResolvedMeta =
      const VerificationMeta('isResolved');
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
      'is_resolved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_resolved" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        type,
        itemId,
        itemType,
        sourceData,
        targetData,
        resolution,
        detectedAt,
        resolvedAt,
        resolvedBy,
        resolvedData,
        isResolved
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(Insertable<SyncConflict> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(_itemTypeMeta,
          itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta));
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('source_data')) {
      context.handle(
          _sourceDataMeta,
          sourceData.isAcceptableOrUnknown(
              data['source_data']!, _sourceDataMeta));
    } else if (isInserting) {
      context.missing(_sourceDataMeta);
    }
    if (data.containsKey('target_data')) {
      context.handle(
          _targetDataMeta,
          targetData.isAcceptableOrUnknown(
              data['target_data']!, _targetDataMeta));
    } else if (isInserting) {
      context.missing(_targetDataMeta);
    }
    if (data.containsKey('resolution')) {
      context.handle(
          _resolutionMeta,
          resolution.isAcceptableOrUnknown(
              data['resolution']!, _resolutionMeta));
    } else if (isInserting) {
      context.missing(_resolutionMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
          _detectedAtMeta,
          detectedAt.isAcceptableOrUnknown(
              data['detected_at']!, _detectedAtMeta));
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('resolved_by')) {
      context.handle(
          _resolvedByMeta,
          resolvedBy.isAcceptableOrUnknown(
              data['resolved_by']!, _resolvedByMeta));
    }
    if (data.containsKey('resolved_data')) {
      context.handle(
          _resolvedDataMeta,
          resolvedData.isAcceptableOrUnknown(
              data['resolved_data']!, _resolvedDataMeta));
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
          _isResolvedMeta,
          isResolved.isAcceptableOrUnknown(
              data['is_resolved']!, _isResolvedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      itemType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_type'])!,
      sourceData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_data'])!,
      targetData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_data'])!,
      resolution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolution'])!,
      detectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}detected_at'])!,
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      resolvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolved_by']),
      resolvedData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resolved_data']),
      isResolved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_resolved'])!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String sessionId;
  final String type;
  final String itemId;
  final String itemType;
  final String sourceData;
  final String targetData;
  final String resolution;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolvedData;
  final bool isResolved;
  const SyncConflict(
      {required this.id,
      required this.sessionId,
      required this.type,
      required this.itemId,
      required this.itemType,
      required this.sourceData,
      required this.targetData,
      required this.resolution,
      required this.detectedAt,
      this.resolvedAt,
      this.resolvedBy,
      this.resolvedData,
      required this.isResolved});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['type'] = Variable<String>(type);
    map['item_id'] = Variable<String>(itemId);
    map['item_type'] = Variable<String>(itemType);
    map['source_data'] = Variable<String>(sourceData);
    map['target_data'] = Variable<String>(targetData);
    map['resolution'] = Variable<String>(resolution);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolvedBy != null) {
      map['resolved_by'] = Variable<String>(resolvedBy);
    }
    if (!nullToAbsent || resolvedData != null) {
      map['resolved_data'] = Variable<String>(resolvedData);
    }
    map['is_resolved'] = Variable<bool>(isResolved);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      itemId: Value(itemId),
      itemType: Value(itemType),
      sourceData: Value(sourceData),
      targetData: Value(targetData),
      resolution: Value(resolution),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolvedBy: resolvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedBy),
      resolvedData: resolvedData == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedData),
      isResolved: Value(isResolved),
    );
  }

  factory SyncConflict.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      sourceData: serializer.fromJson<String>(json['sourceData']),
      targetData: serializer.fromJson<String>(json['targetData']),
      resolution: serializer.fromJson<String>(json['resolution']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolvedBy: serializer.fromJson<String?>(json['resolvedBy']),
      resolvedData: serializer.fromJson<String?>(json['resolvedData']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'type': serializer.toJson<String>(type),
      'itemId': serializer.toJson<String>(itemId),
      'itemType': serializer.toJson<String>(itemType),
      'sourceData': serializer.toJson<String>(sourceData),
      'targetData': serializer.toJson<String>(targetData),
      'resolution': serializer.toJson<String>(resolution),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolvedBy': serializer.toJson<String?>(resolvedBy),
      'resolvedData': serializer.toJson<String?>(resolvedData),
      'isResolved': serializer.toJson<bool>(isResolved),
    };
  }

  SyncConflict copyWith(
          {String? id,
          String? sessionId,
          String? type,
          String? itemId,
          String? itemType,
          String? sourceData,
          String? targetData,
          String? resolution,
          DateTime? detectedAt,
          Value<DateTime?> resolvedAt = const Value.absent(),
          Value<String?> resolvedBy = const Value.absent(),
          Value<String?> resolvedData = const Value.absent(),
          bool? isResolved}) =>
      SyncConflict(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        type: type ?? this.type,
        itemId: itemId ?? this.itemId,
        itemType: itemType ?? this.itemType,
        sourceData: sourceData ?? this.sourceData,
        targetData: targetData ?? this.targetData,
        resolution: resolution ?? this.resolution,
        detectedAt: detectedAt ?? this.detectedAt,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        resolvedBy: resolvedBy.present ? resolvedBy.value : this.resolvedBy,
        resolvedData:
            resolvedData.present ? resolvedData.value : this.resolvedData,
        isResolved: isResolved ?? this.isResolved,
      );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      sourceData:
          data.sourceData.present ? data.sourceData.value : this.sourceData,
      targetData:
          data.targetData.present ? data.targetData.value : this.targetData,
      resolution:
          data.resolution.present ? data.resolution.value : this.resolution,
      detectedAt:
          data.detectedAt.present ? data.detectedAt.value : this.detectedAt,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      resolvedBy:
          data.resolvedBy.present ? data.resolvedBy.value : this.resolvedBy,
      resolvedData: data.resolvedData.present
          ? data.resolvedData.value
          : this.resolvedData,
      isResolved:
          data.isResolved.present ? data.isResolved.value : this.isResolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('sourceData: $sourceData, ')
          ..write('targetData: $targetData, ')
          ..write('resolution: $resolution, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedBy: $resolvedBy, ')
          ..write('resolvedData: $resolvedData, ')
          ..write('isResolved: $isResolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      type,
      itemId,
      itemType,
      sourceData,
      targetData,
      resolution,
      detectedAt,
      resolvedAt,
      resolvedBy,
      resolvedData,
      isResolved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.itemType == this.itemType &&
          other.sourceData == this.sourceData &&
          other.targetData == this.targetData &&
          other.resolution == this.resolution &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.resolvedBy == this.resolvedBy &&
          other.resolvedData == this.resolvedData &&
          other.isResolved == this.isResolved);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> type;
  final Value<String> itemId;
  final Value<String> itemType;
  final Value<String> sourceData;
  final Value<String> targetData;
  final Value<String> resolution;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolvedBy;
  final Value<String?> resolvedData;
  final Value<bool> isResolved;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.sourceData = const Value.absent(),
    this.targetData = const Value.absent(),
    this.resolution = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.resolvedData = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String sessionId,
    required String type,
    required String itemId,
    required String itemType,
    required String sourceData,
    required String targetData,
    required String resolution,
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.resolvedData = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        type = Value(type),
        itemId = Value(itemId),
        itemType = Value(itemType),
        sourceData = Value(sourceData),
        targetData = Value(targetData),
        resolution = Value(resolution),
        detectedAt = Value(detectedAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<String>? itemId,
    Expression<String>? itemType,
    Expression<String>? sourceData,
    Expression<String>? targetData,
    Expression<String>? resolution,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolvedBy,
    Expression<String>? resolvedData,
    Expression<bool>? isResolved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (itemType != null) 'item_type': itemType,
      if (sourceData != null) 'source_data': sourceData,
      if (targetData != null) 'target_data': targetData,
      if (resolution != null) 'resolution': resolution,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolvedBy != null) 'resolved_by': resolvedBy,
      if (resolvedData != null) 'resolved_data': resolvedData,
      if (isResolved != null) 'is_resolved': isResolved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? type,
      Value<String>? itemId,
      Value<String>? itemType,
      Value<String>? sourceData,
      Value<String>? targetData,
      Value<String>? resolution,
      Value<DateTime>? detectedAt,
      Value<DateTime?>? resolvedAt,
      Value<String?>? resolvedBy,
      Value<String?>? resolvedData,
      Value<bool>? isResolved,
      Value<int>? rowid}) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      sourceData: sourceData ?? this.sourceData,
      targetData: targetData ?? this.targetData,
      resolution: resolution ?? this.resolution,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedData: resolvedData ?? this.resolvedData,
      isResolved: isResolved ?? this.isResolved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (sourceData.present) {
      map['source_data'] = Variable<String>(sourceData.value);
    }
    if (targetData.present) {
      map['target_data'] = Variable<String>(targetData.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolvedBy.present) {
      map['resolved_by'] = Variable<String>(resolvedBy.value);
    }
    if (resolvedData.present) {
      map['resolved_data'] = Variable<String>(resolvedData.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('sourceData: $sourceData, ')
          ..write('targetData: $targetData, ')
          ..write('resolution: $resolution, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolvedBy: $resolvedBy, ')
          ..write('resolvedData: $resolvedData, ')
          ..write('isResolved: $isResolved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibrariesTable libraries = $LibrariesTable(this);
  late final $MangasTable mangas = $MangasTable(this);
  late final $MangaPagesTable mangaPages = $MangaPagesTable(this);
  late final $ReadingProgressesTable readingProgresses =
      $ReadingProgressesTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $SyncSessionsTable syncSessions = $SyncSessionsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        libraries,
        mangas,
        mangaPages,
        readingProgresses,
        devices,
        syncSessions,
        syncConflicts
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('libraries',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('mangas', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('mangas',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('manga_pages', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('mangas',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_progresses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sync_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('sync_conflicts', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$LibrariesTableCreateCompanionBuilder = LibrariesCompanion Function({
  required String id,
  required String name,
  required String path,
  required String type,
  Value<bool> isEnabled,
  required DateTime createdAt,
  Value<DateTime?> lastScanAt,
  Value<int> mangaCount,
  Value<String?> settings,
  Value<bool> isScanning,
  Value<bool> isPrivate,
  Value<bool> isPrivateActivated,
  Value<int> rowid,
});
typedef $$LibrariesTableUpdateCompanionBuilder = LibrariesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> path,
  Value<String> type,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime?> lastScanAt,
  Value<int> mangaCount,
  Value<String?> settings,
  Value<bool> isScanning,
  Value<bool> isPrivate,
  Value<bool> isPrivateActivated,
  Value<int> rowid,
});

final class $$LibrariesTableReferences
    extends BaseReferences<_$AppDatabase, $LibrariesTable, Library> {
  $$LibrariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MangasTable, List<Manga>> _mangasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.mangas,
          aliasName:
              $_aliasNameGenerator(db.libraries.id, db.mangas.libraryId));

  $$MangasTableProcessedTableManager get mangasRefs {
    final manager = $$MangasTableTableManager($_db, $_db.mangas)
        .filter((f) => f.libraryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mangasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LibrariesTableFilterComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastScanAt => $composableBuilder(
      column: $table.lastScanAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mangaCount => $composableBuilder(
      column: $table.mangaCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isScanning => $composableBuilder(
      column: $table.isScanning, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrivateActivated => $composableBuilder(
      column: $table.isPrivateActivated,
      builder: (column) => ColumnFilters(column));

  Expression<bool> mangasRefs(
      Expression<bool> Function($$MangasTableFilterComposer f) f) {
    final $$MangasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.libraryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableFilterComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LibrariesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastScanAt => $composableBuilder(
      column: $table.lastScanAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mangaCount => $composableBuilder(
      column: $table.mangaCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isScanning => $composableBuilder(
      column: $table.isScanning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrivateActivated => $composableBuilder(
      column: $table.isPrivateActivated,
      builder: (column) => ColumnOrderings(column));
}

class $$LibrariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScanAt => $composableBuilder(
      column: $table.lastScanAt, builder: (column) => column);

  GeneratedColumn<int> get mangaCount => $composableBuilder(
      column: $table.mangaCount, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<bool> get isScanning => $composableBuilder(
      column: $table.isScanning, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<bool> get isPrivateActivated => $composableBuilder(
      column: $table.isPrivateActivated, builder: (column) => column);

  Expression<T> mangasRefs<T extends Object>(
      Expression<T> Function($$MangasTableAnnotationComposer a) f) {
    final $$MangasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.libraryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableAnnotationComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LibrariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LibrariesTable,
    Library,
    $$LibrariesTableFilterComposer,
    $$LibrariesTableOrderingComposer,
    $$LibrariesTableAnnotationComposer,
    $$LibrariesTableCreateCompanionBuilder,
    $$LibrariesTableUpdateCompanionBuilder,
    (Library, $$LibrariesTableReferences),
    Library,
    PrefetchHooks Function({bool mangasRefs})> {
  $$LibrariesTableTableManager(_$AppDatabase db, $LibrariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibrariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibrariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibrariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastScanAt = const Value.absent(),
            Value<int> mangaCount = const Value.absent(),
            Value<String?> settings = const Value.absent(),
            Value<bool> isScanning = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<bool> isPrivateActivated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibrariesCompanion(
            id: id,
            name: name,
            path: path,
            type: type,
            isEnabled: isEnabled,
            createdAt: createdAt,
            lastScanAt: lastScanAt,
            mangaCount: mangaCount,
            settings: settings,
            isScanning: isScanning,
            isPrivate: isPrivate,
            isPrivateActivated: isPrivateActivated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String path,
            required String type,
            Value<bool> isEnabled = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastScanAt = const Value.absent(),
            Value<int> mangaCount = const Value.absent(),
            Value<String?> settings = const Value.absent(),
            Value<bool> isScanning = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<bool> isPrivateActivated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibrariesCompanion.insert(
            id: id,
            name: name,
            path: path,
            type: type,
            isEnabled: isEnabled,
            createdAt: createdAt,
            lastScanAt: lastScanAt,
            mangaCount: mangaCount,
            settings: settings,
            isScanning: isScanning,
            isPrivate: isPrivate,
            isPrivateActivated: isPrivateActivated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LibrariesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mangasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mangasRefs) db.mangas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mangasRefs)
                    await $_getPrefetchedData<Library, $LibrariesTable, Manga>(
                        currentTable: table,
                        referencedTable:
                            $$LibrariesTableReferences._mangasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LibrariesTableReferences(db, table, p0)
                                .mangasRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.libraryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LibrariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LibrariesTable,
    Library,
    $$LibrariesTableFilterComposer,
    $$LibrariesTableOrderingComposer,
    $$LibrariesTableAnnotationComposer,
    $$LibrariesTableCreateCompanionBuilder,
    $$LibrariesTableUpdateCompanionBuilder,
    (Library, $$LibrariesTableReferences),
    Library,
    PrefetchHooks Function({bool mangasRefs})>;
typedef $$MangasTableCreateCompanionBuilder = MangasCompanion Function({
  required String id,
  required String libraryId,
  required String title,
  Value<String?> subtitle,
  Value<String?> author,
  Value<String?> description,
  Value<String?> coverPath,
  Value<String?> tags,
  Value<String?> status,
  Value<String?> type,
  Value<bool> isFavorite,
  Value<bool> isCompleted,
  Value<int> totalPages,
  Value<int> currentPage,
  Value<double?> rating,
  Value<String?> source,
  Value<String?> sourceUrl,
  Value<String?> lastReadAt,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> readingProgress,
  Value<String?> filePath,
  Value<int?> fileSize,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$MangasTableUpdateCompanionBuilder = MangasCompanion Function({
  Value<String> id,
  Value<String> libraryId,
  Value<String> title,
  Value<String?> subtitle,
  Value<String?> author,
  Value<String?> description,
  Value<String?> coverPath,
  Value<String?> tags,
  Value<String?> status,
  Value<String?> type,
  Value<bool> isFavorite,
  Value<bool> isCompleted,
  Value<int> totalPages,
  Value<int> currentPage,
  Value<double?> rating,
  Value<String?> source,
  Value<String?> sourceUrl,
  Value<String?> lastReadAt,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> readingProgress,
  Value<String?> filePath,
  Value<int?> fileSize,
  Value<String?> metadata,
  Value<int> rowid,
});

final class $$MangasTableReferences
    extends BaseReferences<_$AppDatabase, $MangasTable, Manga> {
  $$MangasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibrariesTable _libraryIdTable(_$AppDatabase db) => db.libraries
      .createAlias($_aliasNameGenerator(db.mangas.libraryId, db.libraries.id));

  $$LibrariesTableProcessedTableManager get libraryId {
    final $_column = $_itemColumn<String>('library_id')!;

    final manager = $$LibrariesTableTableManager($_db, $_db.libraries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_libraryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MangaPagesTable, List<MangaPage>>
      _mangaPagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.mangaPages,
          aliasName: $_aliasNameGenerator(db.mangas.id, db.mangaPages.mangaId));

  $$MangaPagesTableProcessedTableManager get mangaPagesRefs {
    final manager = $$MangaPagesTableTableManager($_db, $_db.mangaPages)
        .filter((f) => f.mangaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mangaPagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingProgressesTable,
      List<ReadingProgressesData>> _readingProgressesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.readingProgresses,
          aliasName:
              $_aliasNameGenerator(db.mangas.id, db.readingProgresses.mangaId));

  $$ReadingProgressesTableProcessedTableManager get readingProgressesRefs {
    final manager =
        $$ReadingProgressesTableTableManager($_db, $_db.readingProgresses)
            .filter((f) => f.mangaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_readingProgressesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MangasTableFilterComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readingProgress => $composableBuilder(
      column: $table.readingProgress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$LibrariesTableFilterComposer get libraryId {
    final $$LibrariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.libraryId,
        referencedTable: $db.libraries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibrariesTableFilterComposer(
              $db: $db,
              $table: $db.libraries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> mangaPagesRefs(
      Expression<bool> Function($$MangaPagesTableFilterComposer f) f) {
    final $$MangaPagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mangaPages,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaPagesTableFilterComposer(
              $db: $db,
              $table: $db.mangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingProgressesRefs(
      Expression<bool> Function($$ReadingProgressesTableFilterComposer f) f) {
    final $$ReadingProgressesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingProgresses,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingProgressesTableFilterComposer(
              $db: $db,
              $table: $db.readingProgresses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MangasTableOrderingComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readingProgress => $composableBuilder(
      column: $table.readingProgress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$LibrariesTableOrderingComposer get libraryId {
    final $$LibrariesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.libraryId,
        referencedTable: $db.libraries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibrariesTableOrderingComposer(
              $db: $db,
              $table: $db.libraries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MangasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangasTable> {
  $$MangasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get readingProgress => $composableBuilder(
      column: $table.readingProgress, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$LibrariesTableAnnotationComposer get libraryId {
    final $$LibrariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.libraryId,
        referencedTable: $db.libraries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibrariesTableAnnotationComposer(
              $db: $db,
              $table: $db.libraries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> mangaPagesRefs<T extends Object>(
      Expression<T> Function($$MangaPagesTableAnnotationComposer a) f) {
    final $$MangaPagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mangaPages,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaPagesTableAnnotationComposer(
              $db: $db,
              $table: $db.mangaPages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingProgressesRefs<T extends Object>(
      Expression<T> Function($$ReadingProgressesTableAnnotationComposer a) f) {
    final $$ReadingProgressesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.readingProgresses,
            getReferencedColumn: (t) => t.mangaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReadingProgressesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.readingProgresses,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MangasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangasTable,
    Manga,
    $$MangasTableFilterComposer,
    $$MangasTableOrderingComposer,
    $$MangasTableAnnotationComposer,
    $$MangasTableCreateCompanionBuilder,
    $$MangasTableUpdateCompanionBuilder,
    (Manga, $$MangasTableReferences),
    Manga,
    PrefetchHooks Function(
        {bool libraryId, bool mangaPagesRefs, bool readingProgressesRefs})> {
  $$MangasTableTableManager(_$AppDatabase db, $MangasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> libraryId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> subtitle = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<int> currentPage = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> lastReadAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> readingProgress = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangasCompanion(
            id: id,
            libraryId: libraryId,
            title: title,
            subtitle: subtitle,
            author: author,
            description: description,
            coverPath: coverPath,
            tags: tags,
            status: status,
            type: type,
            isFavorite: isFavorite,
            isCompleted: isCompleted,
            totalPages: totalPages,
            currentPage: currentPage,
            rating: rating,
            source: source,
            sourceUrl: sourceUrl,
            lastReadAt: lastReadAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            readingProgress: readingProgress,
            filePath: filePath,
            fileSize: fileSize,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String libraryId,
            required String title,
            Value<String?> subtitle = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<int> currentPage = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> lastReadAt = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> readingProgress = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangasCompanion.insert(
            id: id,
            libraryId: libraryId,
            title: title,
            subtitle: subtitle,
            author: author,
            description: description,
            coverPath: coverPath,
            tags: tags,
            status: status,
            type: type,
            isFavorite: isFavorite,
            isCompleted: isCompleted,
            totalPages: totalPages,
            currentPage: currentPage,
            rating: rating,
            source: source,
            sourceUrl: sourceUrl,
            lastReadAt: lastReadAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            readingProgress: readingProgress,
            filePath: filePath,
            fileSize: fileSize,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MangasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {libraryId = false,
              mangaPagesRefs = false,
              readingProgressesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mangaPagesRefs) db.mangaPages,
                if (readingProgressesRefs) db.readingProgresses
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (libraryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.libraryId,
                    referencedTable:
                        $$MangasTableReferences._libraryIdTable(db),
                    referencedColumn:
                        $$MangasTableReferences._libraryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mangaPagesRefs)
                    await $_getPrefetchedData<Manga, $MangasTable, MangaPage>(
                        currentTable: table,
                        referencedTable:
                            $$MangasTableReferences._mangaPagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MangasTableReferences(db, table, p0)
                                .mangaPagesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mangaId == item.id),
                        typedResults: items),
                  if (readingProgressesRefs)
                    await $_getPrefetchedData<Manga, $MangasTable,
                            ReadingProgressesData>(
                        currentTable: table,
                        referencedTable: $$MangasTableReferences
                            ._readingProgressesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MangasTableReferences(db, table, p0)
                                .readingProgressesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mangaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MangasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangasTable,
    Manga,
    $$MangasTableFilterComposer,
    $$MangasTableOrderingComposer,
    $$MangasTableAnnotationComposer,
    $$MangasTableCreateCompanionBuilder,
    $$MangasTableUpdateCompanionBuilder,
    (Manga, $$MangasTableReferences),
    Manga,
    PrefetchHooks Function(
        {bool libraryId, bool mangaPagesRefs, bool readingProgressesRefs})>;
typedef $$MangaPagesTableCreateCompanionBuilder = MangaPagesCompanion Function({
  required String id,
  required String mangaId,
  required int pageIndex,
  Value<String?> localPath,
  Value<String?> largeThumbnail,
  Value<String?> mediumThumbnail,
  Value<String?> smallThumbnail,
  Value<int> rowid,
});
typedef $$MangaPagesTableUpdateCompanionBuilder = MangaPagesCompanion Function({
  Value<String> id,
  Value<String> mangaId,
  Value<int> pageIndex,
  Value<String?> localPath,
  Value<String?> largeThumbnail,
  Value<String?> mediumThumbnail,
  Value<String?> smallThumbnail,
  Value<int> rowid,
});

final class $$MangaPagesTableReferences
    extends BaseReferences<_$AppDatabase, $MangaPagesTable, MangaPage> {
  $$MangaPagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MangasTable _mangaIdTable(_$AppDatabase db) => db.mangas
      .createAlias($_aliasNameGenerator(db.mangaPages.mangaId, db.mangas.id));

  $$MangasTableProcessedTableManager get mangaId {
    final $_column = $_itemColumn<String>('manga_id')!;

    final manager = $$MangasTableTableManager($_db, $_db.mangas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MangaPagesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get largeThumbnail => $composableBuilder(
      column: $table.largeThumbnail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediumThumbnail => $composableBuilder(
      column: $table.mediumThumbnail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get smallThumbnail => $composableBuilder(
      column: $table.smallThumbnail,
      builder: (column) => ColumnFilters(column));

  $$MangasTableFilterComposer get mangaId {
    final $$MangasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableFilterComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MangaPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get largeThumbnail => $composableBuilder(
      column: $table.largeThumbnail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediumThumbnail => $composableBuilder(
      column: $table.mediumThumbnail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get smallThumbnail => $composableBuilder(
      column: $table.smallThumbnail,
      builder: (column) => ColumnOrderings(column));

  $$MangasTableOrderingComposer get mangaId {
    final $$MangasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableOrderingComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MangaPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get largeThumbnail => $composableBuilder(
      column: $table.largeThumbnail, builder: (column) => column);

  GeneratedColumn<String> get mediumThumbnail => $composableBuilder(
      column: $table.mediumThumbnail, builder: (column) => column);

  GeneratedColumn<String> get smallThumbnail => $composableBuilder(
      column: $table.smallThumbnail, builder: (column) => column);

  $$MangasTableAnnotationComposer get mangaId {
    final $$MangasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableAnnotationComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MangaPagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaPagesTable,
    MangaPage,
    $$MangaPagesTableFilterComposer,
    $$MangaPagesTableOrderingComposer,
    $$MangaPagesTableAnnotationComposer,
    $$MangaPagesTableCreateCompanionBuilder,
    $$MangaPagesTableUpdateCompanionBuilder,
    (MangaPage, $$MangaPagesTableReferences),
    MangaPage,
    PrefetchHooks Function({bool mangaId})> {
  $$MangaPagesTableTableManager(_$AppDatabase db, $MangaPagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> largeThumbnail = const Value.absent(),
            Value<String?> mediumThumbnail = const Value.absent(),
            Value<String?> smallThumbnail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaPagesCompanion(
            id: id,
            mangaId: mangaId,
            pageIndex: pageIndex,
            localPath: localPath,
            largeThumbnail: largeThumbnail,
            mediumThumbnail: mediumThumbnail,
            smallThumbnail: smallThumbnail,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mangaId,
            required int pageIndex,
            Value<String?> localPath = const Value.absent(),
            Value<String?> largeThumbnail = const Value.absent(),
            Value<String?> mediumThumbnail = const Value.absent(),
            Value<String?> smallThumbnail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaPagesCompanion.insert(
            id: id,
            mangaId: mangaId,
            pageIndex: pageIndex,
            localPath: localPath,
            largeThumbnail: largeThumbnail,
            mediumThumbnail: mediumThumbnail,
            smallThumbnail: smallThumbnail,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MangaPagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mangaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mangaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mangaId,
                    referencedTable:
                        $$MangaPagesTableReferences._mangaIdTable(db),
                    referencedColumn:
                        $$MangaPagesTableReferences._mangaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MangaPagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaPagesTable,
    MangaPage,
    $$MangaPagesTableFilterComposer,
    $$MangaPagesTableOrderingComposer,
    $$MangaPagesTableAnnotationComposer,
    $$MangaPagesTableCreateCompanionBuilder,
    $$MangaPagesTableUpdateCompanionBuilder,
    (MangaPage, $$MangaPagesTableReferences),
    MangaPage,
    PrefetchHooks Function({bool mangaId})>;
typedef $$ReadingProgressesTableCreateCompanionBuilder
    = ReadingProgressesCompanion Function({
  required String id,
  required String mangaId,
  required String libraryId,
  Value<int> currentPage,
  Value<int> totalPages,
  Value<double> progressPercentage,
  required DateTime lastReadAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ReadingProgressesTableUpdateCompanionBuilder
    = ReadingProgressesCompanion Function({
  Value<String> id,
  Value<String> mangaId,
  Value<String> libraryId,
  Value<int> currentPage,
  Value<int> totalPages,
  Value<double> progressPercentage,
  Value<DateTime> lastReadAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ReadingProgressesTableReferences extends BaseReferences<
    _$AppDatabase, $ReadingProgressesTable, ReadingProgressesData> {
  $$ReadingProgressesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MangasTable _mangaIdTable(_$AppDatabase db) => db.mangas.createAlias(
      $_aliasNameGenerator(db.readingProgresses.mangaId, db.mangas.id));

  $$MangasTableProcessedTableManager get mangaId {
    final $_column = $_itemColumn<String>('manga_id')!;

    final manager = $$MangasTableTableManager($_db, $_db.mangas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get libraryId => $composableBuilder(
      column: $table.libraryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progressPercentage => $composableBuilder(
      column: $table.progressPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$MangasTableFilterComposer get mangaId {
    final $$MangasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableFilterComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get libraryId => $composableBuilder(
      column: $table.libraryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progressPercentage => $composableBuilder(
      column: $table.progressPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$MangasTableOrderingComposer get mangaId {
    final $$MangasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableOrderingComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
      column: $table.currentPage, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<double> get progressPercentage => $composableBuilder(
      column: $table.progressPercentage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MangasTableAnnotationComposer get mangaId {
    final $$MangasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangasTableAnnotationComposer(
              $db: $db,
              $table: $db.mangas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingProgressesTable,
    ReadingProgressesData,
    $$ReadingProgressesTableFilterComposer,
    $$ReadingProgressesTableOrderingComposer,
    $$ReadingProgressesTableAnnotationComposer,
    $$ReadingProgressesTableCreateCompanionBuilder,
    $$ReadingProgressesTableUpdateCompanionBuilder,
    (ReadingProgressesData, $$ReadingProgressesTableReferences),
    ReadingProgressesData,
    PrefetchHooks Function({bool mangaId})> {
  $$ReadingProgressesTableTableManager(
      _$AppDatabase db, $ReadingProgressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<String> libraryId = const Value.absent(),
            Value<int> currentPage = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<double> progressPercentage = const Value.absent(),
            Value<DateTime> lastReadAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressesCompanion(
            id: id,
            mangaId: mangaId,
            libraryId: libraryId,
            currentPage: currentPage,
            totalPages: totalPages,
            progressPercentage: progressPercentage,
            lastReadAt: lastReadAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mangaId,
            required String libraryId,
            Value<int> currentPage = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<double> progressPercentage = const Value.absent(),
            required DateTime lastReadAt,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressesCompanion.insert(
            id: id,
            mangaId: mangaId,
            libraryId: libraryId,
            currentPage: currentPage,
            totalPages: totalPages,
            progressPercentage: progressPercentage,
            lastReadAt: lastReadAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReadingProgressesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mangaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mangaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mangaId,
                    referencedTable:
                        $$ReadingProgressesTableReferences._mangaIdTable(db),
                    referencedColumn:
                        $$ReadingProgressesTableReferences._mangaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingProgressesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingProgressesTable,
    ReadingProgressesData,
    $$ReadingProgressesTableFilterComposer,
    $$ReadingProgressesTableOrderingComposer,
    $$ReadingProgressesTableAnnotationComposer,
    $$ReadingProgressesTableCreateCompanionBuilder,
    $$ReadingProgressesTableUpdateCompanionBuilder,
    (ReadingProgressesData, $$ReadingProgressesTableReferences),
    ReadingProgressesData,
    PrefetchHooks Function({bool mangaId})>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String name,
  required String platform,
  required String version,
  required String ipAddress,
  required int port,
  required DateTime lastSeen,
  Value<bool> isOnline,
  Value<String?> capabilities,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> platform,
  Value<String> version,
  Value<String> ipAddress,
  Value<int> port,
  Value<DateTime> lastSeen,
  Value<bool> isOnline,
  Value<String?> capabilities,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOnline => $composableBuilder(
      column: $table.isOnline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capabilities => $composableBuilder(
      column: $table.capabilities, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ipAddress => $composableBuilder(
      column: $table.ipAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOnline => $composableBuilder(
      column: $table.isOnline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capabilities => $composableBuilder(
      column: $table.capabilities,
      builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<String> get capabilities => $composableBuilder(
      column: $table.capabilities, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String> ipAddress = const Value.absent(),
            Value<int> port = const Value.absent(),
            Value<DateTime> lastSeen = const Value.absent(),
            Value<bool> isOnline = const Value.absent(),
            Value<String?> capabilities = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            name: name,
            platform: platform,
            version: version,
            ipAddress: ipAddress,
            port: port,
            lastSeen: lastSeen,
            isOnline: isOnline,
            capabilities: capabilities,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String platform,
            required String version,
            required String ipAddress,
            required int port,
            required DateTime lastSeen,
            Value<bool> isOnline = const Value.absent(),
            Value<String?> capabilities = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            name: name,
            platform: platform,
            version: version,
            ipAddress: ipAddress,
            port: port,
            lastSeen: lastSeen,
            isOnline: isOnline,
            capabilities: capabilities,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()>;
typedef $$SyncSessionsTableCreateCompanionBuilder = SyncSessionsCompanion
    Function({
  required String id,
  required String sourceDeviceId,
  required String targetDeviceId,
  required String type,
  required String direction,
  required String status,
  required String libraryIds,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<int> totalItems,
  Value<int> processedItems,
  Value<int> failedItems,
  Value<String?> errorMessage,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$SyncSessionsTableUpdateCompanionBuilder = SyncSessionsCompanion
    Function({
  Value<String> id,
  Value<String> sourceDeviceId,
  Value<String> targetDeviceId,
  Value<String> type,
  Value<String> direction,
  Value<String> status,
  Value<String> libraryIds,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int> totalItems,
  Value<int> processedItems,
  Value<int> failedItems,
  Value<String?> errorMessage,
  Value<String?> metadata,
  Value<int> rowid,
});

final class $$SyncSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncSessionsTable, SyncSession> {
  $$SyncSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SyncConflictsTable, List<SyncConflict>>
      _syncConflictsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.syncConflicts,
              aliasName: $_aliasNameGenerator(
                  db.syncSessions.id, db.syncConflicts.sessionId));

  $$SyncConflictsTableProcessedTableManager get syncConflictsRefs {
    final manager = $$SyncConflictsTableTableManager($_db, $_db.syncConflicts)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncConflictsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SyncSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncSessionsTable> {
  $$SyncSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDeviceId => $composableBuilder(
      column: $table.targetDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get libraryIds => $composableBuilder(
      column: $table.libraryIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get processedItems => $composableBuilder(
      column: $table.processedItems,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedItems => $composableBuilder(
      column: $table.failedItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  Expression<bool> syncConflictsRefs(
      Expression<bool> Function($$SyncConflictsTableFilterComposer f) f) {
    final $$SyncConflictsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncConflicts,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncConflictsTableFilterComposer(
              $db: $db,
              $table: $db.syncConflicts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncSessionsTable> {
  $$SyncSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDeviceId => $composableBuilder(
      column: $table.targetDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get libraryIds => $composableBuilder(
      column: $table.libraryIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get processedItems => $composableBuilder(
      column: $table.processedItems,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedItems => $composableBuilder(
      column: $table.failedItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $$SyncSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncSessionsTable> {
  $$SyncSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId, builder: (column) => column);

  GeneratedColumn<String> get targetDeviceId => $composableBuilder(
      column: $table.targetDeviceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get libraryIds => $composableBuilder(
      column: $table.libraryIds, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => column);

  GeneratedColumn<int> get processedItems => $composableBuilder(
      column: $table.processedItems, builder: (column) => column);

  GeneratedColumn<int> get failedItems => $composableBuilder(
      column: $table.failedItems, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  Expression<T> syncConflictsRefs<T extends Object>(
      Expression<T> Function($$SyncConflictsTableAnnotationComposer a) f) {
    final $$SyncConflictsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncConflicts,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncConflictsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncConflicts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncSessionsTable,
    SyncSession,
    $$SyncSessionsTableFilterComposer,
    $$SyncSessionsTableOrderingComposer,
    $$SyncSessionsTableAnnotationComposer,
    $$SyncSessionsTableCreateCompanionBuilder,
    $$SyncSessionsTableUpdateCompanionBuilder,
    (SyncSession, $$SyncSessionsTableReferences),
    SyncSession,
    PrefetchHooks Function({bool syncConflictsRefs})> {
  $$SyncSessionsTableTableManager(_$AppDatabase db, $SyncSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceDeviceId = const Value.absent(),
            Value<String> targetDeviceId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> libraryIds = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<int> processedItems = const Value.absent(),
            Value<int> failedItems = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncSessionsCompanion(
            id: id,
            sourceDeviceId: sourceDeviceId,
            targetDeviceId: targetDeviceId,
            type: type,
            direction: direction,
            status: status,
            libraryIds: libraryIds,
            startTime: startTime,
            endTime: endTime,
            totalItems: totalItems,
            processedItems: processedItems,
            failedItems: failedItems,
            errorMessage: errorMessage,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceDeviceId,
            required String targetDeviceId,
            required String type,
            required String direction,
            required String status,
            required String libraryIds,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<int> processedItems = const Value.absent(),
            Value<int> failedItems = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncSessionsCompanion.insert(
            id: id,
            sourceDeviceId: sourceDeviceId,
            targetDeviceId: targetDeviceId,
            type: type,
            direction: direction,
            status: status,
            libraryIds: libraryIds,
            startTime: startTime,
            endTime: endTime,
            totalItems: totalItems,
            processedItems: processedItems,
            failedItems: failedItems,
            errorMessage: errorMessage,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SyncSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({syncConflictsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (syncConflictsRefs) db.syncConflicts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (syncConflictsRefs)
                    await $_getPrefetchedData<SyncSession, $SyncSessionsTable,
                            SyncConflict>(
                        currentTable: table,
                        referencedTable: $$SyncSessionsTableReferences
                            ._syncConflictsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SyncSessionsTableReferences(db, table, p0)
                                .syncConflictsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SyncSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncSessionsTable,
    SyncSession,
    $$SyncSessionsTableFilterComposer,
    $$SyncSessionsTableOrderingComposer,
    $$SyncSessionsTableAnnotationComposer,
    $$SyncSessionsTableCreateCompanionBuilder,
    $$SyncSessionsTableUpdateCompanionBuilder,
    (SyncSession, $$SyncSessionsTableReferences),
    SyncSession,
    PrefetchHooks Function({bool syncConflictsRefs})>;
typedef $$SyncConflictsTableCreateCompanionBuilder = SyncConflictsCompanion
    Function({
  required String id,
  required String sessionId,
  required String type,
  required String itemId,
  required String itemType,
  required String sourceData,
  required String targetData,
  required String resolution,
  required DateTime detectedAt,
  Value<DateTime?> resolvedAt,
  Value<String?> resolvedBy,
  Value<String?> resolvedData,
  Value<bool> isResolved,
  Value<int> rowid,
});
typedef $$SyncConflictsTableUpdateCompanionBuilder = SyncConflictsCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> type,
  Value<String> itemId,
  Value<String> itemType,
  Value<String> sourceData,
  Value<String> targetData,
  Value<String> resolution,
  Value<DateTime> detectedAt,
  Value<DateTime?> resolvedAt,
  Value<String?> resolvedBy,
  Value<String?> resolvedData,
  Value<bool> isResolved,
  Value<int> rowid,
});

final class $$SyncConflictsTableReferences
    extends BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict> {
  $$SyncConflictsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SyncSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.syncSessions.createAlias(
          $_aliasNameGenerator(db.syncConflicts.sessionId, db.syncSessions.id));

  $$SyncSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SyncSessionsTableTableManager($_db, $_db.syncSessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceData => $composableBuilder(
      column: $table.sourceData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetData => $composableBuilder(
      column: $table.targetData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolvedBy => $composableBuilder(
      column: $table.resolvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolvedData => $composableBuilder(
      column: $table.resolvedData, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnFilters(column));

  $$SyncSessionsTableFilterComposer get sessionId {
    final $$SyncSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.syncSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncSessionsTableFilterComposer(
              $db: $db,
              $table: $db.syncSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceData => $composableBuilder(
      column: $table.sourceData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetData => $composableBuilder(
      column: $table.targetData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolvedBy => $composableBuilder(
      column: $table.resolvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolvedData => $composableBuilder(
      column: $table.resolvedData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnOrderings(column));

  $$SyncSessionsTableOrderingComposer get sessionId {
    final $$SyncSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.syncSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.syncSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get sourceData => $composableBuilder(
      column: $table.sourceData, builder: (column) => column);

  GeneratedColumn<String> get targetData => $composableBuilder(
      column: $table.targetData, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
      column: $table.resolution, builder: (column) => column);

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
      column: $table.detectedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<String> get resolvedBy => $composableBuilder(
      column: $table.resolvedBy, builder: (column) => column);

  GeneratedColumn<String> get resolvedData => $composableBuilder(
      column: $table.resolvedData, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => column);

  $$SyncSessionsTableAnnotationComposer get sessionId {
    final $$SyncSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.syncSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncConflictsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncConflictsTable,
    SyncConflict,
    $$SyncConflictsTableFilterComposer,
    $$SyncConflictsTableOrderingComposer,
    $$SyncConflictsTableAnnotationComposer,
    $$SyncConflictsTableCreateCompanionBuilder,
    $$SyncConflictsTableUpdateCompanionBuilder,
    (SyncConflict, $$SyncConflictsTableReferences),
    SyncConflict,
    PrefetchHooks Function({bool sessionId})> {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> itemType = const Value.absent(),
            Value<String> sourceData = const Value.absent(),
            Value<String> targetData = const Value.absent(),
            Value<String> resolution = const Value.absent(),
            Value<DateTime> detectedAt = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<String?> resolvedBy = const Value.absent(),
            Value<String?> resolvedData = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConflictsCompanion(
            id: id,
            sessionId: sessionId,
            type: type,
            itemId: itemId,
            itemType: itemType,
            sourceData: sourceData,
            targetData: targetData,
            resolution: resolution,
            detectedAt: detectedAt,
            resolvedAt: resolvedAt,
            resolvedBy: resolvedBy,
            resolvedData: resolvedData,
            isResolved: isResolved,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String type,
            required String itemId,
            required String itemType,
            required String sourceData,
            required String targetData,
            required String resolution,
            required DateTime detectedAt,
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<String?> resolvedBy = const Value.absent(),
            Value<String?> resolvedData = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncConflictsCompanion.insert(
            id: id,
            sessionId: sessionId,
            type: type,
            itemId: itemId,
            itemType: itemType,
            sourceData: sourceData,
            targetData: targetData,
            resolution: resolution,
            detectedAt: detectedAt,
            resolvedAt: resolvedAt,
            resolvedBy: resolvedBy,
            resolvedData: resolvedData,
            isResolved: isResolved,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SyncConflictsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SyncConflictsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$SyncConflictsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SyncConflictsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncConflictsTable,
    SyncConflict,
    $$SyncConflictsTableFilterComposer,
    $$SyncConflictsTableOrderingComposer,
    $$SyncConflictsTableAnnotationComposer,
    $$SyncConflictsTableCreateCompanionBuilder,
    $$SyncConflictsTableUpdateCompanionBuilder,
    (SyncConflict, $$SyncConflictsTableReferences),
    SyncConflict,
    PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibrariesTableTableManager get libraries =>
      $$LibrariesTableTableManager(_db, _db.libraries);
  $$MangasTableTableManager get mangas =>
      $$MangasTableTableManager(_db, _db.mangas);
  $$MangaPagesTableTableManager get mangaPages =>
      $$MangaPagesTableTableManager(_db, _db.mangaPages);
  $$ReadingProgressesTableTableManager get readingProgresses =>
      $$ReadingProgressesTableTableManager(_db, _db.readingProgresses);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$SyncSessionsTableTableManager get syncSessions =>
      $$SyncSessionsTableTableManager(_db, _db.syncSessions);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
}

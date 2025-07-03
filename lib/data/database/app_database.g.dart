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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibrariesTable libraries = $LibrariesTable(this);
  late final $MangasTable mangas = $MangasTable(this);
  late final $MangaPagesTable mangaPages = $MangaPagesTable(this);
  late final $ReadingProgressesTable readingProgresses =
      $ReadingProgressesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [libraries, mangas, mangaPages, readingProgresses];
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
}

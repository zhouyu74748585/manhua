// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMangaHash() => r'1207efa3e825bc55eef11f2491da9cef8dae1008';

/// See also [allManga].
@ProviderFor(allManga)
final allMangaProvider = AutoDisposeFutureProvider<List<Manga>>.internal(
  allManga,
  name: r'allMangaProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allMangaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMangaRef = AutoDisposeFutureProviderRef<List<Manga>>;
String _$allMangaProgressHash() => r'ac10046a7bcb41d6dfc8f28523732510a729c193';

/// See also [allMangaProgress].
@ProviderFor(allMangaProgress)
final allMangaProgressProvider =
    AutoDisposeFutureProvider<Map<String, ReadingProgress>>.internal(
  allMangaProgress,
  name: r'allMangaProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allMangaProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMangaProgressRef
    = AutoDisposeFutureProviderRef<Map<String, ReadingProgress>>;
String _$favoriteMangaHash() => r'20acb8a4d1439783e4b17668c19acf8ff0d03366';

/// See also [favoriteManga].
@ProviderFor(favoriteManga)
final favoriteMangaProvider = AutoDisposeFutureProvider<List<Manga>>.internal(
  favoriteManga,
  name: r'favoriteMangaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteMangaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteMangaRef = AutoDisposeFutureProviderRef<List<Manga>>;
String _$recentlyReadMangaHash() => r'3b7685eb1c724bce12938cb42d96290c73eeb45a';

/// See also [recentlyReadManga].
@ProviderFor(recentlyReadManga)
final recentlyReadMangaProvider =
    AutoDisposeFutureProvider<List<Manga>>.internal(
  recentlyReadManga,
  name: r'recentlyReadMangaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentlyReadMangaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentlyReadMangaRef = AutoDisposeFutureProviderRef<List<Manga>>;
String _$recentlyUpdatedMangaHash() =>
    r'20beb0e77e7979cc4ba60d068d7f60b4b18f28f4';

/// See also [recentlyUpdatedManga].
@ProviderFor(recentlyUpdatedManga)
final recentlyUpdatedMangaProvider =
    AutoDisposeFutureProvider<List<Manga>>.internal(
  recentlyUpdatedManga,
  name: r'recentlyUpdatedMangaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentlyUpdatedMangaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentlyUpdatedMangaRef = AutoDisposeFutureProviderRef<List<Manga>>;
String _$mangaDetailHash() => r'bd866c2c16840bebe813f9694ba94702fec9d4dc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [mangaDetail].
@ProviderFor(mangaDetail)
const mangaDetailProvider = MangaDetailFamily();

/// See also [mangaDetail].
class MangaDetailFamily extends Family<AsyncValue<Manga?>> {
  /// See also [mangaDetail].
  const MangaDetailFamily();

  /// See also [mangaDetail].
  MangaDetailProvider call(
    String mangaId,
  ) {
    return MangaDetailProvider(
      mangaId,
    );
  }

  @override
  MangaDetailProvider getProviderOverride(
    covariant MangaDetailProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaDetailProvider';
}

/// See also [mangaDetail].
class MangaDetailProvider extends AutoDisposeFutureProvider<Manga?> {
  /// See also [mangaDetail].
  MangaDetailProvider(
    String mangaId,
  ) : this._internal(
          (ref) => mangaDetail(
            ref as MangaDetailRef,
            mangaId,
          ),
          from: mangaDetailProvider,
          name: r'mangaDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaDetailHash,
          dependencies: MangaDetailFamily._dependencies,
          allTransitiveDependencies:
              MangaDetailFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final String mangaId;

  @override
  Override overrideWith(
    FutureOr<Manga?> Function(MangaDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaDetailProvider._internal(
        (ref) => create(ref as MangaDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Manga?> createElement() {
    return _MangaDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaDetailProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaDetailRef on AutoDisposeFutureProviderRef<Manga?> {
  /// The parameter `mangaId` of this provider.
  String get mangaId;
}

class _MangaDetailProviderElement
    extends AutoDisposeFutureProviderElement<Manga?> with MangaDetailRef {
  _MangaDetailProviderElement(super.provider);

  @override
  String get mangaId => (origin as MangaDetailProvider).mangaId;
}

String _$mangaDetailWithCallbackHash() =>
    r'218b918737da19eb1a5605566ec056b23305c591';

/// See also [mangaDetailWithCallback].
@ProviderFor(mangaDetailWithCallback)
const mangaDetailWithCallbackProvider = MangaDetailWithCallbackFamily();

/// See also [mangaDetailWithCallback].
class MangaDetailWithCallbackFamily extends Family<AsyncValue<Manga?>> {
  /// See also [mangaDetailWithCallback].
  const MangaDetailWithCallbackFamily();

  /// See also [mangaDetailWithCallback].
  MangaDetailWithCallbackProvider call(
    String mangaId,
  ) {
    return MangaDetailWithCallbackProvider(
      mangaId,
    );
  }

  @override
  MangaDetailWithCallbackProvider getProviderOverride(
    covariant MangaDetailWithCallbackProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaDetailWithCallbackProvider';
}

/// See also [mangaDetailWithCallback].
class MangaDetailWithCallbackProvider
    extends AutoDisposeFutureProvider<Manga?> {
  /// See also [mangaDetailWithCallback].
  MangaDetailWithCallbackProvider(
    String mangaId,
  ) : this._internal(
          (ref) => mangaDetailWithCallback(
            ref as MangaDetailWithCallbackRef,
            mangaId,
          ),
          from: mangaDetailWithCallbackProvider,
          name: r'mangaDetailWithCallbackProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaDetailWithCallbackHash,
          dependencies: MangaDetailWithCallbackFamily._dependencies,
          allTransitiveDependencies:
              MangaDetailWithCallbackFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaDetailWithCallbackProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final String mangaId;

  @override
  Override overrideWith(
    FutureOr<Manga?> Function(MangaDetailWithCallbackRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaDetailWithCallbackProvider._internal(
        (ref) => create(ref as MangaDetailWithCallbackRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Manga?> createElement() {
    return _MangaDetailWithCallbackProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaDetailWithCallbackProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaDetailWithCallbackRef on AutoDisposeFutureProviderRef<Manga?> {
  /// The parameter `mangaId` of this provider.
  String get mangaId;
}

class _MangaDetailWithCallbackProviderElement
    extends AutoDisposeFutureProviderElement<Manga?>
    with MangaDetailWithCallbackRef {
  _MangaDetailWithCallbackProviderElement(super.provider);

  @override
  String get mangaId => (origin as MangaDetailWithCallbackProvider).mangaId;
}

String _$mangaProgressHash() => r'dc70f0509257347d6a1733c2adca16a8bf0543cc';

/// See also [mangaProgress].
@ProviderFor(mangaProgress)
const mangaProgressProvider = MangaProgressFamily();

/// See also [mangaProgress].
class MangaProgressFamily extends Family<AsyncValue<ReadingProgress?>> {
  /// See also [mangaProgress].
  const MangaProgressFamily();

  /// See also [mangaProgress].
  MangaProgressProvider call(
    String mangaId,
  ) {
    return MangaProgressProvider(
      mangaId,
    );
  }

  @override
  MangaProgressProvider getProviderOverride(
    covariant MangaProgressProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaProgressProvider';
}

/// See also [mangaProgress].
class MangaProgressProvider
    extends AutoDisposeFutureProvider<ReadingProgress?> {
  /// See also [mangaProgress].
  MangaProgressProvider(
    String mangaId,
  ) : this._internal(
          (ref) => mangaProgress(
            ref as MangaProgressRef,
            mangaId,
          ),
          from: mangaProgressProvider,
          name: r'mangaProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaProgressHash,
          dependencies: MangaProgressFamily._dependencies,
          allTransitiveDependencies:
              MangaProgressFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final String mangaId;

  @override
  Override overrideWith(
    FutureOr<ReadingProgress?> Function(MangaProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaProgressProvider._internal(
        (ref) => create(ref as MangaProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ReadingProgress?> createElement() {
    return _MangaProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaProgressProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaProgressRef on AutoDisposeFutureProviderRef<ReadingProgress?> {
  /// The parameter `mangaId` of this provider.
  String get mangaId;
}

class _MangaProgressProviderElement
    extends AutoDisposeFutureProviderElement<ReadingProgress?>
    with MangaProgressRef {
  _MangaProgressProviderElement(super.provider);

  @override
  String get mangaId => (origin as MangaProgressProvider).mangaId;
}

String _$mangaPagesHash() => r'fb476b56087c78e341ffd8a2f3875ab87734287a';

/// See also [mangaPages].
@ProviderFor(mangaPages)
const mangaPagesProvider = MangaPagesFamily();

/// See also [mangaPages].
class MangaPagesFamily extends Family<AsyncValue<List<MangaPage>>> {
  /// See also [mangaPages].
  const MangaPagesFamily();

  /// See also [mangaPages].
  MangaPagesProvider call(
    String mangaId,
  ) {
    return MangaPagesProvider(
      mangaId,
    );
  }

  @override
  MangaPagesProvider getProviderOverride(
    covariant MangaPagesProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaPagesProvider';
}

/// See also [mangaPages].
class MangaPagesProvider extends AutoDisposeFutureProvider<List<MangaPage>> {
  /// See also [mangaPages].
  MangaPagesProvider(
    String mangaId,
  ) : this._internal(
          (ref) => mangaPages(
            ref as MangaPagesRef,
            mangaId,
          ),
          from: mangaPagesProvider,
          name: r'mangaPagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaPagesHash,
          dependencies: MangaPagesFamily._dependencies,
          allTransitiveDependencies:
              MangaPagesFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaPagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final String mangaId;

  @override
  Override overrideWith(
    FutureOr<List<MangaPage>> Function(MangaPagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaPagesProvider._internal(
        (ref) => create(ref as MangaPagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MangaPage>> createElement() {
    return _MangaPagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaPagesProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaPagesRef on AutoDisposeFutureProviderRef<List<MangaPage>> {
  /// The parameter `mangaId` of this provider.
  String get mangaId;
}

class _MangaPagesProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaPage>>
    with MangaPagesRef {
  _MangaPagesProviderElement(super.provider);

  @override
  String get mangaId => (origin as MangaPagesProvider).mangaId;
}

String _$mangaByLibraryHash() => r'af917a1df21aed5fcb93ca26b96b9d6cdbfc68df';

/// See also [mangaByLibrary].
@ProviderFor(mangaByLibrary)
const mangaByLibraryProvider = MangaByLibraryFamily();

/// See also [mangaByLibrary].
class MangaByLibraryFamily extends Family<AsyncValue<List<Manga>>> {
  /// See also [mangaByLibrary].
  const MangaByLibraryFamily();

  /// See also [mangaByLibrary].
  MangaByLibraryProvider call(
    String libraryId,
  ) {
    return MangaByLibraryProvider(
      libraryId,
    );
  }

  @override
  MangaByLibraryProvider getProviderOverride(
    covariant MangaByLibraryProvider provider,
  ) {
    return call(
      provider.libraryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaByLibraryProvider';
}

/// See also [mangaByLibrary].
class MangaByLibraryProvider extends AutoDisposeFutureProvider<List<Manga>> {
  /// See also [mangaByLibrary].
  MangaByLibraryProvider(
    String libraryId,
  ) : this._internal(
          (ref) => mangaByLibrary(
            ref as MangaByLibraryRef,
            libraryId,
          ),
          from: mangaByLibraryProvider,
          name: r'mangaByLibraryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaByLibraryHash,
          dependencies: MangaByLibraryFamily._dependencies,
          allTransitiveDependencies:
              MangaByLibraryFamily._allTransitiveDependencies,
          libraryId: libraryId,
        );

  MangaByLibraryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.libraryId,
  }) : super.internal();

  final String libraryId;

  @override
  Override overrideWith(
    FutureOr<List<Manga>> Function(MangaByLibraryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaByLibraryProvider._internal(
        (ref) => create(ref as MangaByLibraryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        libraryId: libraryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Manga>> createElement() {
    return _MangaByLibraryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaByLibraryProvider && other.libraryId == libraryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, libraryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaByLibraryRef on AutoDisposeFutureProviderRef<List<Manga>> {
  /// The parameter `libraryId` of this provider.
  String get libraryId;
}

class _MangaByLibraryProviderElement
    extends AutoDisposeFutureProviderElement<List<Manga>>
    with MangaByLibraryRef {
  _MangaByLibraryProviderElement(super.provider);

  @override
  String get libraryId => (origin as MangaByLibraryProvider).libraryId;
}

String _$searchMangaHash() => r'ee3687ab0b4efc463c5bcd280e3ce127d144bc30';

/// See also [searchManga].
@ProviderFor(searchManga)
const searchMangaProvider = SearchMangaFamily();

/// See also [searchManga].
class SearchMangaFamily extends Family<AsyncValue<List<Manga>>> {
  /// See also [searchManga].
  const SearchMangaFamily();

  /// See also [searchManga].
  SearchMangaProvider call(
    String query,
  ) {
    return SearchMangaProvider(
      query,
    );
  }

  @override
  SearchMangaProvider getProviderOverride(
    covariant SearchMangaProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchMangaProvider';
}

/// See also [searchManga].
class SearchMangaProvider extends AutoDisposeFutureProvider<List<Manga>> {
  /// See also [searchManga].
  SearchMangaProvider(
    String query,
  ) : this._internal(
          (ref) => searchManga(
            ref as SearchMangaRef,
            query,
          ),
          from: searchMangaProvider,
          name: r'searchMangaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchMangaHash,
          dependencies: SearchMangaFamily._dependencies,
          allTransitiveDependencies:
              SearchMangaFamily._allTransitiveDependencies,
          query: query,
        );

  SearchMangaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Manga>> Function(SearchMangaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchMangaProvider._internal(
        (ref) => create(ref as SearchMangaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Manga>> createElement() {
    return _SearchMangaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchMangaProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchMangaRef on AutoDisposeFutureProviderRef<List<Manga>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchMangaProviderElement
    extends AutoDisposeFutureProviderElement<List<Manga>> with SearchMangaRef {
  _SearchMangaProviderElement(super.provider);

  @override
  String get query => (origin as SearchMangaProvider).query;
}

String _$mangaActionsHash() => r'c19d5babcf27c575920ec2119a8ea0399a114077';

/// See also [MangaActions].
@ProviderFor(MangaActions)
final mangaActionsProvider =
    AutoDisposeNotifierProvider<MangaActions, void>.internal(
  MangaActions.new,
  name: r'mangaActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mangaActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

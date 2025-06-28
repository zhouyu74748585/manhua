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

String _$mangaChaptersHash() => r'e2e7442af017c98dfa2a20c4e018efddf94fb0e5';

/// See also [mangaChapters].
@ProviderFor(mangaChapters)
const mangaChaptersProvider = MangaChaptersFamily();

/// See also [mangaChapters].
class MangaChaptersFamily extends Family<AsyncValue<List<Chapter>>> {
  /// See also [mangaChapters].
  const MangaChaptersFamily();

  /// See also [mangaChapters].
  MangaChaptersProvider call(
    String mangaId,
  ) {
    return MangaChaptersProvider(
      mangaId,
    );
  }

  @override
  MangaChaptersProvider getProviderOverride(
    covariant MangaChaptersProvider provider,
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
  String? get name => r'mangaChaptersProvider';
}

/// See also [mangaChapters].
class MangaChaptersProvider extends AutoDisposeFutureProvider<List<Chapter>> {
  /// See also [mangaChapters].
  MangaChaptersProvider(
    String mangaId,
  ) : this._internal(
          (ref) => mangaChapters(
            ref as MangaChaptersRef,
            mangaId,
          ),
          from: mangaChaptersProvider,
          name: r'mangaChaptersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChaptersHash,
          dependencies: MangaChaptersFamily._dependencies,
          allTransitiveDependencies:
              MangaChaptersFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaChaptersProvider._internal(
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
    FutureOr<List<Chapter>> Function(MangaChaptersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaChaptersProvider._internal(
        (ref) => create(ref as MangaChaptersRef),
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
  AutoDisposeFutureProviderElement<List<Chapter>> createElement() {
    return _MangaChaptersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChaptersProvider && other.mangaId == mangaId;
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
mixin MangaChaptersRef on AutoDisposeFutureProviderRef<List<Chapter>> {
  /// The parameter `mangaId` of this provider.
  String get mangaId;
}

class _MangaChaptersProviderElement
    extends AutoDisposeFutureProviderElement<List<Chapter>>
    with MangaChaptersRef {
  _MangaChaptersProviderElement(super.provider);

  @override
  String get mangaId => (origin as MangaChaptersProvider).mangaId;
}

String _$chapterDetailHash() => r'c4f39a6f1abad34acd1217701af65c5c36da809a';

/// See also [chapterDetail].
@ProviderFor(chapterDetail)
const chapterDetailProvider = ChapterDetailFamily();

/// See also [chapterDetail].
class ChapterDetailFamily extends Family<AsyncValue<Chapter?>> {
  /// See also [chapterDetail].
  const ChapterDetailFamily();

  /// See also [chapterDetail].
  ChapterDetailProvider call(
    String chapterId,
  ) {
    return ChapterDetailProvider(
      chapterId,
    );
  }

  @override
  ChapterDetailProvider getProviderOverride(
    covariant ChapterDetailProvider provider,
  ) {
    return call(
      provider.chapterId,
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
  String? get name => r'chapterDetailProvider';
}

/// See also [chapterDetail].
class ChapterDetailProvider extends AutoDisposeFutureProvider<Chapter?> {
  /// See also [chapterDetail].
  ChapterDetailProvider(
    String chapterId,
  ) : this._internal(
          (ref) => chapterDetail(
            ref as ChapterDetailRef,
            chapterId,
          ),
          from: chapterDetailProvider,
          name: r'chapterDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterDetailHash,
          dependencies: ChapterDetailFamily._dependencies,
          allTransitiveDependencies:
              ChapterDetailFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  ChapterDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final String chapterId;

  @override
  Override overrideWith(
    FutureOr<Chapter?> Function(ChapterDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterDetailProvider._internal(
        (ref) => create(ref as ChapterDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Chapter?> createElement() {
    return _ChapterDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterDetailProvider && other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChapterDetailRef on AutoDisposeFutureProviderRef<Chapter?> {
  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _ChapterDetailProviderElement
    extends AutoDisposeFutureProviderElement<Chapter?> with ChapterDetailRef {
  _ChapterDetailProviderElement(super.provider);

  @override
  String get chapterId => (origin as ChapterDetailProvider).chapterId;
}

String _$chapterPagesHash() => r'4698b15e471ee254d442d38a5759ee61ab593db7';

/// See also [chapterPages].
@ProviderFor(chapterPages)
const chapterPagesProvider = ChapterPagesFamily();

/// See also [chapterPages].
class ChapterPagesFamily extends Family<AsyncValue<List<MangaPage>>> {
  /// See also [chapterPages].
  const ChapterPagesFamily();

  /// See also [chapterPages].
  ChapterPagesProvider call(
    String chapterId,
  ) {
    return ChapterPagesProvider(
      chapterId,
    );
  }

  @override
  ChapterPagesProvider getProviderOverride(
    covariant ChapterPagesProvider provider,
  ) {
    return call(
      provider.chapterId,
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
  String? get name => r'chapterPagesProvider';
}

/// See also [chapterPages].
class ChapterPagesProvider extends AutoDisposeFutureProvider<List<MangaPage>> {
  /// See also [chapterPages].
  ChapterPagesProvider(
    String chapterId,
  ) : this._internal(
          (ref) => chapterPages(
            ref as ChapterPagesRef,
            chapterId,
          ),
          from: chapterPagesProvider,
          name: r'chapterPagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterPagesHash,
          dependencies: ChapterPagesFamily._dependencies,
          allTransitiveDependencies:
              ChapterPagesFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  ChapterPagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final String chapterId;

  @override
  Override overrideWith(
    FutureOr<List<MangaPage>> Function(ChapterPagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterPagesProvider._internal(
        (ref) => create(ref as ChapterPagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MangaPage>> createElement() {
    return _ChapterPagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterPagesProvider && other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChapterPagesRef on AutoDisposeFutureProviderRef<List<MangaPage>> {
  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _ChapterPagesProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaPage>>
    with ChapterPagesRef {
  _ChapterPagesProviderElement(super.provider);

  @override
  String get chapterId => (origin as ChapterPagesProvider).chapterId;
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

String _$mangaActionsHash() => r'fb044be0f4d8a288ff2b493ba8c9c23e40756693';

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

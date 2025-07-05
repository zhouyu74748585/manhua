// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allLibrariesHash() => r'5316348caed55ca0892bc4eab2d5b9cd9f361a95';

/// See also [allLibraries].
@ProviderFor(allLibraries)
final allLibrariesProvider =
    AutoDisposeFutureProvider<List<MangaLibrary>>.internal(
  allLibraries,
  name: r'allLibrariesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allLibrariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllLibrariesRef = AutoDisposeFutureProviderRef<List<MangaLibrary>>;
String _$libraryDetailHash() => r'09a4812f95fe552f0a403ff6da304db4d8782654';

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

/// See also [libraryDetail].
@ProviderFor(libraryDetail)
const libraryDetailProvider = LibraryDetailFamily();

/// See also [libraryDetail].
class LibraryDetailFamily extends Family<AsyncValue<MangaLibrary?>> {
  /// See also [libraryDetail].
  const LibraryDetailFamily();

  /// See also [libraryDetail].
  LibraryDetailProvider call(
    String libraryId,
  ) {
    return LibraryDetailProvider(
      libraryId,
    );
  }

  @override
  LibraryDetailProvider getProviderOverride(
    covariant LibraryDetailProvider provider,
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
  String? get name => r'libraryDetailProvider';
}

/// See also [libraryDetail].
class LibraryDetailProvider extends AutoDisposeFutureProvider<MangaLibrary?> {
  /// See also [libraryDetail].
  LibraryDetailProvider(
    String libraryId,
  ) : this._internal(
          (ref) => libraryDetail(
            ref as LibraryDetailRef,
            libraryId,
          ),
          from: libraryDetailProvider,
          name: r'libraryDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$libraryDetailHash,
          dependencies: LibraryDetailFamily._dependencies,
          allTransitiveDependencies:
              LibraryDetailFamily._allTransitiveDependencies,
          libraryId: libraryId,
        );

  LibraryDetailProvider._internal(
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
    FutureOr<MangaLibrary?> Function(LibraryDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LibraryDetailProvider._internal(
        (ref) => create(ref as LibraryDetailRef),
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
  AutoDisposeFutureProviderElement<MangaLibrary?> createElement() {
    return _LibraryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryDetailProvider && other.libraryId == libraryId;
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
mixin LibraryDetailRef on AutoDisposeFutureProviderRef<MangaLibrary?> {
  /// The parameter `libraryId` of this provider.
  String get libraryId;
}

class _LibraryDetailProviderElement
    extends AutoDisposeFutureProviderElement<MangaLibrary?>
    with LibraryDetailRef {
  _LibraryDetailProviderElement(super.provider);

  @override
  String get libraryId => (origin as LibraryDetailProvider).libraryId;
}

String _$librarySettingsHash() => r'2ab2b1c3c002e97c3f2afc14e30d4f89e319ca92';

/// See also [librarySettings].
@ProviderFor(librarySettings)
const librarySettingsProvider = LibrarySettingsFamily();

/// See also [librarySettings].
class LibrarySettingsFamily extends Family<AsyncValue<LibrarySettings>> {
  /// See also [librarySettings].
  const LibrarySettingsFamily();

  /// See also [librarySettings].
  LibrarySettingsProvider call(
    String libraryId,
  ) {
    return LibrarySettingsProvider(
      libraryId,
    );
  }

  @override
  LibrarySettingsProvider getProviderOverride(
    covariant LibrarySettingsProvider provider,
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
  String? get name => r'librarySettingsProvider';
}

/// See also [librarySettings].
class LibrarySettingsProvider
    extends AutoDisposeFutureProvider<LibrarySettings> {
  /// See also [librarySettings].
  LibrarySettingsProvider(
    String libraryId,
  ) : this._internal(
          (ref) => librarySettings(
            ref as LibrarySettingsRef,
            libraryId,
          ),
          from: librarySettingsProvider,
          name: r'librarySettingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$librarySettingsHash,
          dependencies: LibrarySettingsFamily._dependencies,
          allTransitiveDependencies:
              LibrarySettingsFamily._allTransitiveDependencies,
          libraryId: libraryId,
        );

  LibrarySettingsProvider._internal(
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
    FutureOr<LibrarySettings> Function(LibrarySettingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LibrarySettingsProvider._internal(
        (ref) => create(ref as LibrarySettingsRef),
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
  AutoDisposeFutureProviderElement<LibrarySettings> createElement() {
    return _LibrarySettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LibrarySettingsProvider && other.libraryId == libraryId;
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
mixin LibrarySettingsRef on AutoDisposeFutureProviderRef<LibrarySettings> {
  /// The parameter `libraryId` of this provider.
  String get libraryId;
}

class _LibrarySettingsProviderElement
    extends AutoDisposeFutureProviderElement<LibrarySettings>
    with LibrarySettingsRef {
  _LibrarySettingsProviderElement(super.provider);

  @override
  String get libraryId => (origin as LibrarySettingsProvider).libraryId;
}

String _$libraryStatsHash() => r'57c8e5fbb8e88925633c823a8aa2215465e8937e';

/// See also [libraryStats].
@ProviderFor(libraryStats)
const libraryStatsProvider = LibraryStatsFamily();

/// See also [libraryStats].
class LibraryStatsFamily extends Family<AsyncValue<Map<String, int>>> {
  /// See also [libraryStats].
  const LibraryStatsFamily();

  /// See also [libraryStats].
  LibraryStatsProvider call(
    String libraryId,
  ) {
    return LibraryStatsProvider(
      libraryId,
    );
  }

  @override
  LibraryStatsProvider getProviderOverride(
    covariant LibraryStatsProvider provider,
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
  String? get name => r'libraryStatsProvider';
}

/// See also [libraryStats].
class LibraryStatsProvider extends AutoDisposeFutureProvider<Map<String, int>> {
  /// See also [libraryStats].
  LibraryStatsProvider(
    String libraryId,
  ) : this._internal(
          (ref) => libraryStats(
            ref as LibraryStatsRef,
            libraryId,
          ),
          from: libraryStatsProvider,
          name: r'libraryStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$libraryStatsHash,
          dependencies: LibraryStatsFamily._dependencies,
          allTransitiveDependencies:
              LibraryStatsFamily._allTransitiveDependencies,
          libraryId: libraryId,
        );

  LibraryStatsProvider._internal(
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
    FutureOr<Map<String, int>> Function(LibraryStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LibraryStatsProvider._internal(
        (ref) => create(ref as LibraryStatsRef),
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
  AutoDisposeFutureProviderElement<Map<String, int>> createElement() {
    return _LibraryStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryStatsProvider && other.libraryId == libraryId;
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
mixin LibraryStatsRef on AutoDisposeFutureProviderRef<Map<String, int>> {
  /// The parameter `libraryId` of this provider.
  String get libraryId;
}

class _LibraryStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, int>>
    with LibraryStatsRef {
  _LibraryStatsProviderElement(super.provider);

  @override
  String get libraryId => (origin as LibraryStatsProvider).libraryId;
}

String _$totalStatsHash() => r'd1f9c34710b1cbe6901659656e9d2e8e8cf9e758';

/// See also [totalStats].
@ProviderFor(totalStats)
final totalStatsProvider = AutoDisposeFutureProvider<Map<String, int>>.internal(
  totalStats,
  name: r'totalStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalStatsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$libraryActionsHash() => r'e110ec6a1c9c9fe38bf5747a971ca27d878a3e1a';

/// See also [LibraryActions].
@ProviderFor(LibraryActions)
final libraryActionsProvider =
    AutoDisposeNotifierProvider<LibraryActions, void>.internal(
  LibraryActions.new,
  name: r'libraryActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryActions = AutoDisposeNotifier<void>;
String _$libraryScanStateHash() => r'588b6994e41a10c1941744a40fff75e09b2d7cf6';

/// See also [LibraryScanState].
@ProviderFor(LibraryScanState)
final libraryScanStateProvider = AutoDisposeAsyncNotifierProvider<
    LibraryScanState, Map<String, bool>>.internal(
  LibraryScanState.new,
  name: r'libraryScanStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryScanStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryScanState = AutoDisposeAsyncNotifier<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

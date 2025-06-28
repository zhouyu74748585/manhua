// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enabledLibrariesHash() => r'eca2b5498fb07d947e291dd5608f2379fef54e11';

/// See also [enabledLibraries].
@ProviderFor(enabledLibraries)
final enabledLibrariesProvider =
    AutoDisposeFutureProvider<List<MangaLibrary>>.internal(
  enabledLibraries,
  name: r'enabledLibrariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enabledLibrariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnabledLibrariesRef = AutoDisposeFutureProviderRef<List<MangaLibrary>>;
String _$libraryByIdHash() => r'7a796b2acbe952f450d1cf7e27bdd7c0049b70a4';

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

/// See also [libraryById].
@ProviderFor(libraryById)
const libraryByIdProvider = LibraryByIdFamily();

/// See also [libraryById].
class LibraryByIdFamily extends Family<AsyncValue<MangaLibrary?>> {
  /// See also [libraryById].
  const LibraryByIdFamily();

  /// See also [libraryById].
  LibraryByIdProvider call(
    String id,
  ) {
    return LibraryByIdProvider(
      id,
    );
  }

  @override
  LibraryByIdProvider getProviderOverride(
    covariant LibraryByIdProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'libraryByIdProvider';
}

/// See also [libraryById].
class LibraryByIdProvider extends AutoDisposeFutureProvider<MangaLibrary?> {
  /// See also [libraryById].
  LibraryByIdProvider(
    String id,
  ) : this._internal(
          (ref) => libraryById(
            ref as LibraryByIdRef,
            id,
          ),
          from: libraryByIdProvider,
          name: r'libraryByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$libraryByIdHash,
          dependencies: LibraryByIdFamily._dependencies,
          allTransitiveDependencies:
              LibraryByIdFamily._allTransitiveDependencies,
          id: id,
        );

  LibraryByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<MangaLibrary?> Function(LibraryByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LibraryByIdProvider._internal(
        (ref) => create(ref as LibraryByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MangaLibrary?> createElement() {
    return _LibraryByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LibraryByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LibraryByIdRef on AutoDisposeFutureProviderRef<MangaLibrary?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _LibraryByIdProviderElement
    extends AutoDisposeFutureProviderElement<MangaLibrary?>
    with LibraryByIdRef {
  _LibraryByIdProviderElement(super.provider);

  @override
  String get id => (origin as LibraryByIdProvider).id;
}

String _$libraryNotifierHash() => r'a56d6eec17fe3b20ca416da614a98538a84d6289';

/// See also [LibraryNotifier].
@ProviderFor(LibraryNotifier)
final libraryNotifierProvider = AutoDisposeAsyncNotifierProvider<
    LibraryNotifier, List<MangaLibrary>>.internal(
  LibraryNotifier.new,
  name: r'libraryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryNotifier = AutoDisposeAsyncNotifier<List<MangaLibrary>>;
String _$scanStatusHash() => r'fc5ef0ddf471cd732ae19ebe669f9821106a507a';

/// See also [ScanStatus].
@ProviderFor(ScanStatus)
final scanStatusProvider =
    AutoDisposeNotifierProvider<ScanStatus, Map<String, bool>>.internal(
  ScanStatus.new,
  name: r'scanStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScanStatus = AutoDisposeNotifier<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

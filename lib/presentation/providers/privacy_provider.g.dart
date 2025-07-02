// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$privateLibrariesHash() => r'cee6b11106ed09d9eedd77509c70e9723d732569';

/// 获取隐私库列表
///
/// Copied from [privateLibraries].
@ProviderFor(privateLibraries)
final privateLibrariesProvider =
    AutoDisposeFutureProvider<List<MangaLibrary>>.internal(
  privateLibraries,
  name: r'privateLibrariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$privateLibrariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrivateLibrariesRef = AutoDisposeFutureProviderRef<List<MangaLibrary>>;
String _$activatedPrivateLibrariesHash() =>
    r'26da345dbb13c5fdc148163003ac85e21c6473fa';

/// 获取已激活的隐私库列表
///
/// Copied from [activatedPrivateLibraries].
@ProviderFor(activatedPrivateLibraries)
final activatedPrivateLibrariesProvider =
    AutoDisposeFutureProvider<List<MangaLibrary>>.internal(
  activatedPrivateLibraries,
  name: r'activatedPrivateLibrariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activatedPrivateLibrariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivatedPrivateLibrariesRef
    = AutoDisposeFutureProviderRef<List<MangaLibrary>>;
String _$privacyNotifierHash() => r'3e9afbcfce5aea608617ee3cd7e6077706e3e35d';

/// 隐私模式状态管理器
///
/// Copied from [PrivacyNotifier].
@ProviderFor(PrivacyNotifier)
final privacyNotifierProvider =
    AutoDisposeNotifierProvider<PrivacyNotifier, PrivacyState>.internal(
  PrivacyNotifier.new,
  name: r'privacyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$privacyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PrivacyNotifier = AutoDisposeNotifier<PrivacyState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

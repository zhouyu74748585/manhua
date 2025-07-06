// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsNotifierHash() =>
    r'484e9860cd40a6fe08dba4a5216e4f0c5e0f8277';

/// See also [AppSettingsNotifier].
@ProviderFor(AppSettingsNotifier)
final appSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AppSettingsNotifier, AppSettings>.internal(
  AppSettingsNotifier.new,
  name: r'appSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppSettingsNotifier = AutoDisposeAsyncNotifier<AppSettings>;
String _$readerSettingsNotifierHash() =>
    r'315edefa5a47bbb28649e97de9c8dbf0c39b5209';

/// See also [ReaderSettingsNotifier].
@ProviderFor(ReaderSettingsNotifier)
final readerSettingsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ReaderSettingsNotifier, ReaderSettings>.internal(
  ReaderSettingsNotifier.new,
  name: r'readerSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readerSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReaderSettingsNotifier = AutoDisposeAsyncNotifier<ReaderSettings>;
String _$libraryViewSettingsNotifierHash() =>
    r'da3dbe743afaa79ece909f5d1fbd2fa758ef7fce';

/// See also [LibraryViewSettingsNotifier].
@ProviderFor(LibraryViewSettingsNotifier)
final libraryViewSettingsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    LibraryViewSettingsNotifier, LibraryViewSettings>.internal(
  LibraryViewSettingsNotifier.new,
  name: r'libraryViewSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryViewSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryViewSettingsNotifier
    = AutoDisposeAsyncNotifier<LibraryViewSettings>;
String _$downloadSettingsNotifierHash() =>
    r'88e1407dffc09e92cd5f32e7f431a71e762e0b58';

/// See also [DownloadSettingsNotifier].
@ProviderFor(DownloadSettingsNotifier)
final downloadSettingsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    DownloadSettingsNotifier, DownloadSettings>.internal(
  DownloadSettingsNotifier.new,
  name: r'downloadSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DownloadSettingsNotifier = AutoDisposeAsyncNotifier<DownloadSettings>;
String _$settingsActionsHash() => r'056ac6fa8d40e0d3efe084723b2109d1267df133';

/// See also [SettingsActions].
@ProviderFor(SettingsActions)
final settingsActionsProvider =
    AutoDisposeNotifierProvider<SettingsActions, void>.internal(
  SettingsActions.new,
  name: r'settingsActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

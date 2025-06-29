import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/constants/app_constants.dart';

part 'settings_provider.g.dart';

// 设置仓库提供者
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return LocalSettingsRepository();
});

// 应用设置提供者
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getAppSettings();
  }
  
  Future<void> updateSettings(AppSettings settings) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveAppSettings(settings);
    ref.invalidateSelf();
  }
  
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(themeMode: themeMode);
    await updateSettings(newSettings);
  }
  
  Future<void> updateLocale(Locale locale) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(locale: locale);
    await updateSettings(newSettings);
  }
}

// 阅读器设置提供者
@riverpod
class ReaderSettingsNotifier extends _$ReaderSettingsNotifier {
  @override
  Future<ReaderSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getReaderSettings();
  }
  
  Future<void> updateSettings(ReaderSettings settings) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveReaderSettings(settings);
    ref.invalidateSelf();
  }
  
  Future<void> updateReadingMode(ReadingMode mode) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(readingMode: mode);
    await updateSettings(newSettings);
  }
  
  Future<void> updateReadingDirection(ReadingDirection direction) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(readingDirection: direction);
    await updateSettings(newSettings);
  }
  
  Future<void> updateFullscreen(bool fullscreen) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(fullscreen: fullscreen);
    await updateSettings(newSettings);
  }
  
  Future<void> updateKeepScreenOn(bool keepScreenOn) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(keepScreenOn: keepScreenOn);
    await updateSettings(newSettings);
  }
  
  Future<void> updateBrightness(double brightness) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(brightness: brightness);
    await updateSettings(newSettings);
  }
}

// 库视图设置提供者
@riverpod
class LibraryViewSettingsNotifier extends _$LibraryViewSettingsNotifier {
  @override
  Future<LibraryViewSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getLibraryViewSettings();
  }
  
  Future<void> updateSettings(LibraryViewSettings settings) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveLibraryViewSettings(settings);
    ref.invalidateSelf();
  }
  
  Future<void> updateViewMode(ViewMode viewMode) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(viewMode: viewMode);
    await updateSettings(newSettings);
  }
  
  Future<void> updateSortAscending(bool sortAscending) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(sortAscending: sortAscending);
    await updateSettings(newSettings);
  }
  
  Future<void> updateGridColumns(int gridColumns) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(gridColumns: gridColumns);
    await updateSettings(newSettings);
  }
}

// 下载设置提供者
@riverpod
class DownloadSettingsNotifier extends _$DownloadSettingsNotifier {
  @override
  Future<DownloadSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getDownloadSettings();
  }
  
  Future<void> updateSettings(DownloadSettings settings) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveDownloadSettings(settings);
    ref.invalidateSelf();
  }
  
  Future<void> updateDownloadOnlyOnWifi(bool downloadOnlyOnWifi) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(downloadOnlyOnWifi: downloadOnlyOnWifi);
    await updateSettings(newSettings);
  }
  
  Future<void> updateMaxConcurrentDownloads(int maxConcurrentDownloads) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(maxConcurrentDownloads: maxConcurrentDownloads);
    await updateSettings(newSettings);
  }
  
  Future<void> updateDownloadPath(String downloadPath) async {
    final currentSettings = await future;
    final newSettings = currentSettings.copyWith(downloadPath: downloadPath);
    await updateSettings(newSettings);
  }
}

// 设置操作提供者
@riverpod
class SettingsActions extends _$SettingsActions {
  @override
  void build() {}
  
  Future<void> resetAllSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.resetToDefaults();
    
    // 刷新所有设置提供者
    ref.invalidate(appSettingsNotifierProvider);
    ref.invalidate(readerSettingsNotifierProvider);
    ref.invalidate(libraryViewSettingsNotifierProvider);
    ref.invalidate(downloadSettingsNotifierProvider);
  }
  
  Future<void> resetReaderSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.resetReaderSettings();
    ref.invalidate(readerSettingsNotifierProvider);
  }
  
  Future<void> resetLibrarySettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.resetLibrarySettings();
    ref.invalidate(libraryViewSettingsNotifierProvider);
  }
  
  Future<void> resetDownloadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.resetDownloadSettings();
    ref.invalidate(downloadSettingsNotifierProvider);
  }
  
  Future<Map<String, dynamic>> exportSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    return repository.exportSettings();
  }
  
  Future<void> importSettings(Map<String, dynamic> data) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.importSettings(data);
    
    // 刷新所有设置提供者
    ref.invalidate(appSettingsNotifierProvider);
    ref.invalidate(readerSettingsNotifierProvider);
    ref.invalidate(libraryViewSettingsNotifierProvider);
    ref.invalidate(downloadSettingsNotifierProvider);
  }
}
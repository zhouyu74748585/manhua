import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_constants.dart';

part 'settings.g.dart';

@JsonSerializable()
class AppSettings {
  final ThemeMode themeMode;
  @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
  final Locale locale;
  final ReaderSettings readerSettings;
  final LibraryViewSettings librarySettings;
  final DownloadSettings downloadSettings;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final DateTime? lastBackupAt;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('zh', 'CN'),
    this.readerSettings = const ReaderSettings(),
    this.librarySettings = const LibraryViewSettings(),
    this.downloadSettings = const DownloadSettings(),
    this.enableAnalytics = false,
    this.enableCrashReporting = false,
    this.lastBackupAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  static Locale _localeFromJson(Map<String, dynamic> json) {
    return Locale(
        json['languageCode'] as String, json['countryCode'] as String?);
  }

  static Map<String, dynamic> _localeToJson(Locale locale) {
    return {
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
    };
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    ReaderSettings? readerSettings,
    LibraryViewSettings? librarySettings,
    DownloadSettings? downloadSettings,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    DateTime? lastBackupAt,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      readerSettings: readerSettings ?? this.readerSettings,
      librarySettings: librarySettings ?? this.librarySettings,
      downloadSettings: downloadSettings ?? this.downloadSettings,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    );
  }
}

@JsonSerializable()
class ReaderSettings {
  final ReadingMode readingMode;
  final ReadingDirection readingDirection;
  final ImageFitMode imageFit;
  final bool fullscreen;
  final bool keepScreenOn;
  final double brightness;
  final bool showPageNumber;
  final bool showBattery;
  final bool showClock;
  final bool enableVolumeKeys;
  final bool enableTapNavigation;
  final double doubleTapZoomScale;
  final bool enablePreloading;
  final int preloadPages;

  const ReaderSettings({
    this.readingMode = ReadingMode.single,
    this.readingDirection = ReadingDirection.leftToRight,
    this.imageFit = ImageFitMode.fitWidth,
    this.fullscreen = true,
    this.keepScreenOn = true,
    this.brightness = 1.0,
    this.showPageNumber = true,
    this.showBattery = true,
    this.showClock = true,
    this.enableVolumeKeys = true,
    this.enableTapNavigation = true,
    this.doubleTapZoomScale = 2.0,
    this.enablePreloading = true,
    this.preloadPages = 3,
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) =>
      _$ReaderSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ReaderSettingsToJson(this);

  ReaderSettings copyWith({
    ReadingMode? readingMode,
    ReadingDirection? readingDirection,
    ImageFitMode? imageFit,
    bool? fullscreen,
    bool? keepScreenOn,
    double? brightness,
    bool? showPageNumber,
    bool? showBattery,
    bool? showClock,
    bool? enableVolumeKeys,
    bool? enableTapNavigation,
    double? doubleTapZoomScale,
    bool? enablePreloading,
    int? preloadPages,
  }) {
    return ReaderSettings(
      readingMode: readingMode ?? this.readingMode,
      readingDirection: readingDirection ?? this.readingDirection,
      imageFit: imageFit ?? this.imageFit,
      fullscreen: fullscreen ?? this.fullscreen,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      brightness: brightness ?? this.brightness,
      showPageNumber: showPageNumber ?? this.showPageNumber,
      showBattery: showBattery ?? this.showBattery,
      showClock: showClock ?? this.showClock,
      enableVolumeKeys: enableVolumeKeys ?? this.enableVolumeKeys,
      enableTapNavigation: enableTapNavigation ?? this.enableTapNavigation,
      doubleTapZoomScale: doubleTapZoomScale ?? this.doubleTapZoomScale,
      enablePreloading: enablePreloading ?? this.enablePreloading,
      preloadPages: preloadPages ?? this.preloadPages,
    );
  }
}

@JsonSerializable()
class LibraryViewSettings {
  final ViewMode viewMode;
  final SortOrder sortBy;
  final bool sortAscending;
  final int gridColumns;
  final bool showUnread;
  final bool showDownloaded;
  final List<String> hiddenCategories;

  const LibraryViewSettings({
    this.viewMode = ViewMode.grid,
    this.sortBy = SortOrder.titleAsc,
    this.sortAscending = true,
    this.gridColumns = 3,
    this.showUnread = true,
    this.showDownloaded = true,
    this.hiddenCategories = const [],
  });

  factory LibraryViewSettings.fromJson(Map<String, dynamic> json) =>
      _$LibraryViewSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryViewSettingsToJson(this);

  LibraryViewSettings copyWith({
    ViewMode? viewMode,
    SortOrder? sortBy,
    bool? sortAscending,
    int? gridColumns,
    bool? showUnread,
    bool? showDownloaded,
    List<String>? hiddenCategories,
  }) {
    return LibraryViewSettings(
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      gridColumns: gridColumns ?? this.gridColumns,
      showUnread: showUnread ?? this.showUnread,
      showDownloaded: showDownloaded ?? this.showDownloaded,
      hiddenCategories: hiddenCategories ?? this.hiddenCategories,
    );
  }
}

@JsonSerializable()
class DownloadSettings {
  final bool downloadOnlyOnWifi;

  final int maxConcurrentDownloads;

  final String downloadPath;

  final bool deleteAfterReading;

  final int maxStorageSize; // MB

  final bool autoDeleteOldChapters;

  const DownloadSettings({
    this.downloadOnlyOnWifi = true,
    this.maxConcurrentDownloads = 3,
    this.downloadPath = '',
    this.deleteAfterReading = false,
    this.maxStorageSize = 1024, // 1GB
    this.autoDeleteOldChapters = false,
  });

  factory DownloadSettings.fromJson(Map<String, dynamic> json) =>
      _$DownloadSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadSettingsToJson(this);

  DownloadSettings copyWith({
    bool? downloadOnlyOnWifi,
    int? maxConcurrentDownloads,
    String? downloadPath,
    bool? deleteAfterReading,
    int? maxStorageSize,
    bool? autoDeleteOldChapters,
  }) {
    return DownloadSettings(
      downloadOnlyOnWifi: downloadOnlyOnWifi ?? this.downloadOnlyOnWifi,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      downloadPath: downloadPath ?? this.downloadPath,
      deleteAfterReading: deleteAfterReading ?? this.deleteAfterReading,
      maxStorageSize: maxStorageSize ?? this.maxStorageSize,
      autoDeleteOldChapters:
          autoDeleteOldChapters ?? this.autoDeleteOldChapters,
    );
  }
}

enum ViewMode {
  grid,
  list,
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      locale: json['locale'] == null
          ? const Locale('zh', 'CN')
          : AppSettings._localeFromJson(json['locale'] as Map<String, dynamic>),
      readerSettings: json['readerSettings'] == null
          ? const ReaderSettings()
          : ReaderSettings.fromJson(
              json['readerSettings'] as Map<String, dynamic>),
      librarySettings: json['librarySettings'] == null
          ? const LibraryViewSettings()
          : LibraryViewSettings.fromJson(
              json['librarySettings'] as Map<String, dynamic>),
      downloadSettings: json['downloadSettings'] == null
          ? const DownloadSettings()
          : DownloadSettings.fromJson(
              json['downloadSettings'] as Map<String, dynamic>),
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? false,
      lastBackupAt: json['lastBackupAt'] == null
          ? null
          : DateTime.parse(json['lastBackupAt'] as String),
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'locale': AppSettings._localeToJson(instance.locale),
      'readerSettings': instance.readerSettings,
      'librarySettings': instance.librarySettings,
      'downloadSettings': instance.downloadSettings,
      'enableAnalytics': instance.enableAnalytics,
      'enableCrashReporting': instance.enableCrashReporting,
      'lastBackupAt': instance.lastBackupAt?.toIso8601String(),
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

ReaderSettings _$ReaderSettingsFromJson(Map<String, dynamic> json) =>
    ReaderSettings(
      readingMode:
          $enumDecodeNullable(_$ReadingModeEnumMap, json['readingMode']) ??
              ReadingMode.single,
      readingDirection: $enumDecodeNullable(
              _$ReadingDirectionEnumMap, json['readingDirection']) ??
          ReadingDirection.leftToRight,
      imageFit: $enumDecodeNullable(_$ImageFitModeEnumMap, json['imageFit']) ??
          ImageFitMode.fitWidth,
      fullscreen: json['fullscreen'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? true,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 1.0,
      showPageNumber: json['showPageNumber'] as bool? ?? true,
      showBattery: json['showBattery'] as bool? ?? true,
      showClock: json['showClock'] as bool? ?? true,
      enableVolumeKeys: json['enableVolumeKeys'] as bool? ?? true,
      enableTapNavigation: json['enableTapNavigation'] as bool? ?? true,
      doubleTapZoomScale:
          (json['doubleTapZoomScale'] as num?)?.toDouble() ?? 2.0,
      enablePreloading: json['enablePreloading'] as bool? ?? true,
      preloadPages: (json['preloadPages'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$ReaderSettingsToJson(ReaderSettings instance) =>
    <String, dynamic>{
      'readingMode': _$ReadingModeEnumMap[instance.readingMode]!,
      'readingDirection': _$ReadingDirectionEnumMap[instance.readingDirection]!,
      'imageFit': _$ImageFitModeEnumMap[instance.imageFit]!,
      'fullscreen': instance.fullscreen,
      'keepScreenOn': instance.keepScreenOn,
      'brightness': instance.brightness,
      'showPageNumber': instance.showPageNumber,
      'showBattery': instance.showBattery,
      'showClock': instance.showClock,
      'enableVolumeKeys': instance.enableVolumeKeys,
      'enableTapNavigation': instance.enableTapNavigation,
      'doubleTapZoomScale': instance.doubleTapZoomScale,
      'enablePreloading': instance.enablePreloading,
      'preloadPages': instance.preloadPages,
    };

const _$ReadingModeEnumMap = {
  ReadingMode.single: 'single',
  ReadingMode.double: 'double',
  ReadingMode.continuous: 'continuous',
};

const _$ReadingDirectionEnumMap = {
  ReadingDirection.leftToRight: 'leftToRight',
  ReadingDirection.rightToLeft: 'rightToLeft',
};

const _$ImageFitModeEnumMap = {
  ImageFitMode.fitWidth: 'fitWidth',
  ImageFitMode.fitHeight: 'fitHeight',
  ImageFitMode.fitScreen: 'fitScreen',
  ImageFitMode.originalSize: 'originalSize',
};

LibraryViewSettings _$LibraryViewSettingsFromJson(Map<String, dynamic> json) =>
    LibraryViewSettings(
      viewMode: $enumDecodeNullable(_$ViewModeEnumMap, json['viewMode']) ??
          ViewMode.grid,
      sortBy: $enumDecodeNullable(_$SortOrderEnumMap, json['sortBy']) ??
          SortOrder.titleAsc,
      sortAscending: json['sortAscending'] as bool? ?? true,
      gridColumns: (json['gridColumns'] as num?)?.toInt() ?? 3,
      showUnread: json['showUnread'] as bool? ?? true,
      showDownloaded: json['showDownloaded'] as bool? ?? true,
      hiddenCategories: (json['hiddenCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LibraryViewSettingsToJson(
        LibraryViewSettings instance) =>
    <String, dynamic>{
      'viewMode': _$ViewModeEnumMap[instance.viewMode]!,
      'sortBy': _$SortOrderEnumMap[instance.sortBy]!,
      'sortAscending': instance.sortAscending,
      'gridColumns': instance.gridColumns,
      'showUnread': instance.showUnread,
      'showDownloaded': instance.showDownloaded,
      'hiddenCategories': instance.hiddenCategories,
    };

const _$ViewModeEnumMap = {
  ViewMode.grid: 'grid',
  ViewMode.list: 'list',
};

const _$SortOrderEnumMap = {
  SortOrder.titleAsc: 'titleAsc',
  SortOrder.titleDesc: 'titleDesc',
  SortOrder.createdAtAsc: 'createdAtAsc',
  SortOrder.createdAtDesc: 'createdAtDesc',
  SortOrder.updatedAtAsc: 'updatedAtAsc',
  SortOrder.updatedAtDesc: 'updatedAtDesc',
  SortOrder.sizeAsc: 'sizeAsc',
  SortOrder.sizeDesc: 'sizeDesc',
};

DownloadSettings _$DownloadSettingsFromJson(Map<String, dynamic> json) =>
    DownloadSettings(
      downloadOnlyOnWifi: json['downloadOnlyOnWifi'] as bool? ?? true,
      maxConcurrentDownloads:
          (json['maxConcurrentDownloads'] as num?)?.toInt() ?? 3,
      downloadPath: json['downloadPath'] as String? ?? '',
      deleteAfterReading: json['deleteAfterReading'] as bool? ?? false,
      maxStorageSize: (json['maxStorageSize'] as num?)?.toInt() ?? 1024,
      autoDeleteOldChapters: json['autoDeleteOldChapters'] as bool? ?? false,
    );

Map<String, dynamic> _$DownloadSettingsToJson(DownloadSettings instance) =>
    <String, dynamic>{
      'downloadOnlyOnWifi': instance.downloadOnlyOnWifi,
      'maxConcurrentDownloads': instance.maxConcurrentDownloads,
      'downloadPath': instance.downloadPath,
      'deleteAfterReading': instance.deleteAfterReading,
      'maxStorageSize': instance.maxStorageSize,
      'autoDeleteOldChapters': instance.autoDeleteOldChapters,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaLibrary _$MangaLibraryFromJson(Map<String, dynamic> json) => MangaLibrary(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: $enumDecode(_$LibraryTypeEnumMap, json['type']),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastScanAt: json['lastScanAt'] == null
          ? null
          : DateTime.parse(json['lastScanAt'] as String),
      mangaCount: (json['mangaCount'] as num?)?.toInt() ?? 0,
      settings: json['settings'] == null
          ? const LibrarySettings()
          : LibrarySettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MangaLibraryToJson(MangaLibrary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'type': _$LibraryTypeEnumMap[instance.type]!,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastScanAt': instance.lastScanAt?.toIso8601String(),
      'mangaCount': instance.mangaCount,
      'settings': instance.settings,
    };

const _$LibraryTypeEnumMap = {
  LibraryType.local: 'local',
  LibraryType.network: 'network',
  LibraryType.cloud: 'cloud',
};

LibrarySettings _$LibrarySettingsFromJson(Map<String, dynamic> json) =>
    LibrarySettings(
      autoScan: json['autoScan'] as bool? ?? false,
      scanInterval: json['scanInterval'] == null
          ? const Duration(hours: 24)
          : Duration(microseconds: (json['scanInterval'] as num).toInt()),
      supportedFormats: (json['supportedFormats'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['.cbz', '.cbr', '.zip', '.rar', '.pdf'],
      includeSubfolders: json['includeSubfolders'] as bool? ?? true,
      coverPattern: json['coverPattern'] as String?,
      generateThumbnails: json['generateThumbnails'] as bool? ?? true,
      coverDisplayMode: $enumDecodeNullable(
              _$CoverDisplayModeEnumMap, json['coverDisplayMode']) ??
          CoverDisplayMode.defaultMode,
      coverScale: (json['coverScale'] as num?)?.toDouble() ?? 3.0,
      coverOffsetX: (json['coverOffsetX'] as num?)?.toDouble() ?? 0.4,
    );

Map<String, dynamic> _$LibrarySettingsToJson(LibrarySettings instance) =>
    <String, dynamic>{
      'autoScan': instance.autoScan,
      'scanInterval': instance.scanInterval.inMicroseconds,
      'supportedFormats': instance.supportedFormats,
      'includeSubfolders': instance.includeSubfolders,
      'coverPattern': instance.coverPattern,
      'generateThumbnails': instance.generateThumbnails,
      'coverDisplayMode': _$CoverDisplayModeEnumMap[instance.coverDisplayMode]!,
      'coverScale': instance.coverScale,
      'coverOffsetX': instance.coverOffsetX,
    };

const _$CoverDisplayModeEnumMap = {
  CoverDisplayMode.defaultMode: 'default',
  CoverDisplayMode.leftHalf: 'left_half',
  CoverDisplayMode.rightHalf: 'right_half',
};

import 'package:json_annotation/json_annotation.dart';

part 'library.g.dart';

@JsonSerializable()
class MangaLibrary {
  final String id;
  final String name;
  final String path;
  final LibraryType type;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastScanAt;
  final int mangaCount;
  final LibrarySettings settings;

  const MangaLibrary({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    this.isEnabled = true,
    required this.createdAt,
    this.lastScanAt,
    this.mangaCount = 0,
    this.settings = const LibrarySettings(),
  });

  factory MangaLibrary.fromJson(Map<String, dynamic> json) =>
      _$MangaLibraryFromJson(json);
  Map<String, dynamic> toJson() => _$MangaLibraryToJson(this);

  MangaLibrary copyWith({
    String? id,
    String? name,
    String? path,
    LibraryType? type,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastScanAt,
    int? mangaCount,
    LibrarySettings? settings,
  }) {
    return MangaLibrary(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastScanAt: lastScanAt ?? this.lastScanAt,
      mangaCount: mangaCount ?? this.mangaCount,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MangaLibrary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}

enum LibraryType {
  @JsonValue('local')
  local,
  @JsonValue('network')
  network,
  @JsonValue('cloud')
  cloud,
}

extension LibraryTypeExtension on LibraryType {
  String get displayName {
    switch (this) {
      case LibraryType.local:
        return '本地';
      case LibraryType.network:
        return '网络';
      case LibraryType.cloud:
        return '云端';
    }
  }

  String get description {
    switch (this) {
      case LibraryType.local:
        return '本地文件夹中的漫画';
      case LibraryType.network:
        return '网络共享文件夹';
      case LibraryType.cloud:
        return '云存储服务';
    }
  }
}

@JsonSerializable()
class LibrarySettings {
  final bool autoScan;
  final Duration scanInterval;
  final List<String> supportedFormats;
  final bool includeSubfolders;
  final String? coverPattern;
  final bool generateThumbnails;
  final CoverDisplayMode coverDisplayMode;

  const LibrarySettings({
    this.autoScan = false,
    this.scanInterval = const Duration(hours: 24),
    this.supportedFormats = const ['.cbz', '.cbr', '.zip', '.rar', '.pdf'],
    this.includeSubfolders = true,
    this.coverPattern,
    this.generateThumbnails = true,
    this.coverDisplayMode = CoverDisplayMode.defaultMode,
  });

  factory LibrarySettings.fromJson(Map<String, dynamic> json) =>
      _$LibrarySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$LibrarySettingsToJson(this);

  LibrarySettings copyWith({
    bool? autoScan,
    Duration? scanInterval,
    List<String>? supportedFormats,
    bool? includeSubfolders,
    String? coverPattern,
    bool? generateThumbnails,
    CoverDisplayMode? coverDisplayMode,
  }) {
    return LibrarySettings(
      autoScan: autoScan ?? this.autoScan,
      scanInterval: scanInterval ?? this.scanInterval,
      supportedFormats: supportedFormats ?? this.supportedFormats,
      includeSubfolders: includeSubfolders ?? this.includeSubfolders,
      coverPattern: coverPattern ?? this.coverPattern,
      generateThumbnails: generateThumbnails ?? this.generateThumbnails,
      coverDisplayMode: coverDisplayMode ?? this.coverDisplayMode,
    );
  }
}

enum CoverDisplayMode {
  @JsonValue('default')
  defaultMode,
  @JsonValue('left_half')
  leftHalf,
  @JsonValue('right_half')
  rightHalf,
}

extension CoverDisplayModeExtension on CoverDisplayMode {
  String get displayName {
    switch (this) {
      case CoverDisplayMode.defaultMode:
        return '默认';
      case CoverDisplayMode.leftHalf:
        return '左半';
      case CoverDisplayMode.rightHalf:
        return '右半';
    }
  }

  String get description {
    switch (this) {
      case CoverDisplayMode.defaultMode:
        return '显示完整封面图片';
      case CoverDisplayMode.leftHalf:
        return '只显示封面图片的左半部分';
      case CoverDisplayMode.rightHalf:
        return '只显示封面图片的右半部分';
    }
  }
}

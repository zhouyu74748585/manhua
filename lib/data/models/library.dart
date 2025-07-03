import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'library.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class MangaLibrary {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String path;
  @HiveField(3)
  final LibraryType type;
  @HiveField(4)
  final bool isEnabled;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime? lastScanAt;
  @HiveField(7)
  final int mangaCount;
  @HiveField(8)
  final LibrarySettings settings;
  @HiveField(9)
  final bool isScanning; // 扫描状态
  @HiveField(10)
  final bool isPrivate; // 隐私模式
  @HiveField(11)
  final bool isPrivateActivated; // 隐私模式是否已激活

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
    this.isScanning = false,
    this.isPrivate = false,
    this.isPrivateActivated = false,
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
    bool? isScanning,
    bool? isPrivate,
    bool? isPrivateActivated,
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
      isScanning: isScanning ?? this.isScanning,
      isPrivate: isPrivate ?? this.isPrivate,
      isPrivateActivated: isPrivateActivated ?? this.isPrivateActivated,
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

@HiveType(typeId: 5)
enum LibraryType {
  @HiveField(0)
  @JsonValue('local')
  local,
  @HiveField(1)
  @JsonValue('network')
  network,
  @HiveField(2)
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
@HiveType(typeId: 6)
class LibrarySettings {
  @HiveField(0)
  final bool autoScan;
  @HiveField(1)
  final Duration scanInterval;
  @HiveField(2)
  final List<String> supportedFormats;
  @HiveField(3)
  final bool includeSubfolders;
  @HiveField(4)
  final String? coverPattern;
  @HiveField(5)
  final bool generateThumbnails;
  @HiveField(6)
  final CoverDisplayMode coverDisplayMode;
  @HiveField(7)
  final double coverScale; // 封面缩放比例（宽高比）
  @HiveField(8)
  final double coverOffsetX; // 封面X轴偏移量

  const LibrarySettings({
    this.autoScan = false,
    this.scanInterval = const Duration(hours: 24),
    this.supportedFormats = const ['.cbz', '.cbr', '.zip', '.rar', '.pdf'],
    this.includeSubfolders = true,
    this.coverPattern,
    this.generateThumbnails = true,
    this.coverDisplayMode = CoverDisplayMode.defaultMode,
    this.coverScale = 3.0,
    this.coverOffsetX = 0.4,
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
    double? coverScale,
    double? coverOffsetX,
  }) {
    return LibrarySettings(
      autoScan: autoScan ?? this.autoScan,
      scanInterval: scanInterval ?? this.scanInterval,
      supportedFormats: supportedFormats ?? this.supportedFormats,
      includeSubfolders: includeSubfolders ?? this.includeSubfolders,
      coverPattern: coverPattern ?? this.coverPattern,
      generateThumbnails: generateThumbnails ?? this.generateThumbnails,
      coverDisplayMode: coverDisplayMode ?? this.coverDisplayMode,
      coverScale: coverScale ?? this.coverScale,
      coverOffsetX: coverOffsetX ?? this.coverOffsetX,
    );
  }
}

@HiveType(typeId: 7)
enum CoverDisplayMode {
  @HiveField(0)
  @JsonValue('default')
  defaultMode,
  @HiveField(1)
  @JsonValue('left_half')
  leftHalf,
  @HiveField(2)
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

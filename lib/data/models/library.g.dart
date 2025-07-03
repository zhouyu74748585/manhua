// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaLibraryAdapter extends TypeAdapter<MangaLibrary> {
  @override
  final int typeId = 4;

  @override
  MangaLibrary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MangaLibrary(
      id: fields[0] as String,
      name: fields[1] as String,
      path: fields[2] as String,
      type: fields[3] as LibraryType,
      isEnabled: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      lastScanAt: fields[6] as DateTime?,
      mangaCount: fields[7] as int,
      settings: fields[8] as LibrarySettings,
      isScanning: fields[9] as bool,
      isPrivate: fields[10] as bool,
      isPrivateActivated: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MangaLibrary obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastScanAt)
      ..writeByte(7)
      ..write(obj.mangaCount)
      ..writeByte(8)
      ..write(obj.settings)
      ..writeByte(9)
      ..write(obj.isScanning)
      ..writeByte(10)
      ..write(obj.isPrivate)
      ..writeByte(11)
      ..write(obj.isPrivateActivated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaLibraryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LibrarySettingsAdapter extends TypeAdapter<LibrarySettings> {
  @override
  final int typeId = 6;

  @override
  LibrarySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibrarySettings(
      autoScan: fields[0] as bool,
      scanInterval: fields[1] as Duration,
      supportedFormats: (fields[2] as List).cast<String>(),
      includeSubfolders: fields[3] as bool,
      coverPattern: fields[4] as String?,
      generateThumbnails: fields[5] as bool,
      coverDisplayMode: fields[6] as CoverDisplayMode,
      coverScale: fields[7] as double,
      coverOffsetX: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LibrarySettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.autoScan)
      ..writeByte(1)
      ..write(obj.scanInterval)
      ..writeByte(2)
      ..write(obj.supportedFormats)
      ..writeByte(3)
      ..write(obj.includeSubfolders)
      ..writeByte(4)
      ..write(obj.coverPattern)
      ..writeByte(5)
      ..write(obj.generateThumbnails)
      ..writeByte(6)
      ..write(obj.coverDisplayMode)
      ..writeByte(7)
      ..write(obj.coverScale)
      ..writeByte(8)
      ..write(obj.coverOffsetX);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LibraryTypeAdapter extends TypeAdapter<LibraryType> {
  @override
  final int typeId = 5;

  @override
  LibraryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LibraryType.local;
      case 1:
        return LibraryType.network;
      case 2:
        return LibraryType.cloud;
      default:
        return LibraryType.local;
    }
  }

  @override
  void write(BinaryWriter writer, LibraryType obj) {
    switch (obj) {
      case LibraryType.local:
        writer.writeByte(0);
        break;
      case LibraryType.network:
        writer.writeByte(1);
        break;
      case LibraryType.cloud:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoverDisplayModeAdapter extends TypeAdapter<CoverDisplayMode> {
  @override
  final int typeId = 7;

  @override
  CoverDisplayMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CoverDisplayMode.defaultMode;
      case 1:
        return CoverDisplayMode.leftHalf;
      case 2:
        return CoverDisplayMode.rightHalf;
      default:
        return CoverDisplayMode.defaultMode;
    }
  }

  @override
  void write(BinaryWriter writer, CoverDisplayMode obj) {
    switch (obj) {
      case CoverDisplayMode.defaultMode:
        writer.writeByte(0);
        break;
      case CoverDisplayMode.leftHalf:
        writer.writeByte(1);
        break;
      case CoverDisplayMode.rightHalf:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverDisplayModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      isScanning: json['isScanning'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isPrivateActivated: json['isPrivateActivated'] as bool? ?? false,
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
      'isScanning': instance.isScanning,
      'isPrivate': instance.isPrivate,
      'isPrivateActivated': instance.isPrivateActivated,
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

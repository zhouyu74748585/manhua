import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../data/models/manga.dart';
import '../../../data/models/network_config.dart';
import 'network_file_system.dart';
import 'network_file_system_factory.dart';

/// 网络漫画缓存服务
/// 负责管理远程漫画文件的本地缓存
class NetworkMangaCacheService {
  static NetworkMangaCacheService? _instance;
  static NetworkMangaCacheService get instance =>
      _instance ??= NetworkMangaCacheService._();

  NetworkMangaCacheService._();

  Directory? _cacheDirectory;
  final Map<String, NetworkFileSystem> _fileSystemCache = {};

  /// 初始化缓存服务
  Future<void> init() async {
    if (_cacheDirectory == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory(path.join(appDir.path, 'network_cache'));
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
    }
  }

  /// 获取缓存目录
  Future<Directory> _getCacheDirectory() async {
    await init();
    return _cacheDirectory!;
  }

  /// 生成缓存文件路径
  String _generateCacheKey(String remotePath, String mangaId) {
    final hash = md5.convert('$remotePath:$mangaId'.codeUnits).toString();
    return hash;
  }

  /// 获取或创建网络文件系统
  Future<NetworkFileSystem> _getFileSystem(NetworkConfig config) async {
    final key = '${config.protocol}://${config.host}:${config.port}';

    if (!_fileSystemCache.containsKey(key)) {
      final fileSystem = NetworkFileSystemFactory.create(config);
      await fileSystem.connect();
      _fileSystemCache[key] = fileSystem;
    }

    return _fileSystemCache[key]!;
  }

  /// 缓存网络漫画封面
  /// [manga] 漫画对象
  /// [config] 网络配置
  /// 返回本地缓存路径
  Future<String?> cacheMangaCover(Manga manga, NetworkConfig config) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheKey = _generateCacheKey(manga.path, manga.id);
      final coverCacheDir = Directory(path.join(cacheDir.path, 'covers'));

      if (!await coverCacheDir.exists()) {
        await coverCacheDir.create(recursive: true);
      }

      // 检查是否已有缓存
      final existingFiles = await coverCacheDir.list().toList();
      final existingCover = existingFiles
          .whereType<File>()
          .where((file) => path.basenameWithoutExtension(file.path) == cacheKey)
          .firstOrNull;

      if (existingCover != null && await existingCover.exists()) {
        dev.log('使用已缓存的封面: ${manga.title}');
        return existingCover.path;
      }

      // 获取网络文件系统
      final fileSystem = await _getFileSystem(config);

      // 获取封面图片
      String? coverImagePath;
      if (manga.type == MangaType.folder) {
        // 目录类型：获取第一张图片作为封面
        coverImagePath =
            await _getFirstImageFromDirectory(fileSystem, manga.path);
      } else {
        // 压缩文件类型：下载并提取封面
        coverImagePath =
            await _extractCoverFromArchive(fileSystem, manga.path, cacheKey);
      }

      if (coverImagePath != null) {
        dev.log('成功缓存封面: ${manga.title} -> $coverImagePath');
        return coverImagePath;
      }

      return null;
    } catch (e, stackTrace) {
      dev.log('缓存漫画封面失败: ${manga.title}, 错误: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 从目录中获取第一张图片
  Future<String?> _getFirstImageFromDirectory(
      NetworkFileSystem fileSystem, String directoryPath) async {
    try {
      final files = await fileSystem.listDirectory(directoryPath);
      final imageFiles =
          files.where((file) => !file.isDirectory && file.isImageFile).toList();

      if (imageFiles.isEmpty) return null;

      // 按名称排序，获取第一张图片
      imageFiles.sort((a, b) => a.name.compareTo(b.name));
      final firstImage = imageFiles.first;

      // 下载图片到缓存
      final cacheDir = await _getCacheDirectory();
      final coverCacheDir = Directory(path.join(cacheDir.path, 'covers'));
      final cacheKey = _generateCacheKey(directoryPath, firstImage.name);
      final extension = path.extension(firstImage.name);
      final cacheFile =
          File(path.join(coverCacheDir.path, '$cacheKey$extension'));

      await fileSystem.downloadFileToLocal(firstImage.path, cacheFile.path);
      return cacheFile.path;
    } catch (e) {
      dev.log('从目录获取封面失败: $directoryPath, 错误: $e');
      return null;
    }
  }

  /// 从压缩文件中提取封面（流式处理）
  Future<String?> _extractCoverFromArchive(
      NetworkFileSystem fileSystem, String archivePath, String cacheKey) async {
    try {
      dev.log('开始流式提取压缩文件封面: $archivePath');

      // 确定文件类型
      final extension = path.extension(archivePath).toLowerCase();

      if (extension == '.zip' || extension == '.cbz') {
        return await _extractCoverFromZip(fileSystem, archivePath, cacheKey);
      } else if (extension == '.rar' || extension == '.cbr') {
        return await _extractCoverFromRar(fileSystem, archivePath, cacheKey);
      } else if (extension == '.7z' || extension == '.cb7') {
        return await _extractCoverFrom7z(fileSystem, archivePath, cacheKey);
      } else {
        dev.log('不支持的压缩文件格式: $extension');
        return null;
      }
    } catch (e) {
      dev.log('从压缩文件提取封面失败: $archivePath, 错误: $e');
      return null;
    }
  }

  /// 从ZIP文件中流式提取封面
  Future<String?> _extractCoverFromZip(
      NetworkFileSystem fileSystem, String archivePath, String cacheKey) async {
    try {
      // 流式下载ZIP文件的前64KB来查找中央目录
      const initialChunkSize = 65536; // 64KB
      final chunks = <int>[];

      await for (final chunk in fileSystem.downloadFileStream(archivePath,
          start: 0, length: initialChunkSize)) {
        chunks.addAll(chunk);
      }

      if (chunks.isEmpty) {
        dev.log('ZIP文件为空或下载失败: $archivePath');
        return null;
      }

      // 尝试解析ZIP文件
      final archive =
          ZipDecoder().decodeBytes(Uint8List.fromList(chunks), verify: false);

      // 查找第一个图片文件
      final imageExtensions = {
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.bmp',
        '.webp'
      };
      ArchiveFile? firstImageFile;

      for (final file in archive.files) {
        if (!file.isFile) continue;

        final ext = path.extension(file.name).toLowerCase();
        if (imageExtensions.contains(ext)) {
          firstImageFile = file;
          break;
        }
      }

      if (firstImageFile == null) {
        dev.log('ZIP文件中未找到图片文件: $archivePath');
        return null;
      }

      // 如果第一个图片文件在初始chunk中，直接提取
      if (firstImageFile.content.isNotEmpty) {
        return await _saveCoverImage(
            firstImageFile.content, cacheKey, firstImageFile.name);
      }

      // 如果需要更多数据，下载完整文件（这里可以进一步优化）
      dev.log('需要下载更多数据来提取封面: ${firstImageFile.name}');
      final fullData = await fileSystem.downloadFile(archivePath);
      final fullArchive = ZipDecoder().decodeBytes(fullData);

      for (final file in fullArchive.files) {
        if (file.name == firstImageFile.name && file.content.isNotEmpty) {
          return await _saveCoverImage(file.content, cacheKey, file.name);
        }
      }

      return null;
    } catch (e) {
      dev.log('从ZIP文件提取封面失败: $archivePath, 错误: $e');
      return null;
    }
  }

  /// 从RAR文件中提取封面（简化实现）
  Future<String?> _extractCoverFromRar(
      NetworkFileSystem fileSystem, String archivePath, String cacheKey) async {
    try {
      // RAR格式比较复杂，这里提供简化实现
      // 实际生产环境可能需要使用专门的RAR解压库
      dev.log('RAR文件封面提取功能需要专门的库支持: $archivePath');
      return null;
    } catch (e) {
      dev.log('从RAR文件提取封面失败: $archivePath, 错误: $e');
      return null;
    }
  }

  /// 从7Z文件中提取封面（简化实现）
  Future<String?> _extractCoverFrom7z(
      NetworkFileSystem fileSystem, String archivePath, String cacheKey) async {
    try {
      // 7Z格式比较复杂，这里提供简化实现
      dev.log('7Z文件封面提取功能需要专门的库支持: $archivePath');
      return null;
    } catch (e) {
      dev.log('从7Z文件提取封面失败: $archivePath, 错误: $e');
      return null;
    }
  }

  /// 保存封面图片到缓存
  Future<String?> _saveCoverImage(
      Uint8List imageData, String cacheKey, String originalName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final coverCacheDir = Directory(path.join(cacheDir.path, 'covers'));

      if (!await coverCacheDir.exists()) {
        await coverCacheDir.create(recursive: true);
      }

      // 根据原始文件扩展名确定保存格式
      final ext = path.extension(originalName).toLowerCase();
      final validExts = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'};
      final saveExt = validExts.contains(ext) ? ext : '.jpg';

      final coverFile =
          File(path.join(coverCacheDir.path, '$cacheKey$saveExt'));
      await coverFile.writeAsBytes(imageData);

      dev.log('封面图片已保存: ${coverFile.path}');
      return coverFile.path;
    } catch (e) {
      dev.log('保存封面图片失败: $e');
      return null;
    }
  }

  /// 缓存漫画页面
  /// [manga] 漫画对象
  /// [pageIndex] 页面索引
  /// [config] 网络配置
  /// 返回本地缓存路径
  Future<String?> cacheMangaPage(
      Manga manga, int pageIndex, NetworkConfig config) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final pageCacheDir =
          Directory(path.join(cacheDir.path, 'pages', manga.id));

      if (!await pageCacheDir.exists()) {
        await pageCacheDir.create(recursive: true);
      }

      final cacheFile =
          File(path.join(pageCacheDir.path, 'page_$pageIndex.jpg'));

      // 检查是否已有缓存
      if (await cacheFile.exists()) {
        return cacheFile.path;
      }

      // 获取网络文件系统
      final fileSystem = await _getFileSystem(config);

      if (manga.type == MangaType.folder) {
        // 目录类型：获取指定索引的图片
        final imagePath =
            await _getImageFromDirectory(fileSystem, manga.path, pageIndex);
        if (imagePath != null) {
          await fileSystem.downloadFileToLocal(imagePath, cacheFile.path);
          return cacheFile.path;
        }
      } else {
        // 压缩文件类型：提取指定页面
        // TODO: 实现压缩文件页面提取
        dev.log('压缩文件页面提取功能待实现: ${manga.path}');
      }

      return null;
    } catch (e, stackTrace) {
      dev.log('缓存漫画页面失败: ${manga.title} 页面$pageIndex, 错误: $e',
          stackTrace: stackTrace);
      return null;
    }
  }

  /// 从目录中获取指定索引的图片
  Future<String?> _getImageFromDirectory(
      NetworkFileSystem fileSystem, String directoryPath, int pageIndex) async {
    try {
      final files = await fileSystem.listDirectory(directoryPath);
      final imageFiles =
          files.where((file) => !file.isDirectory && file.isImageFile).toList();

      if (imageFiles.isEmpty || pageIndex >= imageFiles.length) return null;

      // 按名称排序
      imageFiles.sort((a, b) => a.name.compareTo(b.name));
      return imageFiles[pageIndex].path;
    } catch (e) {
      dev.log('从目录获取图片失败: $directoryPath 索引$pageIndex, 错误: $e');
      return null;
    }
  }

  /// 清理缓存
  /// [maxSizeBytes] 最大缓存大小（字节）
  /// [maxAgeHours] 最大缓存时间（小时）
  Future<void> cleanCache({int? maxSizeBytes, int? maxAgeHours}) async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return;

      final now = DateTime.now();
      int totalSize = 0;
      final List<FileSystemEntity> allFiles = [];

      // 收集所有缓存文件
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          allFiles.add(entity);
          final stat = await entity.stat();
          totalSize += stat.size;

          // 删除过期文件
          if (maxAgeHours != null) {
            final age = now.difference(stat.modified).inHours;
            if (age > maxAgeHours) {
              await entity.delete();
              dev.log('删除过期缓存文件: ${entity.path}');
              continue;
            }
          }
        }
      }

      // 如果超过大小限制，删除最旧的文件
      if (maxSizeBytes != null && totalSize > maxSizeBytes) {
        allFiles.sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return aStat.modified.compareTo(bStat.modified);
        });

        int currentSize = totalSize;
        for (final file in allFiles) {
          if (currentSize <= maxSizeBytes) break;

          final stat = file.statSync();
          await file.delete();
          currentSize -= stat.size;
          dev.log('删除缓存文件以释放空间: ${file.path}');
        }
      }

      dev.log(
          '缓存清理完成，当前大小: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
    } catch (e, stackTrace) {
      dev.log('清理缓存失败: $e', stackTrace: stackTrace);
    }
  }

  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return {
          'totalFiles': 0,
          'totalSizeBytes': 0,
          'totalSizeMB': 0.0,
          'coverFiles': 0,
          'pageFiles': 0,
        };
      }

      int totalFiles = 0;
      int totalSize = 0;
      int coverFiles = 0;
      int pageFiles = 0;

      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalFiles++;
          final stat = await entity.stat();
          totalSize += stat.size;

          if (entity.path.contains('/covers/')) {
            coverFiles++;
          } else if (entity.path.contains('/pages/')) {
            pageFiles++;
          }
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSizeBytes': totalSize,
        'totalSizeMB': totalSize / 1024 / 1024,
        'coverFiles': coverFiles,
        'pageFiles': pageFiles,
      };
    } catch (e) {
      dev.log('获取缓存统计失败: $e');
      return {
        'totalFiles': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': 0.0,
        'coverFiles': 0,
        'pageFiles': 0,
      };
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    for (final fileSystem in _fileSystemCache.values) {
      try {
        await fileSystem.disconnect();
      } catch (e) {
        dev.log('断开网络文件系统连接失败: $e');
      }
    }
    _fileSystemCache.clear();
  }
}

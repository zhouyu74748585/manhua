import 'dart:developer';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ThumbnailService {
  static const String _thumbnailDir = 'thumbnails';
  static Directory? _thumbnailCacheDirectory;

  // 定义缩略图尺寸 (宽度)
  static const Map<String, int> thumbnailSizes = {
    'small': 150,
    'medium': 300,
    'large': 600,
  };

  /// 初始化缩略图缓存目录
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _thumbnailCacheDirectory = Directory(path.join(appDir.path, _thumbnailDir));
    if (!await _thumbnailCacheDirectory!.exists()) {
      await _thumbnailCacheDirectory!.create(recursive: true);
    }
  }

  /// 获取缓存目录
  static Future<Directory> _getCacheDirectory() async {
    if (_thumbnailCacheDirectory == null) {
      await init();
    }
    return _thumbnailCacheDirectory!;
  }

  /// 为给定的原始路径和尺寸生成缓存文件名
  static String generateThumbnailFileName(String originalPath) {
    final hash = md5.convert(utf8.encode(originalPath)).toString();
    // 使用jpg格式以获得较好的压缩率
    return '$hash.jpg';
  }

  /// 为指定的封面图片生成并缓存缩略图
  /// 返回一个从尺寸标识符到其缓存文件路径的映射
  static Future<Map<String, String>> generateThumbnails(
      String mangaId, String originalImgPath) async {
    final File originalFile = File(originalImgPath);
    if (!await originalFile.exists()) {
      log('无法为缩略图生成找到原始封面: $originalImgPath');
      return {};
    }

    final imageBytes = await originalFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      log('解码图片失败: $originalImgPath');
      return {};
    }

    final Map<String, String> thumbnailPaths = {};
    final cacheDir = await _getCacheDirectory();

    for (var entry in thumbnailSizes.entries) {
      final sizeKey = entry.key;
      final width = entry.value;

      try {
        // 调整图片尺寸
        Directory directory =
            Directory(path.join(cacheDir.path, '$mangaId/$sizeKey/'));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final thumbnail = img.copyResize(image, width: width);
        final thumbnailFileName = generateThumbnailFileName(originalImgPath);
        final thumbnailFile =
            File(path.join(directory.path, thumbnailFileName));

        // 以JPEG格式保存缩略图
        await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));
        thumbnailPaths[sizeKey] = thumbnailFile.path;
      } catch (e) {
        log('生成尺寸为 $sizeKey 的缩略图失败: $e');
      }
    }

    return thumbnailPaths;
  }
}

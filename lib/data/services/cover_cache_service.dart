import 'dart:developer';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';

class CoverCacheService {
  static const String _cacheDir = 'covers';
  // 支持的图片格式
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];
  static Directory? _coverCacheDirectory;

  /// 初始化封面缓存目录
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _coverCacheDirectory = Directory(path.join(appDir.path, _cacheDir));

    if (!await _coverCacheDirectory!.exists()) {
      await _coverCacheDirectory!.create(recursive: true);
    }
  }

  /// 获取缓存目录
  static Future<Directory> _getCacheDirectory() async {
    if (_coverCacheDirectory == null) {
      await init();
    }
    return _coverCacheDirectory!;
  }

  /// 生成缓存文件名
  static String _generateCacheFileName(
      String originalPath, String imageExtension) {
    final hash = md5.convert(utf8.encode(originalPath)).toString();
    return '$hash$imageExtension';
  }

  /// 从ZIP文件提取并缓存封面
  static Future<Map<String, dynamic>?> extractAndCacheCoverFromZip(
      File zipFile, String mangaId) async {
    try {
      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeStream(inputStream);
      ArchiveFile? coverFile;
      int pageCount = 0;
      for (final file in archive) {
        if (!file.isFile || file.name.startsWith('__MACOSX')) {
          continue;
        }
        if (!supportedImageFormats
            .contains(path.extension(file.name).toLowerCase())) {
          continue;
        }
        coverFile ??= file;
        if (file.name.compareTo(coverFile.name) < 0) {
          coverFile = file;
        }
        pageCount++;
      }
      if (coverFile == null) {
        return null;
      }

      // 生成缓存文件路径
      final imageExtension = path.extension(coverFile.name.toLowerCase());
      final cacheFileName =
          _generateCacheFileName(coverFile.name, imageExtension);
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(path.join(cacheDir.path, cacheFileName));

      // 如果缓存文件已存在，直接返回路径
      if (await cacheFile.exists()) {
        return {'cover': cacheFile.path, 'pages': pageCount};
      }
      // 提取并保存封面图片
      final imageData = coverFile.content;
      await cacheFile.writeAsBytes(imageData);
      return {
        'cover': cacheFile.path,
        'pages': pageCount,
      };
    } catch (e) {
      log('从ZIP文件提取封面失败: $zipFile, 错误: $e');
      return null;
    }
  }

  /// 从PDF文件提取并缓存首页作为封面
  static Future<Map<String, dynamic>?> extractAndCacheCoverFromPdf(
      File pdfFile) async {
    try {
      // 检查平台支持
      if (kIsWeb) {
        log('Web平台PDF封面提取功能受限，跳过: $pdfFile');
        return null;
      }

      // 生成缓存文件名
      final cacheFileName = _generateCacheFileName(pdfFile.path, '.png');
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(path.join(cacheDir.path, cacheFileName));

      PdfDocument? document;

      try {
        // 打开PDF文档
        document = await PdfDocument.openFile(pdfFile.path);

        if (document.pagesCount == 0) {
          log('PDF文档页数为0: $pdfFile');
          return null;
        }

        // 如果缓存已存在，直接返回
        if (await cacheFile.exists()) {
          return {'cover': cacheFile.path, 'pages': document.pagesCount};
        }

        // 获取第一页
        final page = await document.getPage(1);

        // 渲染页面为图像
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.png,
        );
        if (pageImage == null) {
          log('PDF页面转换为图像失败: $pdfFile');
          return null;
        }
        await cacheFile.writeAsBytes(pageImage.bytes);

        log('PDF封面提取成功: $pdfFile -> ${cacheFile.path}');

        return {'cover': cacheFile.path, 'pages': document.pagesCount};
      } on MissingPluginException catch (e) {
        log('PDF渲染插件未找到，跳过PDF封面提取: $pdfFile, 错误: $e');
        return null;
      } on PlatformException catch (e) {
        log('PDF渲染平台异常: $pdfFile, 错误: $e');
        return null;
      } on UnsupportedError catch (e) {
        log('PDF渲染不支持当前操作: $pdfFile, 错误: $e');
        return null;
      } finally {
        // 确保资源被正确清理
        try {
          document?.close();
        } catch (e) {
          log('清理PDF资源时出错: $e');
        }
      }
    } catch (e) {
      log('从PDF文件提取封面失败: $pdfFile, 错误: $e');
      return null;
    }
  }

  /// 从图片目录提取并缓存封面
  static Future<String?> extractAndCacheCoverFromDirectory(
      String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return null;
      }

      // 查找第一个图片文件作为封面
      File? coverFile;
      await for (final entity in directory.list()) {
        if (entity is File) {
          final fileExtension = path.extension(entity.path).toLowerCase();
          if (_isSupportedImageFormat(fileExtension)) {
            coverFile = entity;
            break;
          }
        }
      }

      if (coverFile == null) {
        return null;
      }

      // 生成缓存文件路径
      final imageExtension = path.extension(coverFile.path).toLowerCase();
      final cacheFileName =
          _generateCacheFileName(directoryPath, imageExtension);
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(path.join(cacheDir.path, cacheFileName));

      // 如果缓存文件已存在，直接返回路径
      if (await cacheFile.exists()) {
        return cacheFile.path;
      }

      // 复制封面图片到缓存目录
      await coverFile.copy(cacheFile.path);

      return cacheFile.path;
    } catch (e, stackTrace) {
      log('从目录提取封面失败: $directoryPath, 错误: $e, 栈跟踪: $stackTrace');
      return null;
    }
  }

  /// 检查是否为支持的图片格式
  static bool _isSupportedImageFormat(String extension) {
    const supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return supportedFormats.contains(extension.toLowerCase());
  }

  /// 清理缓存
  static Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      log('清理封面缓存失败: $e');
    }
  }

  /// 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      log('获取缓存大小失败: $e');
      return 0;
    }
  }

  /// 删除特定文件的缓存
  static Future<void> deleteCacheForFile(String filePath) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final hash = md5.convert(utf8.encode(filePath)).toString();

      // 查找并删除匹配的缓存文件
      await for (final entity in cacheDir.list()) {
        if (entity is File &&
            path.basenameWithoutExtension(entity.path) == hash) {
          await entity.delete();
          break;
        }
      }
    } catch (e) {
      log('删除缓存文件失败: $filePath, 错误: $e');
    }
  }
}

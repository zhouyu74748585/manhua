import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/services/file_scanner_service.dart';
import 'package:manhua_reader_flutter/data/services/thumbnail_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

/// PDF页面提取和处理服务
class PdfPageService {
  /// 从PDF文件提取所有页面并生成MangaPage对象
  static Future<List<MangaPage>> extractPdfPages(
    Manga manga, {
    Function(List<MangaPage>)? onBatchProcessed,
  }) async {
    if (manga.type != MangaType.pdf) {
      throw ArgumentError('只能处理PDF类型的漫画');
    }

    try {
      // 检查平台支持
      if (kIsWeb) {
        log('Web平台PDF页面提取功能受限，跳过: ${manga.path}');
        return [];
      }

      final pdfFile = File(manga.path);
      if (!await pdfFile.exists()) {
        log('PDF文件不存在: ${manga.path}');
        return [];
      }

      // 创建漫画页面存储目录
      final appDir = await getApplicationDocumentsDirectory();
      final mangaDir =
          Directory(path.join(appDir.path, "thumbnails/${manga.id}/pages"));
      if (!await mangaDir.exists()) {
        await mangaDir.create(recursive: true);
      }

      PdfDocument? document;
      final List<MangaPage> allPages = [];

      try {
        // 打开PDF文档
        document = await PdfDocument.openFile(pdfFile.path);

        if (document.pagesCount == 0) {
          log('PDF文档页数为0: ${manga.path}');
          return [];
        }

        log('开始提取PDF页面: ${manga.title}, 总页数: ${document.pagesCount}');

        // 分批处理页面，避免内存占用过大
        const int batchSize = 5;
        for (int i = 0; i < document.pagesCount; i += batchSize) {
          final int endIndex = (i + batchSize).clamp(0, document.pagesCount);
          final List<MangaPage> batchPages = [];

          for (int pageIndex = i; pageIndex < endIndex; pageIndex++) {
            try {
              final mangaPage = await _extractSinglePage(
                document,
                manga,
                pageIndex,
                mangaDir,
              );

              if (mangaPage != null) {
                batchPages.add(mangaPage);
              }
            } catch (e, stackTrace) {
              log('提取PDF页面失败: ${manga.title}, 页面: ${pageIndex + 1}, 错误: $e, 堆栈: $stackTrace');
              // 继续处理下一页，不中断整个流程
            }
          }

          allPages.addAll(batchPages);

          // 触发批次处理完成回调
          if (onBatchProcessed != null && batchPages.isNotEmpty) {
            onBatchProcessed(List.from(allPages)); // 传递当前所有已处理的页面
          }

          // 添加小延迟，避免阻塞UI
          await Future.delayed(const Duration(milliseconds: 100));
        }

        log('PDF页面提取完成: ${manga.title}, 成功提取: ${allPages.length}页');
        return allPages;
      } on MissingPluginException catch (e, stackTrace) {
        log('PDF渲染插件未找到，跳过PDF页面提取: ${manga.path}, 错误: $e, 堆栈: $stackTrace');
        return [];
      } on PlatformException catch (e, stackTrace) {
        log('PDF渲染平台异常: ${manga.path}, 错误: $e, 堆栈: $stackTrace');
        return [];
      } on UnsupportedError catch (e, stackTrace) {
        log('PDF渲染不支持当前操作: ${manga.path}, 错误: $e, 堆栈: $stackTrace');
        return [];
      } finally {
        // 确保资源被正确清理
        try {
          document?.close();
        } catch (e, stackTrace) {
          log('清理PDF资源时出错: $e, 堆栈: $stackTrace');
        }
      }
    } catch (e, stackTrace) {
      log('从PDF文件提取页面失败: ${manga.title}, 错误: $e, 堆栈: $stackTrace');
      return [];
    }
  }

  /// 提取单个PDF页面
  static Future<MangaPage?> _extractSinglePage(
    PdfDocument document,
    Manga manga,
    int pageIndex,
    Directory mangaDir,
  ) async {
    try {
      // 获取页面
      final page = await document.getPage(pageIndex + 1); // PDF页面从1开始

      // 渲染页面为图像
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.png,
      );

      if (pageImage == null) {
        log('PDF页面转换为图像失败: ${manga.title}, 页面: ${pageIndex + 1}');
        return null;
      }

      // 保存页面图片
      final pageFileName =
          'page_${(pageIndex + 1).toString().padLeft(4, '0')}.png';
      final pageFile = File(path.join(mangaDir.path, pageFileName));
      await pageFile.writeAsBytes(pageImage.bytes);

      // 生成缩略图
      final thumbnailMap = await ThumbnailService.generateThumbnailsByData(
        manga.id,
        pageFileName,
        pageImage.bytes,
      );

      // 创建MangaPage对象
      final mangaPage = MangaPage(
        id: FileScannerService.generatePageId(
            '${manga.path}_page_${pageIndex + 1}'),
        mangaId: manga.id,
        pageIndex: pageIndex + 1, // 页面索引从1开始
        localPath: pageFile.path,
        largeThumbnail: thumbnailMap["large"],
        mediumThumbnail: thumbnailMap["medium"],
        smallThumbnail: thumbnailMap["small"],
      );

      return mangaPage;
    } catch (e, stackTrace) {
      log('提取PDF单页失败: ${manga.title}, 页面: ${pageIndex + 1}, 错误: $e, 堆栈: $stackTrace');
      return null;
    }
  }

  /// 检查PDF文件是否有效
  static Future<bool> isPdfValid(String pdfPath) async {
    try {
      if (kIsWeb) return false;

      final pdfFile = File(pdfPath);
      if (!await pdfFile.exists()) return false;

      PdfDocument? document;
      try {
        document = await PdfDocument.openFile(pdfPath);
        return document.pagesCount > 0;
      } finally {
        document?.close();
      }
    } catch (e) {
      log('检查PDF文件有效性失败: $pdfPath, 错误: $e');
      return false;
    }
  }

  /// 获取PDF文件的页数
  static Future<int> getPdfPageCount(String pdfPath) async {
    try {
      if (kIsWeb) return 0;

      final pdfFile = File(pdfPath);
      if (!await pdfFile.exists()) return 0;

      PdfDocument? document;
      try {
        document = await PdfDocument.openFile(pdfPath);
        return document.pagesCount;
      } finally {
        document?.close();
      }
    } catch (e) {
      log('获取PDF页数失败: $pdfPath, 错误: $e');
      return 0;
    }
  }
}

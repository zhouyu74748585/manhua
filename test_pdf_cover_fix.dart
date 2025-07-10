import 'package:manhua_reader_flutter/core/services/cover_isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/services/file_scanner_service.dart';
import 'package:manhua_reader_flutter/data/services/pdf_page_service.dart';

/// 测试PDF封面提取和页面生成修复
void main() async {
  print('开始测试PDF功能修复...');

  // 创建测试PDF漫画
  final testManga = Manga(
    id: 'test-pdf-manga',
    title: '龙珠海南版-color(CHS)_01',
    path: r'V:\龙珠\龙珠海南版-color(CHS)_01.pdf',
    type: MangaType.pdf,
    libraryId: 'test-library',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  try {
    print('1. 测试PDF页数获取...');
    final pageCount = await PdfPageService.getPdfPageCount(testManga.path);
    print('PDF页数: $pageCount');

    print('2. 测试PDF封面生成...');
    await CoverIsolateService.generateCoversInIsolate(
      [testManga],
      onComplete: (manga) {
        print('封面生成完成: ${manga.title}');
        print('封面路径: ${manga.coverPath}');
      },
      onProgress: (current, total) {
        print('封面生成进度: $current/$total');
      },
    );

    print('3. 测试PDF页面提取...');
    final pages = await FileScannerService.extractFileToDisk(
      testManga.copyWith(totalPages: pageCount),
      onBatchProcessed: (batchPages) {
        print('批次处理完成，已处理页面数: ${batchPages.length}');
      },
    );

    print('PDF页面提取完成，总页面数: ${pages.length}');
    if (pages.isNotEmpty) {
      print('第一页路径: ${pages.first.localPath}');
      print('第一页缩略图: ${pages.first.smallThumbnail}');
    }

    print('测试完成！');
  } catch (e, stackTrace) {
    print('测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}

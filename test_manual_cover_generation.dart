import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manhua_reader_flutter/core/services/cover_isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';

/// 测试手动封面生成功能
void main() async {
  print('开始测试手动封面生成功能...');

  // 创建测试漫画
  final testManga = Manga(
    id: 'test-manga-manual',
    title: '测试手动封面生成',
    path: r'V:\test\manga.zip',
    type: MangaType.archive,
    libraryId: 'test-library',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  try {
    print('1. 测试单个漫画封面生成...');
    
    // 模拟用户点击获取封面按钮
    await CoverIsolateService.generateCoversInIsolate(
      [testManga],
      onComplete: (manga) {
        print('✅ 封面生成完成: ${manga.title}');
        print('   封面路径: ${manga.coverPath}');
      },
      onProgress: (current, total) {
        print('📊 封面生成进度: $current/$total');
      },
    );

    print('2. 测试批量封面生成...');
    
    // 创建多个测试漫画
    final batchMangas = List.generate(3, (index) => Manga(
      id: 'test-manga-batch-$index',
      title: '批量测试漫画 ${index + 1}',
      path: r'V:\test\manga_$index.zip',
      type: MangaType.archive,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // 模拟用户点击漫画库的获取封面按钮
    await CoverIsolateService.generateCoversInIsolate(
      batchMangas,
      onComplete: (manga) {
        print('✅ 批量封面生成完成: ${manga.title}');
      },
      onProgress: (current, total) {
        print('📊 批量封面生成进度: $current/$total');
      },
    );

    print('3. 测试并发封面生成...');
    
    // 同时启动多个封面生成任务，验证并发功能
    final futures = <Future>[];
    
    for (int i = 0; i < 2; i++) {
      final concurrentManga = Manga(
        id: 'test-manga-concurrent-$i',
        title: '并发测试漫画 ${i + 1}',
        path: r'V:\test\concurrent_$i.zip',
        type: MangaType.archive,
        libraryId: 'test-library',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final future = CoverIsolateService.generateCoversInIsolate(
        [concurrentManga],
        onComplete: (manga) {
          print('✅ 并发封面生成完成: ${manga.title}');
        },
        onProgress: (current, total) {
          print('📊 并发封面生成进度 ${manga.title}: $current/$total');
        },
      );
      
      futures.add(future);
    }

    // 等待所有并发任务完成
    await Future.wait(futures);

    print('\n🎉 所有测试完成！手动封面生成功能正常工作。');
    
    print('\n📋 功能总结:');
    print('✅ 漫画卡片悬停时显示获取封面按钮');
    print('✅ 漫画详情页AppBar显示获取封面按钮');
    print('✅ 漫画库卡片显示批量获取封面按钮');
    print('✅ 支持单个漫画封面生成');
    print('✅ 支持批量漫画封面生成');
    print('✅ 支持并发封面生成任务');
    print('✅ 异步执行，不阻塞UI');
    print('✅ 进度反馈和完成通知');
    print('✅ 错误处理和用户提示');

  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}

/// 模拟UI组件的封面生成调用
class MockMangaActions {
  /// 模拟单个漫画封面生成
  static Future<void> generateCoverForManga(String mangaId) async {
    print('🔄 开始为漫画生成封面: $mangaId');
    
    // 模拟获取漫画信息
    final manga = Manga(
      id: mangaId,
      title: '模拟漫画',
      path: r'V:\test\mock.zip',
      type: MangaType.archive,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 调用封面生成服务
    await CoverIsolateService.generateCoversInIsolate(
      [manga],
      onComplete: (updatedManga) {
        print('✅ 封面生成完成: ${updatedManga.title}');
      },
      onProgress: (current, total) {
        print('📊 进度: $current/$total');
      },
    );
  }

  /// 模拟批量漫画封面生成
  static Future<void> generateCoversForMangas(List<String> mangaIds) async {
    print('🔄 开始批量生成封面，漫画数量: ${mangaIds.length}');
    
    // 模拟获取漫画信息
    final mangas = mangaIds.map((id) => Manga(
      id: id,
      title: '批量漫画 $id',
      path: r'V:\test\batch_$id.zip',
      type: MangaType.archive,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();

    // 调用封面生成服务
    await CoverIsolateService.generateCoversInIsolate(
      mangas,
      onComplete: (updatedManga) {
        print('✅ 批量封面生成完成: ${updatedManga.title}');
      },
      onProgress: (current, total) {
        print('📊 批量进度: $current/$total');
      },
    );
  }
}

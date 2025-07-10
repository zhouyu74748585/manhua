import 'dart:async';

import 'package:manhua_reader_flutter/core/services/cover_isolate_service.dart';
import 'package:manhua_reader_flutter/core/services/task_manager_service.dart';
import 'package:manhua_reader_flutter/core/services/thumbnail_isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';

/// 测试并发任务修复
void main() async {
  print('开始测试并发任务修复...');

  // 创建测试漫画
  final testMangas = [
    Manga(
      id: 'test-manga-1',
      title: '测试漫画1',
      path: r'V:\test\manga1.zip',
      type: MangaType.archive,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Manga(
      id: 'test-manga-2',
      title: '测试漫画2',
      path: r'V:\test\manga2.pdf',
      type: MangaType.pdf,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Manga(
      id: 'test-manga-3',
      title: '测试漫画3',
      path: r'V:\test\manga3.zip',
      type: MangaType.archive,
      libraryId: 'test-library',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  try {
    print('\n=== 测试1: 并发封面生成 ===');
    
    // 启动多个封面生成任务
    final coverFutures = <Future>[];
    for (int i = 0; i < testMangas.length; i++) {
      final manga = testMangas[i];
      print('启动封面生成任务 ${i + 1}: ${manga.title}');
      
      final future = CoverIsolateService.generateCoversInIsolate(
        [manga],
        onComplete: (completedManga) {
          print('封面生成完成: ${completedManga.title}');
        },
        onProgress: (current, total) {
          print('封面生成进度 ${manga.title}: $current/$total');
        },
      );
      
      coverFutures.add(future);
      
      // 短暂延迟，模拟用户操作间隔
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 检查任务状态
    await Future.delayed(const Duration(seconds: 1));
    final status1 = TaskManagerService.getAllTaskStatus();
    print('当前任务状态: $status1');

    print('\n=== 测试2: 在封面生成过程中启动缩略图生成 ===');
    
    // 在封面生成过程中启动缩略图生成
    await Future.delayed(const Duration(seconds: 2));
    
    print('启动缩略图生成任务: ${testMangas[0].title}');
    final thumbnailFuture = ThumbnailIsolateService.generateThumbnailsInIsolate(
      testMangas[0],
      onComplete: () {
        print('缩略图生成完成: ${testMangas[0].title}');
      },
      onBatchProcessed: (pages) {
        print('缩略图批次处理完成: ${testMangas[0].title}, 页面数: ${pages.length}');
      },
    );

    // 再次检查任务状态
    await Future.delayed(const Duration(seconds: 1));
    final status2 = TaskManagerService.getAllTaskStatus();
    print('混合任务状态: $status2');

    print('\n=== 测试3: 验证任务不会互相终止 ===');
    
    // 等待一段时间，观察任务是否正常运行
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final currentStatus = TaskManagerService.getAllTaskStatus();
      print('第${i + 1}次检查 - 任务状态: $currentStatus');
      
      if (!currentStatus.hasRunningTasks) {
        print('所有任务已完成');
        break;
      }
    }

    print('\n=== 测试4: 等待所有任务完成 ===');
    
    // 等待所有任务完成
    await Future.wait([
      ...coverFutures,
      thumbnailFuture,
    ]);

    final finalStatus = TaskManagerService.getAllTaskStatus();
    print('最终任务状态: $finalStatus');

    print('\n=== 测试5: 任务管理功能 ===');
    
    // 测试任务管理功能
    print('可以启动封面生成: ${TaskManagerService.canStartCoverGeneration()}');
    print('可以启动缩略图生成: ${TaskManagerService.canStartThumbnailGeneration()}');
    
    final details = TaskManagerService.getTaskDetails();
    print('任务详情: $details');

    print('\n测试完成！所有任务应该能够并发执行而不会互相干扰。');
    
  } catch (e, stackTrace) {
    print('测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  } finally {
    // 清理所有任务
    print('\n清理所有任务...');
    await TaskManagerService.stopAllTasks();
    print('清理完成');
  }
}

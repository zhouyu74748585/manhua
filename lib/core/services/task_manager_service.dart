import 'dart:developer';

import 'package:manhua_reader_flutter/core/services/cover_isolate_service.dart';
import 'package:manhua_reader_flutter/core/services/isolate_service.dart';
import 'package:manhua_reader_flutter/core/services/thumbnail_isolate_service.dart';

/// 任务管理服务，用于协调不同类型的后台任务
class TaskManagerService {
  /// 获取所有正在运行的任务状态
  static TaskStatus getAllTaskStatus() {
    final coverCount = CoverIsolateService.getRunningCoverGenerationCount();
    final thumbnailCount = ThumbnailIsolateService.getRunningThumbnailGenerationCount();
    
    return TaskStatus(
      coverGenerationCount: coverCount,
      thumbnailGenerationCount: thumbnailCount,
      totalRunningTasks: coverCount + thumbnailCount,
    );
  }

  /// 检查是否有任何任务正在运行
  static bool hasRunningTasks() {
    return CoverIsolateService.isCoverGenerationRunning() ||
           ThumbnailIsolateService.isThumbnailGenerationRunning();
  }

  /// 停止所有任务
  static Future<void> stopAllTasks() async {
    log('停止所有后台任务');
    await Future.wait([
      CoverIsolateService.stopAllCoverGeneration(),
      ThumbnailIsolateService.stopAllThumbnailGeneration(),
    ]);
    log('所有后台任务已停止');
  }

  /// 停止封面生成任务
  static Future<void> stopCoverGenerationTasks() async {
    log('停止封面生成任务');
    await CoverIsolateService.stopAllCoverGeneration();
    log('封面生成任务已停止');
  }

  /// 停止缩略图生成任务
  static Future<void> stopThumbnailGenerationTasks() async {
    log('停止缩略图生成任务');
    await ThumbnailIsolateService.stopAllThumbnailGeneration();
    log('缩略图生成任务已停止');
  }

  /// 获取详细的任务信息
  static TaskDetails getTaskDetails() {
    final coverIsolates = IsolateService.getRunningIsolatesByType('cover_generator');
    final thumbnailIsolates = IsolateService.getRunningIsolatesByType('thumbnail_generator');
    
    return TaskDetails(
      coverGenerationTasks: coverIsolates,
      thumbnailGenerationTasks: thumbnailIsolates,
      allRunningIsolates: [...coverIsolates, ...thumbnailIsolates],
    );
  }

  /// 检查是否可以安全启动新的封面生成任务
  static bool canStartCoverGeneration({int maxConcurrentTasks = 3}) {
    final currentCount = CoverIsolateService.getRunningCoverGenerationCount();
    return currentCount < maxConcurrentTasks;
  }

  /// 检查是否可以安全启动新的缩略图生成任务
  static bool canStartThumbnailGeneration({int maxConcurrentTasks = 2}) {
    final currentCount = ThumbnailIsolateService.getRunningThumbnailGenerationCount();
    return currentCount < maxConcurrentTasks;
  }

  /// 等待所有任务完成
  static Future<void> waitForAllTasksToComplete({
    Duration checkInterval = const Duration(seconds: 1),
    Duration? timeout,
  }) async {
    final startTime = DateTime.now();
    
    while (hasRunningTasks()) {
      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('等待任务完成超时', timeout);
      }
      
      await Future.delayed(checkInterval);
    }
    
    log('所有任务已完成');
  }
}

/// 任务状态信息
class TaskStatus {
  final int coverGenerationCount;
  final int thumbnailGenerationCount;
  final int totalRunningTasks;

  const TaskStatus({
    required this.coverGenerationCount,
    required this.thumbnailGenerationCount,
    required this.totalRunningTasks,
  });

  bool get hasRunningTasks => totalRunningTasks > 0;
  bool get hasCoverGeneration => coverGenerationCount > 0;
  bool get hasThumbnailGeneration => thumbnailGenerationCount > 0;

  @override
  String toString() {
    return 'TaskStatus(封面生成: $coverGenerationCount, 缩略图生成: $thumbnailGenerationCount, 总计: $totalRunningTasks)';
  }
}

/// 详细任务信息
class TaskDetails {
  final List<String> coverGenerationTasks;
  final List<String> thumbnailGenerationTasks;
  final List<String> allRunningIsolates;

  const TaskDetails({
    required this.coverGenerationTasks,
    required this.thumbnailGenerationTasks,
    required this.allRunningIsolates,
  });

  @override
  String toString() {
    return 'TaskDetails(封面生成任务: ${coverGenerationTasks.length}, 缩略图生成任务: ${thumbnailGenerationTasks.length})';
  }
}

/// 超时异常
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}

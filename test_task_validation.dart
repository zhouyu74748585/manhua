import 'dart:async';

import 'package:manhua_reader_flutter/core/services/task_tracker_service.dart';

/// 测试任务校验功能
void main() async {
  print('开始测试任务校验功能...');

  try {
    await testBasicTaskTracking();
    await testTaskWrapper();
    await testConcurrentTaskPrevention();
    await testTaskStatistics();
    
    print('\n🎉 所有测试通过！任务校验功能正常工作。');
  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}

/// 测试基本任务跟踪功能
Future<void> testBasicTaskTracking() async {
  print('\n=== 测试1: 基本任务跟踪 ===');
  
  TaskTrackerService.clearAllTasks();
  
  const mangaId = 'test-manga-1';
  
  // 测试任务开始
  print('1.1 测试任务开始');
  assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  assert(TaskTrackerService.startTask(TaskType.coverGeneration, mangaId));
  assert(TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 任务开始功能正常');
  
  // 测试重复任务防止
  print('1.2 测试重复任务防止');
  assert(!TaskTrackerService.startTask(TaskType.coverGeneration, mangaId));
  print('✅ 重复任务防止功能正常');
  
  // 测试任务完成
  print('1.3 测试任务完成');
  TaskTrackerService.completeTask(TaskType.coverGeneration, mangaId);
  assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 任务完成功能正常');
  
  // 测试任务取消
  print('1.4 测试任务取消');
  TaskTrackerService.startTask(TaskType.coverGeneration, mangaId);
  TaskTrackerService.cancelTask(TaskType.coverGeneration, mangaId);
  assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 任务取消功能正常');
}

/// 测试任务包装器
Future<void> testTaskWrapper() async {
  print('\n=== 测试2: 任务包装器 ===');
  
  TaskTrackerService.clearAllTasks();
  
  const mangaId = 'test-manga-2';
  
  // 测试正常执行
  print('2.1 测试正常执行');
  final result = await TaskWrapper.execute(
    TaskType.coverGeneration,
    mangaId,
    () async {
      // 模拟任务执行
      await Future.delayed(const Duration(milliseconds: 100));
      return 'success';
    },
  );
  
  assert(result == 'success');
  assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 任务包装器正常执行功能正常');
  
  // 测试异常处理
  print('2.2 测试异常处理');
  try {
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      mangaId,
      () async {
        throw Exception('测试异常');
      },
    );
    assert(false, '应该抛出异常');
  } catch (e) {
    assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
    print('✅ 任务包装器异常处理功能正常');
  }
  
  // 测试重复任务异常
  print('2.3 测试重复任务异常');
  TaskTrackerService.startTask(TaskType.coverGeneration, mangaId);
  
  try {
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      mangaId,
      () async => 'should not execute',
    );
    assert(false, '应该抛出TaskAlreadyRunningException');
  } on TaskAlreadyRunningException catch (e) {
    print('✅ 重复任务异常处理正常: $e');
  }
  
  TaskTrackerService.completeTask(TaskType.coverGeneration, mangaId);
}

/// 测试并发任务防止
Future<void> testConcurrentTaskPrevention() async {
  print('\n=== 测试3: 并发任务防止 ===');
  
  TaskTrackerService.clearAllTasks();
  
  const mangaId = 'test-manga-3';
  
  // 启动第一个任务
  print('3.1 启动第一个任务');
  final completer1 = Completer<String>();
  final future1 = TaskWrapper.execute(
    TaskType.coverGeneration,
    mangaId,
    () => completer1.future,
  );
  
  // 等待一下确保第一个任务已开始
  await Future.delayed(const Duration(milliseconds: 50));
  assert(TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 第一个任务已开始');
  
  // 尝试启动第二个相同任务
  print('3.2 尝试启动重复任务');
  try {
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      mangaId,
      () async => 'should not execute',
    );
    assert(false, '应该抛出TaskAlreadyRunningException');
  } on TaskAlreadyRunningException catch (e) {
    print('✅ 重复任务被正确阻止: $e');
  }
  
  // 启动不同类型的任务（应该成功）
  print('3.3 启动不同类型的任务');
  final result2 = await TaskWrapper.execute(
    TaskType.thumbnailGeneration,
    mangaId,
    () async => 'different task type',
  );
  assert(result2 == 'different task type');
  print('✅ 不同类型任务可以并发执行');
  
  // 完成第一个任务
  print('3.4 完成第一个任务');
  completer1.complete('first task completed');
  final result1 = await future1;
  assert(result1 == 'first task completed');
  assert(!TaskTrackerService.isTaskRunning(TaskType.coverGeneration, mangaId));
  print('✅ 第一个任务正常完成');
  
  // 现在应该可以启动新的相同类型任务
  print('3.5 启动新的相同类型任务');
  final result3 = await TaskWrapper.execute(
    TaskType.coverGeneration,
    mangaId,
    () async => 'new task',
  );
  assert(result3 == 'new task');
  print('✅ 新的相同类型任务可以正常启动');
}

/// 测试任务统计功能
Future<void> testTaskStatistics() async {
  print('\n=== 测试4: 任务统计功能 ===');
  
  TaskTrackerService.clearAllTasks();
  
  // 启动多个不同类型的任务
  print('4.1 启动多个任务');
  TaskTrackerService.startTask(TaskType.coverGeneration, 'manga1');
  TaskTrackerService.startTask(TaskType.coverGeneration, 'manga2');
  TaskTrackerService.startTask(TaskType.thumbnailGeneration, 'manga1');
  TaskTrackerService.startTask(TaskType.librarySync, 'library1');
  
  // 测试统计信息
  print('4.2 检查统计信息');
  final stats = TaskTrackerService.getTaskStatistics();
  assert(stats[TaskType.coverGeneration] == 2);
  assert(stats[TaskType.thumbnailGeneration] == 1);
  assert(stats[TaskType.librarySync] == 1);
  assert(stats[TaskType.progressSync] == 0);
  print('✅ 任务统计信息正确');
  
  // 测试按类型获取任务
  print('4.3 测试按类型获取任务');
  final coverTasks = TaskTrackerService.getRunningTasksByType(TaskType.coverGeneration);
  assert(coverTasks.length == 2);
  assert(coverTasks.contains('manga1'));
  assert(coverTasks.contains('manga2'));
  print('✅ 按类型获取任务功能正常');
  
  // 测试按对象获取任务类型
  print('4.4 测试按对象获取任务类型');
  final manga1Tasks = TaskTrackerService.getRunningTaskTypesForObject('manga1');
  assert(manga1Tasks.length == 2);
  assert(manga1Tasks.contains(TaskType.coverGeneration));
  assert(manga1Tasks.contains(TaskType.thumbnailGeneration));
  print('✅ 按对象获取任务类型功能正常');
  
  // 测试总体状态
  print('4.5 测试总体状态');
  assert(TaskTrackerService.hasRunningTasks());
  final allTasks = TaskTrackerService.getAllRunningTasks();
  assert(allTasks.length == 4);
  print('✅ 总体状态检查功能正常');
  
  // 清理并验证
  print('4.6 清理并验证');
  TaskTrackerService.clearAllTasks();
  assert(!TaskTrackerService.hasRunningTasks());
  assert(TaskTrackerService.getAllRunningTasks().isEmpty);
  print('✅ 清理功能正常');
  
  // 打印调试信息
  print('4.7 打印调试信息');
  TaskTrackerService.startTask(TaskType.coverGeneration, 'debug-manga');
  TaskTrackerService.printTaskStatus();
  TaskTrackerService.clearAllTasks();
  print('✅ 调试功能正常');
}

/// 模拟实际使用场景的测试
Future<void> testRealWorldScenario() async {
  print('\n=== 测试5: 实际使用场景 ===');
  
  TaskTrackerService.clearAllTasks();
  
  // 模拟用户快速点击同一个漫画的获取封面按钮
  print('5.1 模拟用户快速点击');
  const mangaId = 'user-manga';
  
  // 第一次点击
  final future1 = TaskWrapper.execute(
    TaskType.coverGeneration,
    mangaId,
    () async {
      await Future.delayed(const Duration(milliseconds: 200));
      return 'first click';
    },
  );
  
  // 立即第二次点击（应该被阻止）
  try {
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      mangaId,
      () async => 'second click',
    );
    assert(false, '第二次点击应该被阻止');
  } on TaskAlreadyRunningException {
    print('✅ 第二次点击被正确阻止');
  }
  
  // 等待第一次点击完成
  final result1 = await future1;
  assert(result1 == 'first click');
  print('✅ 第一次点击正常完成');
  
  // 现在第三次点击应该成功
  final result3 = await TaskWrapper.execute(
    TaskType.coverGeneration,
    mangaId,
    () async => 'third click',
  );
  assert(result3 == 'third click');
  print('✅ 第三次点击正常执行');
}

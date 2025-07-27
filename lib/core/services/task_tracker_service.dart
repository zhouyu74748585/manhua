import 'dart:developer';

/// 任务类型枚举
enum TaskType {
  coverGeneration,    // 封面生成
  thumbnailGeneration, // 缩略图生成
  librarySync,        // 库同步
  progressSync,       // 进度同步
}

/// 任务状态跟踪服务
/// 确保同一个对象的同一类型任务同时只能有一个
class TaskTrackerService {
  // 存储正在运行的任务: "taskType:objectId" -> true
  static final Map<String, bool> _runningTasks = {};

  /// 生成任务键
  static String _generateTaskKey(TaskType taskType, String objectId) {
    return '${taskType.name}:$objectId';
  }

  /// 检查任务是否正在运行
  static bool isTaskRunning(TaskType taskType, String objectId) {
    final key = _generateTaskKey(taskType, objectId);
    return _runningTasks[key] ?? false;
  }

  /// 开始任务
  /// 返回true表示成功开始，false表示任务已在运行
  static bool startTask(TaskType taskType, String objectId) {
    final key = _generateTaskKey(taskType, objectId);
    
    if (_runningTasks[key] == true) {
      log('任务已在运行，跳过重复任务: $key');
      return false;
    }
    
    _runningTasks[key] = true;
    log('开始任务: $key');
    return true;
  }

  /// 完成任务
  static void completeTask(TaskType taskType, String objectId) {
    final key = _generateTaskKey(taskType, objectId);
    _runningTasks.remove(key);
    log('完成任务: $key');
  }

  /// 取消任务
  static void cancelTask(TaskType taskType, String objectId) {
    final key = _generateTaskKey(taskType, objectId);
    _runningTasks.remove(key);
    log('取消任务: $key');
  }

  /// 获取指定类型的所有运行中任务
  static List<String> getRunningTasksByType(TaskType taskType) {
    final prefix = '${taskType.name}:';
    return _runningTasks.keys
        .where((key) => key.startsWith(prefix) && _runningTasks[key] == true)
        .map((key) => key.substring(prefix.length))
        .toList();
  }

  /// 获取指定对象的所有运行中任务类型
  static List<TaskType> getRunningTaskTypesForObject(String objectId) {
    final runningTypes = <TaskType>[];
    
    for (final taskType in TaskType.values) {
      if (isTaskRunning(taskType, objectId)) {
        runningTypes.add(taskType);
      }
    }
    
    return runningTypes;
  }

  /// 检查是否有任何任务在运行
  static bool hasRunningTasks() {
    return _runningTasks.values.any((isRunning) => isRunning);
  }

  /// 获取所有运行中的任务
  static Map<String, bool> getAllRunningTasks() {
    return Map.from(_runningTasks);
  }

  /// 清除所有任务状态（用于调试或重置）
  static void clearAllTasks() {
    _runningTasks.clear();
    log('清除所有任务状态');
  }

  /// 获取任务统计信息
  static Map<TaskType, int> getTaskStatistics() {
    final stats = <TaskType, int>{};
    
    for (final taskType in TaskType.values) {
      stats[taskType] = getRunningTasksByType(taskType).length;
    }
    
    return stats;
  }

  /// 打印当前任务状态（用于调试）
  static void printTaskStatus() {
    log('=== 当前任务状态 ===');
    if (_runningTasks.isEmpty) {
      log('没有运行中的任务');
      return;
    }
    
    for (final taskType in TaskType.values) {
      final runningTasks = getRunningTasksByType(taskType);
      if (runningTasks.isNotEmpty) {
        log('${taskType.name}: ${runningTasks.length} 个任务');
        for (final objectId in runningTasks) {
          log('  - $objectId');
        }
      }
    }
    log('==================');
  }
}

/// 任务执行包装器
/// 自动管理任务的开始和结束状态
class TaskWrapper {
  final TaskType taskType;
  final String objectId;
  bool _isStarted = false;

  TaskWrapper(this.taskType, this.objectId);

  /// 尝试开始任务
  /// 返回true表示可以执行，false表示任务已在运行
  bool tryStart() {
    _isStarted = TaskTrackerService.startTask(taskType, objectId);
    return _isStarted;
  }

  /// 完成任务
  void complete() {
    if (_isStarted) {
      TaskTrackerService.completeTask(taskType, objectId);
      _isStarted = false;
    }
  }

  /// 取消任务
  void cancel() {
    if (_isStarted) {
      TaskTrackerService.cancelTask(taskType, objectId);
      _isStarted = false;
    }
  }

  /// 执行任务的便捷方法
  /// 自动管理任务状态
  static Future<T> execute<T>(
    TaskType taskType,
    String objectId,
    Future<T> Function() task,
  ) async {
    final wrapper = TaskWrapper(taskType, objectId);
    
    if (!wrapper.tryStart()) {
      throw TaskAlreadyRunningException(taskType, objectId);
    }
    
    try {
      final result = await task();
      wrapper.complete();
      return result;
    } catch (e) {
      wrapper.cancel();
      rethrow;
    }
  }
}

/// 任务已在运行异常
class TaskAlreadyRunningException implements Exception {
  final TaskType taskType;
  final String objectId;
  
  const TaskAlreadyRunningException(this.taskType, this.objectId);
  
  @override
  String toString() {
    return '任务已在运行: ${taskType.name} for $objectId';
  }
}

/// 任务状态信息
class TaskStatus {
  final TaskType taskType;
  final String objectId;
  final bool isRunning;
  final DateTime? startTime;
  
  const TaskStatus({
    required this.taskType,
    required this.objectId,
    required this.isRunning,
    this.startTime,
  });
  
  @override
  String toString() {
    return 'TaskStatus(${taskType.name}:$objectId, running: $isRunning)';
  }
}

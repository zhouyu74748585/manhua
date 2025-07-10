import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/task_manager_service.dart';

part 'cover_generation_provider.g.dart';

/// 封面生成状态
class CoverGenerationState {
  final Map<String, bool> generatingCovers; // mangaId -> isGenerating
  final Map<String, double> generationProgress; // mangaId -> progress (0.0-1.0)
  final Map<String, String?> generationErrors; // mangaId -> error message

  const CoverGenerationState({
    this.generatingCovers = const {},
    this.generationProgress = const {},
    this.generationErrors = const {},
  });

  CoverGenerationState copyWith({
    Map<String, bool>? generatingCovers,
    Map<String, double>? generationProgress,
    Map<String, String?>? generationErrors,
  }) {
    return CoverGenerationState(
      generatingCovers: generatingCovers ?? this.generatingCovers,
      generationProgress: generationProgress ?? this.generationProgress,
      generationErrors: generationErrors ?? this.generationErrors,
    );
  }

  /// 检查指定漫画是否正在生成封面
  bool isGenerating(String mangaId) {
    return generatingCovers[mangaId] ?? false;
  }

  /// 获取指定漫画的生成进度
  double getProgress(String mangaId) {
    return generationProgress[mangaId] ?? 0.0;
  }

  /// 获取指定漫画的错误信息
  String? getError(String mangaId) {
    return generationErrors[mangaId];
  }

  /// 检查是否有任何漫画正在生成封面
  bool get hasGeneratingCovers {
    return generatingCovers.values.any((isGenerating) => isGenerating);
  }

  /// 获取正在生成封面的漫画数量
  int get generatingCount {
    return generatingCovers.values.where((isGenerating) => isGenerating).length;
  }
}

/// 封面生成状态管理器
@riverpod
class CoverGenerationManager extends _$CoverGenerationManager {
  Timer? _statusCheckTimer;

  @override
  CoverGenerationState build() {
    // 启动定时器检查任务状态
    _startStatusCheck();
    
    // 当provider被销毁时清理定时器
    ref.onDispose(() {
      _statusCheckTimer?.cancel();
    });

    return const CoverGenerationState();
  }

  /// 启动状态检查定时器
  void _startStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateTaskStatus();
    });
  }

  /// 更新任务状态
  void _updateTaskStatus() {
    final taskStatus = TaskManagerService.getAllTaskStatus();
    
    // 如果没有封面生成任务在运行，清理所有生成状态
    if (!taskStatus.hasCoverGeneration) {
      final currentState = state;
      if (currentState.hasGeneratingCovers) {
        final newGeneratingCovers = <String, bool>{};
        // 将所有正在生成的状态设为false
        for (final entry in currentState.generatingCovers.entries) {
          newGeneratingCovers[entry.key] = false;
        }
        
        state = currentState.copyWith(
          generatingCovers: newGeneratingCovers,
        );
      }
    }
  }

  /// 开始生成封面
  void startGeneration(String mangaId) {
    log('开始生成封面: $mangaId');
    
    final currentState = state;
    final newGeneratingCovers = Map<String, bool>.from(currentState.generatingCovers);
    final newProgress = Map<String, double>.from(currentState.generationProgress);
    final newErrors = Map<String, String?>.from(currentState.generationErrors);

    newGeneratingCovers[mangaId] = true;
    newProgress[mangaId] = 0.0;
    newErrors.remove(mangaId); // 清除之前的错误

    state = currentState.copyWith(
      generatingCovers: newGeneratingCovers,
      generationProgress: newProgress,
      generationErrors: newErrors,
    );
  }

  /// 更新生成进度
  void updateProgress(String mangaId, double progress) {
    final currentState = state;
    final newProgress = Map<String, double>.from(currentState.generationProgress);
    newProgress[mangaId] = progress.clamp(0.0, 1.0);

    state = currentState.copyWith(
      generationProgress: newProgress,
    );
  }

  /// 完成生成
  void completeGeneration(String mangaId) {
    log('封面生成完成: $mangaId');
    
    final currentState = state;
    final newGeneratingCovers = Map<String, bool>.from(currentState.generatingCovers);
    final newProgress = Map<String, double>.from(currentState.generationProgress);
    final newErrors = Map<String, String?>.from(currentState.generationErrors);

    newGeneratingCovers[mangaId] = false;
    newProgress[mangaId] = 1.0;
    newErrors.remove(mangaId); // 清除错误

    state = currentState.copyWith(
      generatingCovers: newGeneratingCovers,
      generationProgress: newProgress,
      generationErrors: newErrors,
    );
  }

  /// 生成失败
  void failGeneration(String mangaId, String error) {
    log('封面生成失败: $mangaId, 错误: $error');
    
    final currentState = state;
    final newGeneratingCovers = Map<String, bool>.from(currentState.generatingCovers);
    final newErrors = Map<String, String?>.from(currentState.generationErrors);

    newGeneratingCovers[mangaId] = false;
    newErrors[mangaId] = error;

    state = currentState.copyWith(
      generatingCovers: newGeneratingCovers,
      generationErrors: newErrors,
    );
  }

  /// 清除指定漫画的状态
  void clearStatus(String mangaId) {
    final currentState = state;
    final newGeneratingCovers = Map<String, bool>.from(currentState.generatingCovers);
    final newProgress = Map<String, double>.from(currentState.generationProgress);
    final newErrors = Map<String, String?>.from(currentState.generationErrors);

    newGeneratingCovers.remove(mangaId);
    newProgress.remove(mangaId);
    newErrors.remove(mangaId);

    state = currentState.copyWith(
      generatingCovers: newGeneratingCovers,
      generationProgress: newProgress,
      generationErrors: newErrors,
    );
  }

  /// 清除所有状态
  void clearAllStatus() {
    state = const CoverGenerationState();
  }
}

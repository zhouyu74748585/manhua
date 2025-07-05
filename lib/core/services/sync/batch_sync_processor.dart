import 'dart:async';
import 'dart:developer';

/// 分批同步处理器
/// 
/// 负责将大量数据分批处理，避免内存溢出和超时问题
class BatchSyncProcessor {
  // 配置参数
  static const int _defaultBatchSize = 50;
  static const int _maxBatchSize = 200;
  static const int _minBatchSize = 10;
  static const Duration _batchDelay = Duration(milliseconds: 100);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;

  /// 分批处理结果
  static Future<BatchSyncResult> processBatch<T>({
    required List<T> items,
    required Future<BatchProcessResult> Function(List<T> batch) processor,
    int? batchSize,
    Function(BatchProgress)? onProgress,
    Function(String)? onError,
    bool continueOnError = true,
  }) async {
    if (items.isEmpty) {
      return BatchSyncResult(
        totalItems: 0,
        processedItems: 0,
        failedItems: 0,
        batches: [],
        duration: Duration.zero,
      );
    }

    final effectiveBatchSize = _validateBatchSize(batchSize ?? _defaultBatchSize);
    final startTime = DateTime.now();
    final batches = <BatchResult>[];
    
    int totalProcessed = 0;
    int totalFailed = 0;

    log('开始分批处理: 总项目数=${items.length}, 批次大小=$effectiveBatchSize');

    // 分批处理
    for (int i = 0; i < items.length; i += effectiveBatchSize) {
      final endIndex = (i + effectiveBatchSize).clamp(0, items.length);
      final batch = items.sublist(i, endIndex);
      final batchIndex = (i / effectiveBatchSize).floor();
      
      log('处理批次 ${batchIndex + 1}/${((items.length - 1) / effectiveBatchSize).floor() + 1}: ${batch.length}项');

      // 处理当前批次
      final batchResult = await _processSingleBatch(
        batch: batch,
        batchIndex: batchIndex,
        processor: processor,
        onError: onError,
        continueOnError: continueOnError,
      );

      batches.add(batchResult);
      totalProcessed += batchResult.processedItems;
      totalFailed += batchResult.failedItems;

      // 更新进度
      final progress = BatchProgress(
        totalItems: items.length,
        processedItems: totalProcessed,
        failedItems: totalFailed,
        currentBatch: batchIndex + 1,
        totalBatches: ((items.length - 1) / effectiveBatchSize).floor() + 1,
        percentage: (totalProcessed + totalFailed) / items.length,
      );

      onProgress?.call(progress);

      // 如果不是最后一个批次，添加延迟
      if (endIndex < items.length) {
        await Future.delayed(_batchDelay);
      }

      // 如果遇到严重错误且不继续处理，则停止
      if (!continueOnError && batchResult.failedItems > 0) {
        log('批次处理失败，停止后续处理');
        break;
      }
    }

    final duration = DateTime.now().difference(startTime);
    
    final result = BatchSyncResult(
      totalItems: items.length,
      processedItems: totalProcessed,
      failedItems: totalFailed,
      batches: batches,
      duration: duration,
    );

    log('分批处理完成: ${result.toString()}');
    return result;
  }

  /// 处理单个批次
  static Future<BatchResult> _processSingleBatch<T>({
    required List<T> batch,
    required int batchIndex,
    required Future<BatchProcessResult> Function(List<T> batch) processor,
    Function(String)? onError,
    bool continueOnError = true,
  }) async {
    final startTime = DateTime.now();
    int retryCount = 0;
    
    while (retryCount <= _maxRetries) {
      try {
        final result = await processor(batch);
        final duration = DateTime.now().difference(startTime);
        
        return BatchResult(
          batchIndex: batchIndex,
          totalItems: batch.length,
          processedItems: result.processedItems,
          failedItems: result.failedItems,
          duration: duration,
          error: result.error,
          retryCount: retryCount,
        );
      } catch (e, stackTrace) {
        retryCount++;
        final errorMessage = '批次 $batchIndex 处理失败 (重试 $retryCount/$_maxRetries): $e';
        log(errorMessage, stackTrace: stackTrace);
        onError?.call(errorMessage);

        if (retryCount <= _maxRetries) {
          // 指数退避延迟
          final delay = Duration(milliseconds: _retryDelay.inMilliseconds * retryCount);
          await Future.delayed(delay);
        } else {
          // 达到最大重试次数
          final duration = DateTime.now().difference(startTime);
          return BatchResult(
            batchIndex: batchIndex,
            totalItems: batch.length,
            processedItems: 0,
            failedItems: batch.length,
            duration: duration,
            error: e.toString(),
            retryCount: retryCount - 1,
          );
        }
      }
    }

    // 这里不应该到达，但为了类型安全
    throw StateError('批次处理逻辑错误');
  }

  /// 验证批次大小
  static int _validateBatchSize(int batchSize) {
    return batchSize.clamp(_minBatchSize, _maxBatchSize);
  }

  /// 计算推荐的批次大小
  static int calculateOptimalBatchSize({
    required int totalItems,
    int? availableMemoryMB,
    int? estimatedItemSizeKB,
  }) {
    // 基于总项目数的基础批次大小
    int baseBatchSize;
    if (totalItems <= 100) {
      baseBatchSize = 25;
    } else if (totalItems <= 500) {
      baseBatchSize = 50;
    } else if (totalItems <= 1000) {
      baseBatchSize = 75;
    } else {
      baseBatchSize = 100;
    }

    // 基于内存限制调整
    if (availableMemoryMB != null && estimatedItemSizeKB != null) {
      final maxItemsForMemory = (availableMemoryMB * 1024) ~/ estimatedItemSizeKB;
      baseBatchSize = baseBatchSize.clamp(_minBatchSize, maxItemsForMemory);
    }

    return _validateBatchSize(baseBatchSize);
  }
}

/// 批次处理进度
class BatchProgress {
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final int currentBatch;
  final int totalBatches;
  final double percentage;

  const BatchProgress({
    required this.totalItems,
    required this.processedItems,
    required this.failedItems,
    required this.currentBatch,
    required this.totalBatches,
    required this.percentage,
  });

  @override
  String toString() {
    return 'BatchProgress(批次: $currentBatch/$totalBatches, '
           '进度: ${(percentage * 100).toStringAsFixed(1)}%, '
           '处理: $processedItems/$totalItems, 失败: $failedItems)';
  }
}

/// 批次同步结果
class BatchSyncResult {
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final List<BatchResult> batches;
  final Duration duration;

  const BatchSyncResult({
    required this.totalItems,
    required this.processedItems,
    required this.failedItems,
    required this.batches,
    required this.duration,
  });

  double get successRate => totalItems > 0 ? processedItems / totalItems : 0.0;
  double get failureRate => totalItems > 0 ? failedItems / totalItems : 0.0;
  bool get isSuccess => failedItems == 0;
  bool get hasPartialSuccess => processedItems > 0 && failedItems > 0;

  @override
  String toString() {
    return 'BatchSyncResult(总计: $totalItems, 成功: $processedItems, '
           '失败: $failedItems, 成功率: ${(successRate * 100).toStringAsFixed(1)}%, '
           '耗时: ${duration.inMilliseconds}ms)';
  }
}

/// 单个批次结果
class BatchResult {
  final int batchIndex;
  final int totalItems;
  final int processedItems;
  final int failedItems;
  final Duration duration;
  final String? error;
  final int retryCount;

  const BatchResult({
    required this.batchIndex,
    required this.totalItems,
    required this.processedItems,
    required this.failedItems,
    required this.duration,
    this.error,
    required this.retryCount,
  });

  bool get isSuccess => failedItems == 0;
  double get successRate => totalItems > 0 ? processedItems / totalItems : 0.0;

  @override
  String toString() {
    return 'BatchResult(批次: $batchIndex, 成功: $processedItems/$totalItems, '
           '重试: $retryCount, 耗时: ${duration.inMilliseconds}ms)';
  }
}

/// 批次处理结果（由处理器返回）
class BatchProcessResult {
  final int processedItems;
  final int failedItems;
  final String? error;

  const BatchProcessResult({
    required this.processedItems,
    required this.failedItems,
    this.error,
  });

  bool get isSuccess => failedItems == 0;
}

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/core/services/network/connection_pool_manager.dart';
import 'package:manhua_reader_flutter/core/services/sync/batch_sync_processor.dart';

void main() {
  group('性能优化测试', () {
    group('连接池管理测试', () {
      late ConnectionPoolManager poolManager;

      setUp(() {
        poolManager = ConnectionPoolManager.instance;
        // 重新初始化以确保状态清洁
        try {
          poolManager.initialize();
        } catch (e) {
          // 如果已经初始化，忽略错误
        }
      });

      tearDown(() async {
        // 不在每个测试后释放，避免状态问题
        // await poolManager.dispose();
      });

      test('连接池基本功能测试', () async {
        const baseUrl = 'http://test.example.com:8080';

        // 获取连接
        final dio1 = poolManager.getConnection(baseUrl);
        expect(dio1, isNotNull);
        expect(dio1.options.baseUrl, equals(baseUrl));

        // 复用连接
        final dio2 = poolManager.getConnection(baseUrl);
        expect(dio2, same(dio1)); // 应该是同一个实例

        // 获取统计信息
        final stats = poolManager.getStats();
        expect(stats.totalConnections, equals(1));
        expect(stats.connectionsByHost[baseUrl], equals(1));
      });

      test('连接池限制测试', () async {
        // 先清理现有连接
        await poolManager.dispose();
        poolManager.initialize();

        final connections = <String>[];

        // 创建多个连接
        for (int i = 0; i < 15; i++) {
          final url = 'http://test$i.example.com:8080';
          connections.add(url);
          poolManager.getConnection(url);
        }

        final stats = poolManager.getStats();
        // 连接数应该被限制在最大值以内
        expect(stats.totalConnections, lessThanOrEqualTo(10));
      });

      test('空闲连接清理测试', () async {
        // 先清理现有连接
        await poolManager.dispose();
        poolManager.initialize();

        const baseUrl = 'http://idle.example.com:8080';

        // 创建连接
        poolManager.getConnection(baseUrl);

        var stats = poolManager.getStats();
        expect(stats.totalConnections, equals(1));

        // 手动清理空闲连接
        poolManager.cleanupIdleConnections();

        stats = poolManager.getStats();
        // 由于刚创建，不应该被清理
        expect(stats.totalConnections, equals(1));
      });

      test('连接释放测试', () async {
        // 先清理现有连接
        await poolManager.dispose();
        poolManager.initialize();

        const baseUrl = 'http://release.example.com:8080';

        // 创建连接
        poolManager.getConnection(baseUrl);

        var stats = poolManager.getStats();
        expect(stats.totalConnections, equals(1));

        // 释放连接
        poolManager.releaseConnection(baseUrl);

        stats = poolManager.getStats();
        expect(stats.totalConnections, equals(0));
      });
    });

    group('分批处理测试', () {
      test('基本分批处理测试', () async {
        final items = List.generate(100, (index) => 'item_$index');

        final result = await BatchSyncProcessor.processBatch<String>(
          items: items,
          processor: (batch) async {
            // 模拟处理延迟
            await Future.delayed(const Duration(milliseconds: 10));
            return BatchProcessResult(
              processedItems: batch.length,
              failedItems: 0,
            );
          },
          batchSize: 25,
        );

        expect(result.totalItems, equals(100));
        expect(result.processedItems, equals(100));
        expect(result.failedItems, equals(0));
        expect(result.isSuccess, isTrue);
        expect(result.batches.length, equals(4)); // 100/25 = 4批次
      });

      test('分批处理进度回调测试', () async {
        final items = List.generate(50, (index) => 'item_$index');
        final progressUpdates = <BatchProgress>[];

        final result = await BatchSyncProcessor.processBatch<String>(
          items: items,
          processor: (batch) async {
            await Future.delayed(const Duration(milliseconds: 5));
            return BatchProcessResult(
              processedItems: batch.length,
              failedItems: 0,
            );
          },
          batchSize: 10,
          onProgress: (progress) {
            progressUpdates.add(progress);
          },
        );

        expect(result.isSuccess, isTrue);
        expect(progressUpdates.length, equals(5)); // 50/10 = 5批次

        // 验证进度递增
        for (int i = 0; i < progressUpdates.length; i++) {
          final progress = progressUpdates[i];
          expect(progress.currentBatch, equals(i + 1));
          expect(progress.totalBatches, equals(5));
          expect(progress.processedItems, equals((i + 1) * 10));
        }
      });

      test('分批处理错误处理测试', () async {
        final items = List.generate(30, (index) => 'item_$index');

        final result = await BatchSyncProcessor.processBatch<String>(
          items: items,
          processor: (batch) async {
            // 模拟第2批次失败
            if (batch.contains('item_10')) {
              throw Exception('模拟处理失败');
            }
            return BatchProcessResult(
              processedItems: batch.length,
              failedItems: 0,
            );
          },
          batchSize: 10,
          continueOnError: true,
        );

        expect(result.totalItems, equals(30));
        expect(result.processedItems, equals(20)); // 第1和第3批次成功
        expect(result.failedItems, equals(10)); // 第2批次失败
        expect(result.hasPartialSuccess, isTrue);
      });

      test('批次大小优化测试', () async {
        // 测试小数据量
        var batchSize = BatchSyncProcessor.calculateOptimalBatchSize(
          totalItems: 50,
        );
        expect(batchSize, equals(25));

        // 测试中等数据量
        batchSize = BatchSyncProcessor.calculateOptimalBatchSize(
          totalItems: 300,
        );
        expect(batchSize, equals(50));

        // 测试大数据量
        batchSize = BatchSyncProcessor.calculateOptimalBatchSize(
          totalItems: 1500,
        );
        expect(batchSize, equals(100));

        // 测试内存限制
        batchSize = BatchSyncProcessor.calculateOptimalBatchSize(
          totalItems: 1000,
          availableMemoryMB: 50,
          estimatedItemSizeKB: 100,
        );
        expect(batchSize, lessThanOrEqualTo(500)); // 50MB / 100KB = 500项
      });

      test('重试机制测试', () async {
        final items = ['item_1', 'item_2', 'item_3'];
        int attemptCount = 0;

        final result = await BatchSyncProcessor.processBatch<String>(
          items: items,
          processor: (batch) async {
            attemptCount++;
            if (attemptCount <= 2) {
              throw Exception('模拟网络错误');
            }
            return BatchProcessResult(
              processedItems: batch.length,
              failedItems: 0,
            );
          },
          batchSize: 3,
        );

        expect(result.isSuccess, isTrue);
        expect(attemptCount, equals(3)); // 2次失败 + 1次成功
        expect(result.batches.first.retryCount, equals(2));
      });

      test('空列表处理测试', () async {
        final result = await BatchSyncProcessor.processBatch<String>(
          items: [],
          processor: (batch) async {
            return BatchProcessResult(
              processedItems: 0,
              failedItems: 0,
            );
          },
        );

        expect(result.totalItems, equals(0));
        expect(result.processedItems, equals(0));
        expect(result.failedItems, equals(0));
        expect(result.batches.isEmpty, isTrue);
        expect(result.duration, equals(Duration.zero));
      });

      test('性能基准测试', () async {
        final items = List.generate(1000, (index) => 'item_$index');
        final stopwatch = Stopwatch()..start();

        final result = await BatchSyncProcessor.processBatch<String>(
          items: items,
          processor: (batch) async {
            // 模拟轻量级处理
            await Future.delayed(const Duration(microseconds: 100));
            return BatchProcessResult(
              processedItems: batch.length,
              failedItems: 0,
            );
          },
          batchSize: 100,
        );

        stopwatch.stop();

        expect(result.isSuccess, isTrue);
        expect(result.totalItems, equals(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒内完成

        // 计算吞吐量
        final throughput =
            result.totalItems / (stopwatch.elapsedMilliseconds / 1000);
        expect(throughput, greaterThan(200)); // 每秒处理200+项
      });
    });

    group('内存使用测试', () {
      test('大数据量内存稳定性测试', () async {
        // 创建大量测试数据
        final largeItems = List.generate(
            5000,
            (index) => {
                  'id': 'item_$index',
                  'data': List.generate(100, (i) => Random().nextInt(1000)),
                  'metadata': {
                    'created': DateTime.now().toIso8601String(),
                    'size': Random().nextInt(10000),
                  }
                });

        final result =
            await BatchSyncProcessor.processBatch<Map<String, dynamic>>(
          items: largeItems,
          processor: (batch) async {
            // 模拟数据处理
            final processed = batch
                .map((item) => {
                      ...item,
                      'processed': true,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    })
                .toList();

            // 模拟网络延迟
            await Future.delayed(const Duration(milliseconds: 50));

            return BatchProcessResult(
              processedItems: processed.length,
              failedItems: 0,
            );
          },
          batchSize: 100, // 较小的批次大小以控制内存使用
        );

        expect(result.isSuccess, isTrue);
        expect(result.totalItems, equals(5000));
        expect(result.processedItems, equals(5000));
      });
    });
  });
}

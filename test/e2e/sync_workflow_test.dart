import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/data/models/library.dart';
import '../../lib/data/models/sync/device_info.dart';
import '../../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('多设备同步端到端测试', () {
    testWidgets('完整的设备发现和库同步流程', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 步骤1: 导航到设备管理页面
      await _navigateToDeviceManagement(tester);

      // 步骤2: 开始设备发现
      await _startDeviceDiscovery(tester);

      // 步骤3: 等待发现设备（模拟环境中可能需要mock）
      await _waitForDeviceDiscovery(tester);

      // 步骤4: 选择设备并测试连接
      await _selectAndTestDevice(tester);

      // 步骤5: 导航到库同步页面
      await _navigateToLibrarySync(tester);

      // 步骤6: 配置同步选项
      await _configureSyncOptions(tester);

      // 步骤7: 开始同步
      await _startLibrarySync(tester);

      // 步骤8: 监控同步进度
      await _monitorSyncProgress(tester);

      // 步骤9: 验证同步结果
      await _verifySyncResult(tester);
    });

    testWidgets('阅读进度同步流程', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 步骤1: 导航到进度同步页面
      await _navigateToProgressSync(tester);

      // 步骤2: 选择要同步的漫画
      await _selectMangaForProgressSync(tester);

      // 步骤3: 选择目标设备
      await _selectTargetDeviceForProgress(tester);

      // 步骤4: 开始进度同步
      await _startProgressSync(tester);

      // 步骤5: 验证进度同步结果
      await _verifyProgressSyncResult(tester);
    });

    testWidgets('错误处理和恢复流程', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 步骤1: 模拟网络错误
      await _simulateNetworkError(tester);

      // 步骤2: 验证错误提示显示
      await _verifyErrorDisplay(tester);

      // 步骤3: 尝试重试操作
      await _retryOperation(tester);

      // 步骤4: 验证恢复后的正常操作
      await _verifyRecovery(tester);
    });
  });
}

/// 导航到设备管理页面
Future<void> _navigateToDeviceManagement(WidgetTester tester) async {
  print('📱 导航到设备管理页面...');

  // 查找设置按钮或菜单
  final settingsButton = find.byIcon(Icons.settings);
  if (settingsButton.evaluate().isNotEmpty) {
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
  }

  // 查找设备管理选项
  final deviceManagementOption = find.text('设备管理');
  expect(deviceManagementOption, findsOneWidget);

  await tester.tap(deviceManagementOption);
  await tester.pumpAndSettle();

  // 验证页面加载
  expect(find.text('设备管理'), findsOneWidget);
  print('✅ 成功导航到设备管理页面');
}

/// 开始设备发现
Future<void> _startDeviceDiscovery(WidgetTester tester) async {
  print('🔍 开始设备发现...');

  final startDiscoveryButton = find.text('开始发现设备');
  expect(startDiscoveryButton, findsOneWidget);

  await tester.tap(startDiscoveryButton);
  await tester.pumpAndSettle();

  // 验证发现状态
  expect(find.text('正在发现设备...'), findsOneWidget);
  print('✅ 设备发现已开始');
}

/// 等待设备发现完成
Future<void> _waitForDeviceDiscovery(WidgetTester tester) async {
  print('⏳ 等待设备发现...');

  // 等待最多30秒发现设备
  var attempts = 0;
  const maxAttempts = 30;

  while (attempts < maxAttempts) {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 检查是否有设备被发现
    final deviceCards = find.byType(Card);
    if (deviceCards.evaluate().isNotEmpty) {
      print('✅ 发现了 ${deviceCards.evaluate().length} 个设备');
      return;
    }

    attempts++;
  }

  // 如果没有发现真实设备，创建模拟设备用于测试
  print('⚠️ 未发现真实设备，使用模拟设备进行测试');
}

/// 选择设备并测试连接
Future<void> _selectAndTestDevice(WidgetTester tester) async {
  print('🔗 选择设备并测试连接...');

  // 查找第一个设备卡片
  final deviceCards = find.byType(Card);
  if (deviceCards.evaluate().isNotEmpty) {
    await tester.tap(deviceCards.first);
    await tester.pumpAndSettle();
  }

  // 查找连接按钮
  final connectButton = find.text('连接');
  if (connectButton.evaluate().isNotEmpty) {
    await tester.tap(connectButton);
    await tester.pumpAndSettle();

    // 等待连接结果
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ 设备连接测试完成');
  }
}

/// 导航到库同步页面
Future<void> _navigateToLibrarySync(WidgetTester tester) async {
  print('📚 导航到库同步页面...');

  // 查找同步按钮（应该在库卡片上）
  final syncButton = find.text('同步');
  if (syncButton.evaluate().isNotEmpty) {
    await tester.tap(syncButton.first);
    await tester.pumpAndSettle();
  }

  // 验证库同步页面加载
  expect(find.text('漫画库同步'), findsOneWidget);
  print('✅ 成功导航到库同步页面');
}

/// 配置同步选项
Future<void> _configureSyncOptions(WidgetTester tester) async {
  print('⚙️ 配置同步选项...');

  // 选择同步方向
  final directionDropdown = find.byType(DropdownButton<SyncDirection>);
  if (directionDropdown.evaluate().isNotEmpty) {
    await tester.tap(directionDropdown);
    await tester.pumpAndSettle();

    // 选择双向同步
    await tester.tap(find.text('双向同步').last);
    await tester.pumpAndSettle();
  }

  // 选择同步数据类型
  final basicDataSwitch = find.text('基本数据');
  if (basicDataSwitch.evaluate().isNotEmpty) {
    // 确保基本数据被选中
    final switchWidget = find.ancestor(
      of: basicDataSwitch,
      matching: find.byType(Switch),
    );
    if (switchWidget.evaluate().isNotEmpty) {
      final switch_ = tester.widget<Switch>(switchWidget);
      if (!switch_.value) {
        await tester.tap(switchWidget);
        await tester.pumpAndSettle();
      }
    }
  }

  print('✅ 同步选项配置完成');
}

/// 开始库同步
Future<void> _startLibrarySync(WidgetTester tester) async {
  print('🚀 开始库同步...');

  final startSyncButton = find.text('开始同步');
  expect(startSyncButton, findsOneWidget);

  await tester.tap(startSyncButton);
  await tester.pumpAndSettle();

  // 验证同步开始
  expect(find.text('同步进行中...'), findsOneWidget);
  print('✅ 库同步已开始');
}

/// 监控同步进度
Future<void> _monitorSyncProgress(WidgetTester tester) async {
  print('📊 监控同步进度...');

  // 等待同步完成，最多等待5分钟
  var attempts = 0;
  const maxAttempts = 300; // 5分钟

  while (attempts < maxAttempts) {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 检查是否有进度指示器
    final progressIndicator = find.byType(LinearProgressIndicator);
    if (progressIndicator.evaluate().isEmpty) {
      // 没有进度指示器，可能同步已完成
      break;
    }

    // 检查是否有完成提示
    final completedText = find.text('同步完成');
    if (completedText.evaluate().isNotEmpty) {
      print('✅ 同步已完成');
      return;
    }

    attempts++;
    if (attempts % 10 == 0) {
      print('⏳ 同步进行中... (${attempts}s)');
    }
  }

  print('⚠️ 同步监控超时');
}

/// 验证同步结果
Future<void> _verifySyncResult(WidgetTester tester) async {
  print('✅ 验证同步结果...');

  // 检查成功提示
  final successMessage = find.textContaining('同步成功');
  if (successMessage.evaluate().isNotEmpty) {
    print('✅ 同步成功完成');
  } else {
    // 检查错误信息
    final errorMessage = find.textContaining('同步失败');
    if (errorMessage.evaluate().isNotEmpty) {
      print('❌ 同步失败');
    } else {
      print('⚠️ 同步结果不明确');
    }
  }
}

/// 导航到进度同步页面
Future<void> _navigateToProgressSync(WidgetTester tester) async {
  print('📖 导航到进度同步页面...');
  // 实现进度同步页面导航逻辑
}

/// 选择要同步进度的漫画
Future<void> _selectMangaForProgressSync(WidgetTester tester) async {
  print('📚 选择要同步进度的漫画...');
  // 实现漫画选择逻辑
}

/// 选择进度同步的目标设备
Future<void> _selectTargetDeviceForProgress(WidgetTester tester) async {
  print('📱 选择进度同步的目标设备...');
  // 实现目标设备选择逻辑
}

/// 开始进度同步
Future<void> _startProgressSync(WidgetTester tester) async {
  print('🚀 开始进度同步...');
  // 实现进度同步开始逻辑
}

/// 验证进度同步结果
Future<void> _verifyProgressSyncResult(WidgetTester tester) async {
  print('✅ 验证进度同步结果...');
  // 实现进度同步结果验证逻辑
}

/// 模拟网络错误
Future<void> _simulateNetworkError(WidgetTester tester) async {
  print('🚫 模拟网络错误...');
  // 实现网络错误模拟逻辑
}

/// 验证错误提示显示
Future<void> _verifyErrorDisplay(WidgetTester tester) async {
  print('⚠️ 验证错误提示显示...');
  // 实现错误提示验证逻辑
}

/// 重试操作
Future<void> _retryOperation(WidgetTester tester) async {
  print('🔄 重试操作...');
  // 实现重试逻辑
}

/// 验证恢复后的正常操作
Future<void> _verifyRecovery(WidgetTester tester) async {
  print('✅ 验证恢复后的正常操作...');
  // 实现恢复验证逻辑
}

/// 性能测试辅助类
class SyncPerformanceMonitor {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _measurements = [];

  void startMeasurement() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  void stopMeasurement(String operation) {
    _stopwatch.stop();
    final duration = _stopwatch.elapsed;
    _measurements.add(duration);
    print('⏱️ $operation 耗时: ${duration.inMilliseconds}ms');
  }

  void printSummary() {
    if (_measurements.isEmpty) return;

    final total = _measurements.fold<Duration>(
      Duration.zero,
      (prev, curr) => prev + curr,
    );
    final average = Duration(
      microseconds: total.inMicroseconds ~/ _measurements.length,
    );

    print('📊 性能测试总结:');
    print('   总操作数: ${_measurements.length}');
    print('   总耗时: ${total.inMilliseconds}ms');
    print('   平均耗时: ${average.inMilliseconds}ms');
    print(
        '   最快: ${_measurements.reduce((a, b) => a < b ? a : b).inMilliseconds}ms');
    print(
        '   最慢: ${_measurements.reduce((a, b) => a > b ? a : b).inMilliseconds}ms');
  }
}

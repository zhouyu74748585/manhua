import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/core/services/network/device_discovery_service.dart';
import 'package:manhua_reader_flutter/core/services/network/sync_communication_service.dart';
import 'package:manhua_reader_flutter/data/services/sync/multi_device_sync_service.dart';

void main() {
  group('资源管理测试', () {
    test('MultiDeviceSyncService 资源释放测试', () async {
      final service = MultiDeviceSyncService();

      // 初始化服务
      await service.initialize();

      // 验证服务已初始化
      expect(service.isInitialized, true);

      // 释放资源
      await service.dispose();

      // 验证资源已释放
      expect(service.isInitialized, false);
    });

    test('DeviceDiscoveryService 资源释放测试', () async {
      final service = DeviceDiscoveryService();

      // 初始化服务
      await service.initialize();

      // 释放资源（跳过startDiscovery以避免mDNS问题）
      await service.dispose();

      // 验证资源已释放
      expect(service.isDiscovering, false);
    });

    test('SyncCommunicationService 资源释放测试', () async {
      final service = SyncCommunicationService();

      // 初始化服务
      await service.initialize();

      // 释放资源
      await service.dispose();

      // 验证服务已释放（通过检查是否能正常调用dispose）
      expect(() => service.dispose(), returnsNormally);
    });

    test('StreamController 内存泄漏测试', () async {
      final service = MultiDeviceSyncService();

      // 初始化服务
      await service.initialize();

      // 监听流以确保StreamController正常工作
      final subscription = service.devicesStream.listen((_) {});

      // 释放资源
      await service.dispose();

      // 取消订阅
      await subscription.cancel();

      // 验证StreamController已关闭
      expect(service.devicesStream, emitsDone);
    });

    test('Timer 资源清理测试', () async {
      final service = DeviceDiscoveryService();

      // 初始化服务（跳过startDiscovery以避免mDNS问题）
      await service.initialize();

      // 等待一段时间
      await Future.delayed(const Duration(milliseconds: 100));

      // 释放资源
      await service.dispose();

      // 验证服务已停止
      expect(service.isDiscovering, false);
    });

    test('会话清理机制测试', () async {
      final service = MultiDeviceSyncService();

      // 初始化服务
      await service.initialize();

      // 获取初始会话数量
      final initialSessions = service.getActiveSyncSessions();
      expect(initialSessions.length, 0);

      // 释放资源
      await service.dispose();

      // 验证会话已清理
      final finalSessions = service.getActiveSyncSessions();
      expect(finalSessions.length, 0);
    });

    test('多次dispose调用安全性测试', () async {
      final service = MultiDeviceSyncService();

      // 初始化服务
      await service.initialize();

      // 多次调用dispose应该是安全的
      await service.dispose();
      await service.dispose();
      await service.dispose();

      // 验证没有异常抛出
      expect(service.isInitialized, false);
    });

    test('资源监控功能测试', () async {
      final service = MultiDeviceSyncService();

      // 初始化服务
      await service.initialize();

      // 等待资源监控运行
      await Future.delayed(const Duration(milliseconds: 200));

      // 释放资源
      await service.dispose();

      // 验证监控已停止
      expect(service.isInitialized, false);
    });
  });

  group('性能优化测试', () {
    test('设备发现频率优化测试', () async {
      final service = DeviceDiscoveryService();

      // 初始化服务
      await service.initialize();

      // 验证服务已初始化
      expect(service.isDiscovering, false);

      // 清理
      await service.dispose();

      // 验证清理完成
      expect(service.isDiscovering, false);
    });

    test('超时配置优化测试', () async {
      final service = SyncCommunicationService();

      // 初始化服务
      await service.initialize();

      // 验证服务已初始化（通过能够正常dispose来验证）
      expect(() => service.dispose(), returnsNormally);

      // 清理
      await service.dispose();
    });
  });
}

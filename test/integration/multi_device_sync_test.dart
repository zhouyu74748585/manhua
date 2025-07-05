import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/core/services/network/device_discovery_service.dart';
import '../../lib/core/services/network/sync_communication_service.dart';
import '../../lib/data/models/library.dart';
import '../../lib/data/models/manga.dart';
import '../../lib/data/models/sync/device_info.dart';
import '../../lib/data/models/sync/sync_session.dart';
import '../../lib/data/services/sync/multi_device_sync_service.dart';
import '../../lib/data/services/sync/library_sync_service.dart';
import '../../lib/data/services/sync/sync_coordinator_service.dart';

// 生成Mock类
@GenerateMocks([
  DeviceDiscoveryService,
  SyncCommunicationService,
  LibrarySyncService,
])
import 'multi_device_sync_test.mocks.dart';

void main() {
  group('多设备同步集成测试', () {
    late MultiDeviceSyncService syncService;
    late SyncCoordinatorService coordinatorService;
    late MockDeviceDiscoveryService mockDiscoveryService;
    late MockSyncCommunicationService mockCommunicationService;
    late MockLibrarySyncService mockLibrarySyncService;

    setUp(() {
      mockDiscoveryService = MockDeviceDiscoveryService();
      mockCommunicationService = MockSyncCommunicationService();
      mockLibrarySyncService = MockLibrarySyncService();

      // 创建测试用的同步服务
      syncService = MultiDeviceSyncService();
      coordinatorService = SyncCoordinatorService(
        multiDeviceSyncService: syncService,
        librarySyncService: mockLibrarySyncService,
      );
    });

    tearDown(() {
      syncService.dispose();
      coordinatorService.dispose();
    });

    group('设备发现测试', () {
      testWidgets('TC001: 基本设备发现功能', (WidgetTester tester) async {
        // 准备测试数据
        final testDevice = DeviceInfo(
          id: 'test-device-1',
          name: 'Test Device',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.100',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
          capabilities: ['library_sync', 'progress_sync'],
        );

        // 模拟设备发现
        when(mockDiscoveryService.discoveredDevices).thenReturn([testDevice]);
        when(mockDiscoveryService.devicesStream)
            .thenAnswer((_) => Stream.value([testDevice]));

        // 开始设备发现
        await coordinatorService.startDeviceDiscovery();

        // 验证设备被发现
        final devices = coordinatorService.getAvailableDevices();
        expect(devices, isNotEmpty);
        expect(devices.first.id, equals('test-device-1'));
        expect(devices.first.name, equals('Test Device'));
        expect(devices.first.isOnline, isTrue);
      });

      testWidgets('TC002: 设备连接测试', (WidgetTester tester) async {
        final testDevice = DeviceInfo(
          id: 'test-device-2',
          name: 'Target Device',
          platform: 'Windows',
          version: '1.0.0',
          ipAddress: '192.168.1.101',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟连接测试成功
        when(mockCommunicationService.pingDevice(testDevice))
            .thenAnswer((_) async => true);

        // 测试设备连通性
        final isConnected = await syncService.testDeviceConnectivity(testDevice);
        expect(isConnected, isTrue);

        // 验证ping方法被调用
        verify(mockCommunicationService.pingDevice(testDevice)).called(1);
      });
    });

    group('漫画库同步测试', () {
      testWidgets('TC003: 单库同步测试', (WidgetTester tester) async {
        // 准备测试数据
        final testLibrary = MangaLibrary(
          id: 'lib-001',
          name: '测试漫画库',
          path: '/test/manga',
          isEnabled: true,
          mangaCount: 10,
          coverDisplayMode: CoverDisplayMode.defaultMode,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final targetDevice = DeviceInfo(
          id: 'target-device',
          name: 'Target Device',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.102',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟同步成功
        final mockSyncResult = SyncResult(
          sessionId: 'test-session-1',
          status: SyncStatus.completed,
          totalItems: 1,
          processedItems: 1,
          failedItems: 0,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );

        when(mockLibrarySyncService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: ['lib-001'],
          direction: SyncDirection.toRemote,
          resolveConflictsAutomatically: true,
        )).thenAnswer((_) async => mockSyncResult);

        // 执行库同步
        final result = await coordinatorService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: ['lib-001'],
          direction: SyncDirection.toRemote,
        );

        // 验证同步结果
        expect(result.status, equals(SyncStatus.completed));
        expect(result.totalItems, equals(1));
        expect(result.processedItems, equals(1));
        expect(result.failedItems, equals(0));
      });

      testWidgets('TC004: 双向同步测试', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'bidirectional-device',
          name: 'Bidirectional Device',
          platform: 'Windows',
          version: '1.0.0',
          ipAddress: '192.168.1.103',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟双向同步成功
        final mockSyncResult = SyncResult(
          sessionId: 'bidirectional-session',
          status: SyncStatus.completed,
          totalItems: 2,
          processedItems: 2,
          failedItems: 0,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );

        when(mockLibrarySyncService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: ['lib-001', 'lib-002'],
          direction: SyncDirection.bidirectional,
          resolveConflictsAutomatically: true,
        )).thenAnswer((_) async => mockSyncResult);

        // 执行双向同步
        final result = await coordinatorService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: ['lib-001', 'lib-002'],
          direction: SyncDirection.bidirectional,
        );

        // 验证双向同步结果
        expect(result.status, equals(SyncStatus.completed));
        expect(result.totalItems, equals(2));
        expect(result.processedItems, equals(2));
      });
    });

    group('阅读进度同步测试', () {
      testWidgets('TC005: 进度同步测试', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'progress-device',
          name: 'Progress Device',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.104',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟进度同步成功
        final mockProgressResult = SyncResult(
          sessionId: 'progress-session',
          status: SyncStatus.completed,
          totalItems: 1,
          processedItems: 1,
          failedItems: 0,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );

        when(mockLibrarySyncService.syncReadingProgress(
          targetDevice: targetDevice,
          mangaId: 'manga-001',
          useLatestWins: true,
        )).thenAnswer((_) async => mockProgressResult);

        // 执行进度同步
        final result = await coordinatorService.syncReadingProgress(
          targetDevice: targetDevice,
          mangaId: 'manga-001',
        );

        // 验证进度同步结果
        expect(result.status, equals(SyncStatus.completed));
        expect(result.processedItems, equals(1));
      });
    });

    group('错误处理测试', () {
      testWidgets('TC006: 网络连接失败处理', (WidgetTester tester) async {
        final unreachableDevice = DeviceInfo(
          id: 'unreachable-device',
          name: 'Unreachable Device',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.999', // 无效IP
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: false,
        );

        // 模拟连接失败
        when(mockCommunicationService.pingDevice(unreachableDevice))
            .thenThrow(const SocketException('Network unreachable'));

        // 测试连接失败处理
        expect(
          () async => await syncService.testDeviceConnectivity(unreachableDevice),
          throwsA(isA<SocketException>()),
        );
      });

      testWidgets('TC007: 同步过程中断处理', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'interrupted-device',
          name: 'Interrupted Device',
          platform: 'Windows',
          version: '1.0.0',
          ipAddress: '192.168.1.105',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟同步中断
        when(mockLibrarySyncService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: ['lib-001'],
          direction: SyncDirection.toRemote,
          resolveConflictsAutomatically: true,
        )).thenThrow(const SocketException('Connection reset'));

        // 验证错误处理
        expect(
          () async => await coordinatorService.syncLibraries(
            targetDevice: targetDevice,
            libraryIds: ['lib-001'],
            direction: SyncDirection.toRemote,
          ),
          throwsA(isA<SocketException>()),
        );
      });
    });

    group('性能测试', () {
      testWidgets('TC008: 大数据量同步性能', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'performance-device',
          name: 'Performance Device',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.106',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // 模拟大量库的同步
        final largeLibraryList = List.generate(100, (index) => 'lib-$index');
        
        final mockLargeResult = SyncResult(
          sessionId: 'large-sync-session',
          status: SyncStatus.completed,
          totalItems: 100,
          processedItems: 100,
          failedItems: 0,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );

        when(mockLibrarySyncService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: largeLibraryList,
          direction: SyncDirection.toRemote,
          resolveConflictsAutomatically: true,
        )).thenAnswer((_) async => mockLargeResult);

        // 测试大数据量同步
        final stopwatch = Stopwatch()..start();
        final result = await coordinatorService.syncLibraries(
          targetDevice: targetDevice,
          libraryIds: largeLibraryList,
          direction: SyncDirection.toRemote,
        );
        stopwatch.stop();

        // 验证性能指标
        expect(result.status, equals(SyncStatus.completed));
        expect(result.totalItems, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒内完成
      });
    });
  });
}

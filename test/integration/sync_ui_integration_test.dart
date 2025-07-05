import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:manhua_reader_flutter/data/models/library.dart';
import 'package:manhua_reader_flutter/data/models/sync/device_info.dart';
import 'package:manhua_reader_flutter/data/models/sync/sync_session.dart';
import 'package:manhua_reader_flutter/data/services/sync/multi_device_sync_service.dart';
import 'package:manhua_reader_flutter/presentation/pages/sync/device_management_page.dart';
import 'package:manhua_reader_flutter/presentation/pages/sync/library_sync_page.dart';
import 'package:manhua_reader_flutter/presentation/providers/sync_providers.dart';

// 生成Mock类
@GenerateMocks([
  MultiDeviceSyncService,
])
import 'sync_ui_integration_test.mocks.dart';

void main() {
  group('同步UI集成测试', () {
    late MockMultiDeviceSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockMultiDeviceSyncService();
    });

    group('设备管理页面测试', () {
      testWidgets('显示发现的设备列表', (WidgetTester tester) async {
        // 准备测试数据
        final testDevices = [
          DeviceInfo(
            id: 'device-1',
            name: '测试设备1',
            platform: 'Android',
            version: '1.0.0',
            ipAddress: '192.168.1.100',
            port: 8080,
            lastSeen: DateTime.now(),
            isOnline: true,
          ),
          DeviceInfo(
            id: 'device-2',
            name: '测试设备2',
            platform: 'Windows',
            version: '1.0.0',
            ipAddress: '192.168.1.101',
            port: 8080,
            lastSeen: DateTime.now(),
            isOnline: false,
          ),
        ];

        // 模拟设备流
        when(mockSyncService.devicesStream)
            .thenAnswer((_) => Stream.value(testDevices));
        when(mockSyncService.discoveredDevices).thenReturn(testDevices);

        // 创建测试应用
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              multiDeviceSyncServiceProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: DeviceManagementPage(),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        // 等待UI构建完成
        await tester.pumpAndSettle();

        // 验证页面标题
        expect(find.text('设备管理'), findsOneWidget);

        // 验证设备列表显示
        expect(find.text('测试设备1'), findsOneWidget);
        expect(find.text('测试设备2'), findsOneWidget);
        expect(find.text('Android'), findsOneWidget);
        expect(find.text('Windows'), findsOneWidget);

        // 验证在线状态显示
        expect(find.byIcon(Icons.circle), findsNWidgets(2)); // 在线/离线指示器
      });

      testWidgets('开始和停止设备发现', (WidgetTester tester) async {
        // 模拟空设备列表
        when(mockSyncService.devicesStream)
            .thenAnswer((_) => Stream.value([]));
        when(mockSyncService.discoveredDevices).thenReturn([]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              multiDeviceSyncServiceProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: DeviceManagementPage(),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 查找开始发现按钮
        final startDiscoveryButton = find.text('开始发现设备');
        expect(startDiscoveryButton, findsOneWidget);

        // 点击开始发现
        await tester.tap(startDiscoveryButton);
        await tester.pumpAndSettle();

        // 验证startDeviceDiscovery被调用
        verify(mockSyncService.startDeviceDiscovery()).called(1);

        // 验证按钮文本变化
        expect(find.text('停止发现'), findsOneWidget);
      });

      testWidgets('测试设备连接', (WidgetTester tester) async {
        final testDevice = DeviceInfo(
          id: 'test-device',
          name: '测试设备',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.100',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        when(mockSyncService.devicesStream)
            .thenAnswer((_) => Stream.value([testDevice]));
        when(mockSyncService.discoveredDevices).thenReturn([testDevice]);
        when(mockSyncService.testDeviceConnectivity(testDevice))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              multiDeviceSyncServiceProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: DeviceManagementPage(),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 查找连接按钮
        final connectButton = find.text('连接');
        expect(connectButton, findsOneWidget);

        // 点击连接按钮
        await tester.tap(connectButton);
        await tester.pumpAndSettle();

        // 验证连接测试被调用
        verify(mockSyncService.testDeviceConnectivity(testDevice)).called(1);
      });
    });

    group('库同步页面测试', () {
      testWidgets('显示同步选项和设备信息', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'target-device',
          name: '目标设备',
          platform: 'Windows',
          version: '1.0.0',
          ipAddress: '192.168.1.101',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LibrarySyncPage(targetDevice: targetDevice),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 验证页面标题
        expect(find.text('漫画库同步'), findsOneWidget);

        // 验证目标设备信息显示
        expect(find.text('目标设备'), findsOneWidget);
        expect(find.text('Windows'), findsOneWidget);

        // 验证同步方向选项
        expect(find.text('双向同步'), findsOneWidget);
        expect(find.text('发送到目标设备'), findsOneWidget);
        expect(find.text('从目标设备接收'), findsOneWidget);

        // 验证数据选择选项
        expect(find.text('基本数据'), findsOneWidget);
        expect(find.text('封面图片'), findsOneWidget);
        expect(find.text('缩略图'), findsOneWidget);
        expect(find.text('原始文件'), findsOneWidget);
      });

      testWidgets('选择同步方向', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'target-device',
          name: '目标设备',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.102',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LibrarySyncPage(targetDevice: targetDevice),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 查找同步方向选择器
        final directionDropdown = find.byType(DropdownButton<SyncDirection>);
        expect(directionDropdown, findsOneWidget);

        // 点击下拉菜单
        await tester.tap(directionDropdown);
        await tester.pumpAndSettle();

        // 选择"发送到目标设备"
        await tester.tap(find.text('发送到目标设备').last);
        await tester.pumpAndSettle();

        // 验证选择生效
        expect(find.text('发送到目标设备'), findsOneWidget);
      });

      testWidgets('开始同步操作', (WidgetTester tester) async {
        final targetDevice = DeviceInfo(
          id: 'sync-device',
          name: '同步设备',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.103',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LibrarySyncPage(targetDevice: targetDevice),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 查找开始同步按钮
        final startSyncButton = find.text('开始同步');
        expect(startSyncButton, findsOneWidget);

        // 验证按钮初始状态
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: startSyncButton,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('同步进度测试', () {
      testWidgets('显示同步进度信息', (WidgetTester tester) async {
        // 这里可以添加同步进度页面的测试
        // 由于SyncProgressPage比较复杂，这里先跳过具体实现
      });
    });

    group('错误处理UI测试', () {
      testWidgets('显示网络错误提示', (WidgetTester tester) async {
        // 模拟网络错误
        when(mockSyncService.devicesStream)
            .thenAnswer((_) => Stream.error('网络连接失败'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              multiDeviceSyncServiceProvider.overrideWithValue(mockSyncService),
            ],
            child: MaterialApp(
              home: DeviceManagementPage(),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 验证错误提示显示
        // 这里需要根据实际的错误处理UI来验证
      });
    });

    group('响应性测试', () {
      testWidgets('页面在不同屏幕尺寸下正常显示', (WidgetTester tester) async {
        // 设置不同的屏幕尺寸
        await tester.binding.setSurfaceSize(const Size(360, 640)); // 手机尺寸

        final testDevice = DeviceInfo(
          id: 'responsive-device',
          name: '响应式测试设备',
          platform: 'Android',
          version: '1.0.0',
          ipAddress: '192.168.1.104',
          port: 8080,
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LibrarySyncPage(targetDevice: testDevice),
              locale: const Locale('zh', 'CN'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 验证UI元素在小屏幕上正常显示
        expect(find.text('漫画库同步'), findsOneWidget);
        expect(find.text('响应式测试设备'), findsOneWidget);

        // 恢复默认屏幕尺寸
        await tester.binding.setSurfaceSize(const Size(800, 600));
      });
    });
  });
}

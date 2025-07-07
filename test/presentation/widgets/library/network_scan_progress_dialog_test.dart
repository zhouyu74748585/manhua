import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/data/models/library.dart';
import 'package:manhua_reader_flutter/data/models/network_config.dart';
import 'package:manhua_reader_flutter/presentation/widgets/library/network_scan_progress_dialog.dart';

void main() {
  group('NetworkScanProgressDialog 测试', () {
    late MangaLibrary testLibrary;

    setUp(() {
      // 创建测试用的网络漫画库
      testLibrary = MangaLibrary(
        id: 'test_library_id',
        name: '测试网络库',
        path: 'smb://10.0.0.3/share',
        type: LibraryType.network,
        isEnabled: true,
        createdAt: DateTime.now(),
        settings: LibrarySettings(
          networkConfig: const NetworkConfig(
            protocol: NetworkProtocol.smb,
            host: '10.0.0.3',
            port: 445,
            username: 'zhouyu',
            password: '946898',
            shareName: 'share',
          ),
        ),
      );
    });

    testWidgets('应该在初始化时启动扫描', (WidgetTester tester) async {
      const taskId = 'scan_test_library_id_1234567890';

      // 构建对话框
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NetworkScanProgressDialog(
                library: testLibrary,
                taskId: taskId,
              ),
            ),
          ),
        ),
      );

      // 验证初始状态显示"正在初始化扫描..."
      expect(find.text('正在初始化扫描...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待一帧以确保initState完成
      await tester.pump();

      // 验证对话框标题
      expect(find.text('扫描网络漫画库'), findsOneWidget);
      expect(find.text('测试网络库'), findsOneWidget);
    });

    testWidgets('应该显示网络配置无效的错误', (WidgetTester tester) async {
      // 创建无效配置的库
      final invalidLibrary = testLibrary.copyWith(
        settings: const LibrarySettings(
          networkConfig: NetworkConfig(
            protocol: NetworkProtocol.smb,
            host: '', // 无效的主机
          ),
        ),
      );

      const taskId = 'test_task_id';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NetworkScanProgressDialog(
                library: invalidLibrary,
                taskId: taskId,
              ),
            ),
          ),
        ),
      );

      // 等待扫描启动和错误处理
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 验证显示配置无效错误
      expect(find.textContaining('网络配置无效'), findsOneWidget);
    });

    testWidgets('应该在初始状态显示取消按钮', (WidgetTester tester) async {
      const taskId = 'test_task_id';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NetworkScanProgressDialog(
                library: testLibrary,
                taskId: taskId,
              ),
            ),
          ),
        ),
      );

      // 在扫描开始前，应该显示取消按钮
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('应该能够取消扫描', (WidgetTester tester) async {
      const taskId = 'test_task_id';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NetworkScanProgressDialog(
                library: testLibrary,
                taskId: taskId,
              ),
            ),
          ),
        ),
      );

      // 验证初始状态有取消按钮
      expect(find.text('取消'), findsOneWidget);

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pump();

      // 验证取消状态
      // 注意：实际的取消逻辑会通过NetworkScanQueueManager处理
      // 这里主要验证UI响应
    });
  });

  group('网络配置解析测试', () {
    test('应该正确解析SMB连接字符串', () {
      const connectionString = 'smb://zhouyu:946898@10.0.0.3:445/share';
      final config = NetworkConfig.fromConnectionString(connectionString);

      expect(config.protocol, equals(NetworkProtocol.smb));
      expect(config.host, equals('10.0.0.3'));
      expect(config.port, equals(445));
      expect(config.username, equals('zhouyu'));
      expect(config.password, equals('946898'));
      expect(config.shareName, equals('share'));
      expect(config.isValid, isTrue);
    });

    test('应该处理无效的连接字符串', () {
      const connectionString = 'invalid://';
      final config = NetworkConfig.fromConnectionString(connectionString);

      expect(config.isValid, isFalse);
    });
  });
}

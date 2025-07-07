import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lib/core/services/network/network_scan_queue_manager.dart';
import 'lib/data/models/library.dart';
import 'lib/data/models/network_config.dart';
import 'lib/presentation/widgets/library/network_scan_progress_dialog.dart';

/// 验证网络扫描修复的测试应用
class ScanFixVerificationApp extends StatelessWidget {
  const ScanFixVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: '网络扫描修复验证',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ScanTestPage(),
      ),
    );
  }
}

class ScanTestPage extends StatefulWidget {
  const ScanTestPage({super.key});

  @override
  State<ScanTestPage> createState() => _ScanTestPageState();
}

class _ScanTestPageState extends State<ScanTestPage> {
  late MangaLibrary testLibrary;

  @override
  void initState() {
    super.initState();
    
    // 创建测试用的网络漫画库
    testLibrary = MangaLibrary(
      id: 'test_library_id',
      name: '测试SMB网络库',
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
  }

  void _testNetworkScan() async {
    // 生成任务ID（与LibraryCard中的格式一致）
    final taskId = 'scan_${testLibrary.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    // 显示进度对话框
    final result = await showDialog<NetworkScanProgress>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkScanProgressDialog(
        library: testLibrary,
        taskId: taskId,
      ),
    );

    // 显示结果
    if (mounted) {
      String message;
      Color color;
      
      if (result?.status == NetworkScanStatus.completed) {
        message = '扫描成功！发现 ${result?.foundMangas?.length ?? 0} 个漫画';
        color = Colors.green;
      } else if (result?.status == NetworkScanStatus.failed) {
        message = '扫描失败：${result?.message ?? "未知错误"}';
        color = Colors.red;
      } else if (result?.status == NetworkScanStatus.cancelled) {
        message = '扫描已取消';
        color = Colors.orange;
      } else {
        message = '扫描状态未知';
        color = Colors.grey;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _testInvalidConfig() async {
    // 创建无效配置的库
    final invalidLibrary = testLibrary.copyWith(
      name: '无效配置测试库',
      settings: const LibrarySettings(
        networkConfig: NetworkConfig(
          protocol: NetworkProtocol.smb,
          host: '', // 无效的主机
        ),
      ),
    );

    final taskId = 'scan_${invalidLibrary.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    final result = await showDialog<NetworkScanProgress>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkScanProgressDialog(
        library: invalidLibrary,
        taskId: taskId,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无效配置测试结果：${result?.message ?? "无结果"}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络扫描修复验证'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '网络扫描修复验证测试',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '测试库信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('名称：${testLibrary.name}'),
                    Text('协议：${testLibrary.settings.networkConfig?.protocol.name ?? "未知"}'),
                    Text('主机：${testLibrary.settings.networkConfig?.host ?? "未知"}'),
                    Text('用户名：${testLibrary.settings.networkConfig?.username ?? "未知"}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _testNetworkScan,
              icon: const Icon(Icons.refresh),
              label: const Text('测试网络扫描'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _testInvalidConfig,
              icon: const Icon(Icons.error),
              label: const Text('测试无效配置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '预期行为',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('✓ 点击"测试网络扫描"应该立即开始连接和扫描'),
                    Text('✓ 不应该一直显示"正在初始化扫描..."'),
                    Text('✓ 应该显示具体的连接和扫描进度'),
                    Text('✓ 点击"测试无效配置"应该立即显示配置错误'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const ScanFixVerificationApp());
}

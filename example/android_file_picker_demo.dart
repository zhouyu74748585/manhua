import 'package:flutter/material.dart';
import '../lib/core/services/enhanced_file_picker_service.dart';

/// Android文件选择器问题演示应用
class AndroidFilePickerDemo extends StatefulWidget {
  const AndroidFilePickerDemo({super.key});

  @override
  State<AndroidFilePickerDemo> createState() => _AndroidFilePickerDemoState();
}

class _AndroidFilePickerDemoState extends State<AndroidFilePickerDemo> {
  String? _selectedPath;
  bool _isLoading = false;
  List<String> _grantedPaths = [];

  @override
  void initState() {
    super.initState();
    _loadGrantedPaths();
  }

  Future<void> _loadGrantedPaths() async {
    final paths = await EnhancedFilePickerService.getGrantedPaths();
    setState(() {
      _grantedPaths = paths;
    });
  }

  Future<void> _selectDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EnhancedFilePickerService.pickDirectoryWithPermission(
        context: context,
        dialogTitle: '选择漫画库文件夹',
      );

      setState(() {
        _selectedPath = result;
        _isLoading = false;
      });

      if (result != null) {
        await _loadGrantedPaths();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('成功选择文件夹: $result'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件夹失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearPermissions() async {
    await EnhancedFilePickerService.clearAllPermissions();
    await _loadGrantedPaths();
    setState(() {
      _selectedPath = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已清除所有权限数据'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android文件选择器演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 问题说明卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          '问题说明',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Android 11+系统中，文件选择器可能返回根目录"/"而不是实际选择的路径。'
                      '我们的解决方案提供了多种备用方案来处理这个问题。',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 选择文件夹按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _selectDirectory,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open),
              label: Text(_isLoading ? '选择中...' : '选择文件夹'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // 当前选择的路径
            if (_selectedPath != null) ...[
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            '当前选择的路径',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _selectedPath!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 已授权路径列表
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            '已授权路径',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _grantedPaths.isEmpty ? null : _clearPermissions,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('清除'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _grantedPaths.isEmpty
                            ? const Center(
                                child: Text(
                                  '暂无已授权的路径\n请先选择一个文件夹',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _grantedPaths.length,
                                itemBuilder: (context, index) {
                                  final path = _grantedPaths[index];
                                  return ListTile(
                                    leading: const Icon(Icons.folder, color: Colors.green),
                                    title: Text(path.split('/').last),
                                    subtitle: Text(
                                      path,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    dense: true,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
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
  runApp(MaterialApp(
    title: 'Android文件选择器演示',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const AndroidFilePickerDemo(),
  ));
}

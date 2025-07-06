import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/permission_diagnostic_service.dart';
import '../../../core/services/permission_service.dart';

/// 权限诊断和修复页面
class PermissionDiagnosticPage extends StatefulWidget {
  const PermissionDiagnosticPage({super.key});

  @override
  State<PermissionDiagnosticPage> createState() => _PermissionDiagnosticPageState();
}

class _PermissionDiagnosticPageState extends State<PermissionDiagnosticPage> {
  PermissionDiagnosticResult? _diagnosticResult;
  bool _isRunningDiagnostic = false;
  bool _isFixing = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunningDiagnostic = true;
    });

    try {
      final result = await PermissionDiagnosticService.runDiagnostic();
      setState(() {
        _diagnosticResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('诊断失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRunningDiagnostic = false;
      });
    }
  }

  Future<void> _autoFix() async {
    setState(() {
      _isFixing = true;
    });

    try {
      final success = await PermissionDiagnosticService.autoFixPermissions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '修复成功' : '修复失败，请手动设置权限'),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }

      // 重新运行诊断
      await _runDiagnostic();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修复过程出错: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isFixing = false;
      });
    }
  }

  void _copyReport() {
    if (_diagnosticResult != null) {
      final report = PermissionDiagnosticService.generateReport(_diagnosticResult!);
      Clipboard.setData(ClipboardData(text: report));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('诊断报告已复制到剪贴板'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限诊断'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunningDiagnostic ? null : _runDiagnostic,
            tooltip: '重新诊断',
          ),
          if (_diagnosticResult != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyReport,
              tooltip: '复制报告',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isRunningDiagnostic) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在诊断权限状态...'),
          ],
        ),
      );
    }

    if (_diagnosticResult == null) {
      return const Center(
        child: Text('诊断失败，请重试'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildPermissionDetails(),
          const SizedBox(height: 16),
          _buildAccessiblePaths(),
          if (_diagnosticResult!.issues.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildIssues(),
          ],
          if (_diagnosticResult!.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRecommendations(),
          ],
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final result = _diagnosticResult!;
    final isHealthy = result.isHealthy;
    
    return Card(
      color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isHealthy ? Icons.check_circle : Icons.error,
              color: isHealthy ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHealthy ? '权限状态正常' : '权限存在问题',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    'Android ${result.androidVersion}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDetails() {
    final result = _diagnosticResult!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '权限详情',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildPermissionItem('基本权限', result.hasBasicPermission),
            _buildPermissionItem('文件访问', result.hasFileAccess),
            _buildPermissionItem('管理存储权限', result.hasManageStoragePermission),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String title, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildAccessiblePaths() {
    final paths = _diagnosticResult!.accessiblePaths;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '可访问路径 (${paths.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (paths.isEmpty)
              const Text('无可访问路径')
            else
              ...paths.map((path) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.folder, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(path, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildIssues() {
    final issues = _diagnosticResult!.issues;
    
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '发现的问题 (${issues.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...issues.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. '),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _diagnosticResult!.recommendations;
    
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '建议操作 (${recommendations.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...recommendations.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. '),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isFixing ? null : _autoFix,
                    icon: _isFixing 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.build),
                    label: Text(_isFixing ? '修复中...' : '自动修复'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => PermissionService.openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('应用设置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

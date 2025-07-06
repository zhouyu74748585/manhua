import 'package:flutter/material.dart';

import '../../../core/services/enhanced_file_picker_service.dart';
import '../../../core/services/library_permission_validator.dart';
import '../../../core/services/permission_service.dart';

/// 权限管理页面
/// 显示应用权限状态，管理已授权路径，提供权限修复功能
class PermissionManagementPage extends StatefulWidget {
  const PermissionManagementPage({super.key});

  @override
  State<PermissionManagementPage> createState() => _PermissionManagementPageState();
}

class _PermissionManagementPageState extends State<PermissionManagementPage> {
  AppPermissionStatus? _permissionStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await LibraryPermissionValidator.checkAppPermissionStatus();
      setState(() {
        _permissionStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载权限状态失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestFilePermission() async {
    try {
      final granted = await PermissionService.requestFilePermission();
      if (granted) {
        await _loadPermissionStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件权限授权成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件权限授权失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('请求权限时发生错误: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addNewPath() async {
    try {
      final path = await EnhancedFilePickerService.pickDirectoryWithPermission(
        context: context,
        dialogTitle: '选择要授权的文件夹',
      );

      if (path != null) {
        await _loadPermissionStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已添加授权路径: $path'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加路径失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllPermissions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有已保存的权限数据吗？\n\n这将删除所有已授权的路径记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PermissionService.clearAllPermissions();
        await _loadPermissionStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已清除所有权限数据'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清除权限数据失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPermissionStatus,
            tooltip: '刷新权限状态',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permissionStatus == null
              ? const Center(child: Text('加载权限状态失败'))
              : _buildPermissionContent(),
    );
  }

  Widget _buildPermissionContent() {
    final status = _permissionStatus!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 权限状态卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      status.hasFilePermission ? Icons.check_circle : Icons.error,
                      color: status.hasFilePermission ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '文件访问权限',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  status.hasFilePermission ? '已授权' : '未授权',
                  style: TextStyle(
                    color: status.hasFilePermission ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!status.hasFilePermission) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _requestFilePermission,
                    child: const Text('请求文件权限'),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 已授权路径
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已授权路径 (${status.grantedPathsCount})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addNewPath,
                      tooltip: '添加新路径',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (status.grantedPaths.isEmpty)
                  const Text(
                    '暂无已授权的路径',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...status.grantedPaths.map((path) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.folder, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                path,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 权限管理操作
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '权限管理',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('打开应用设置'),
                  subtitle: const Text('在系统设置中管理应用权限'),
                  onTap: () => PermissionService.openAppSettings(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.clear_all, color: Colors.red),
                  title: const Text('清除所有权限数据'),
                  subtitle: const Text('删除所有已保存的权限记录'),
                  onTap: _clearAllPermissions,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 权限说明
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '权限说明',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 文件访问权限：用于读取本地漫画文件\n'
                  '• 已授权路径：应用可以访问的文件夹列表\n'
                  '• Android 11+：需要为每个文件夹单独授权\n'
                  '• 权限可能会过期，需要重新授权',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

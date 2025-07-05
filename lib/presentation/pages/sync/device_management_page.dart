import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/sync/device_info.dart';
import '../../providers/sync_providers.dart';

/// 设备管理页面 - 显示可用设备和同步状态
class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState<DeviceManagementPage> createState() =>
      _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage> {
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _startDeviceDiscovery();
  }

  Future<void> _startDeviceDiscovery() async {
    setState(() => _isDiscovering = true);
    try {
      await ref.read(multiDeviceSyncServiceProvider).startDeviceDiscovery();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动设备发现失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDiscovering = false);
      }
    }
  }

  Future<void> _stopDeviceDiscovery() async {
    try {
      await ref
          .read(multiDeviceSyncServiceProvider)
          .stopDeviceDiscovery();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止设备发现失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopDeviceDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(availableDevicesProvider);
    final syncSessionsAsync = ref.watch(activeSyncSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设备管理'),
        actions: [
          IconButton(
            icon: _isDiscovering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isDiscovering ? null : _startDeviceDiscovery,
            tooltip: '刷新设备列表',
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前设备信息卡片
          _buildCurrentDeviceCard(),

          const Divider(),

          // 可用设备列表
          Expanded(
            child: devicesAsync.when(
              data: (devices) => _buildDevicesList(devices),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载设备列表失败: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startDeviceDiscovery,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 活跃同步会话
          syncSessionsAsync.when(
            data: (sessions) => sessions.isNotEmpty
                ? _buildActiveSyncSessions(sessions)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDeviceCard() {
    final currentDevice = ref.watch(currentDeviceProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smartphone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '当前设备',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            currentDevice.when(
              data: (device) => device != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('设备名称: ${device.name}'),
                        Text('设备ID: ${device.id}'),
                        Text('IP地址: ${device.ipAddress}'),
                        Text('端口: ${device.port}'),
                        Text('平台: ${device.platform}'),
                      ],
                    )
                  : const Text('设备信息不可用'),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('获取设备信息失败: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(List<DeviceInfo> devices) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '未发现可用设备',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '确保其他设备已开启多设备共享功能',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startDeviceDiscovery,
              icon: const Icon(Icons.refresh),
              label: const Text('重新扫描'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(DeviceInfo device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            _getDeviceIcon(device.platform),
            color: Colors.white,
          ),
        ),
        title: Text(device.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.ipAddress}:${device.port}'),
            Text('平台: ${device.platform}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleDeviceAction(action, device),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync_library',
              child: ListTile(
                leading: Icon(Icons.library_books),
                title: Text('同步漫画库'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'sync_progress',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('同步阅读进度'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'device_info',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('设备详情'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSyncSessions(List<dynamic> sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活跃同步会话 (${sessions.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...sessions.take(3).map((session) => _buildSyncSessionItem(session)),
          if (sessions.length > 3)
            TextButton(
              onPressed: () {
                // TODO: 导航到同步会话详情页
              },
              child: Text('查看全部 ${sessions.length} 个会话'),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncSessionItem(dynamic session) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '正在同步...', // TODO: 显示实际的同步信息
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.computer;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  void _handleDeviceAction(String action, DeviceInfo device) {
    switch (action) {
      case 'sync_library':
        context.push('/sync/library-selection', extra: device);
        break;
      case 'sync_progress':
        context.push('/sync/progress-selection', extra: device);
        break;
      case 'device_info':
        _showDeviceInfoDialog(device);
        break;
    }
  }

  void _showDeviceInfoDialog(DeviceInfo device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('设备详情 - ${device.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('设备ID', device.id),
            _buildInfoRow('设备名称', device.name),
            _buildInfoRow('IP地址', device.ipAddress),
            _buildInfoRow('端口', device.port.toString()),
            _buildInfoRow('平台', device.platform),
            _buildInfoRow('发现时间', device.lastSeen.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

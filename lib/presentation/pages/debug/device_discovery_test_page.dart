import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/network/device_discovery_service.dart';
import '../../../data/models/sync/device_info.dart';

/// 设备发现测试页面，用于调试设备发现功能
class DeviceDiscoveryTestPage extends ConsumerStatefulWidget {
  const DeviceDiscoveryTestPage({super.key});

  @override
  ConsumerState<DeviceDiscoveryTestPage> createState() => _DeviceDiscoveryTestPageState();
}

class _DeviceDiscoveryTestPageState extends ConsumerState<DeviceDiscoveryTestPage> {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  List<DeviceInfo> _discoveredDevices = [];
  bool _isDiscovering = false;
  bool _isInitialized = false;
  String _statusMessage = '未初始化';
  DeviceInfo? _currentDevice;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      setState(() {
        _statusMessage = '正在初始化...';
      });

      await _discoveryService.initialize();
      _currentDevice = _discoveryService.currentDevice;

      // 监听设备发现
      _discoveryService.devicesStream.listen((devices) {
        if (mounted) {
          setState(() {
            _discoveredDevices = devices;
          });
        }
      });

      setState(() {
        _isInitialized = true;
        _statusMessage = '初始化完成';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: $e';
      });
    }
  }

  Future<void> _startDiscovery() async {
    if (!_isInitialized) return;

    try {
      setState(() {
        _isDiscovering = true;
        _statusMessage = '正在启动设备发现...';
      });

      await _discoveryService.startDiscovery();

      setState(() {
        _statusMessage = '设备发现已启动';
      });
    } catch (e) {
      setState(() {
        _isDiscovering = false;
        _statusMessage = '启动设备发现失败: $e';
      });
    }
  }

  Future<void> _stopDiscovery() async {
    try {
      setState(() {
        _statusMessage = '正在停止设备发现...';
      });

      await _discoveryService.stopDiscovery();

      setState(() {
        _isDiscovering = false;
        _statusMessage = '设备发现已停止';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '停止设备发现失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备发现测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '状态信息',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('状态: $_statusMessage'),
                    Text('已初始化: $_isInitialized'),
                    Text('正在发现: $_isDiscovering'),
                    if (_currentDevice != null) ...[
                      const SizedBox(height: 8),
                      Text('当前设备: ${_currentDevice!.name}'),
                      Text('设备ID: ${_currentDevice!.id}'),
                      Text('平台: ${_currentDevice!.platform}'),
                      Text('IP地址: ${_currentDevice!.ipAddress}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 控制按钮
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isInitialized && !_isDiscovering ? _startDiscovery : null,
                  child: const Text('开始发现'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isDiscovering ? _stopDiscovery : null,
                  child: const Text('停止发现'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _discoveredDevices.clear();
                    });
                  },
                  child: const Text('清空列表'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 发现的设备列表
            Text(
              '发现的设备 (${_discoveredDevices.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _discoveredDevices.isEmpty
                  ? const Center(
                      child: Text('暂无发现的设备'),
                    )
                  : ListView.builder(
                      itemCount: _discoveredDevices.length,
                      itemBuilder: (context, index) {
                        final device = _discoveredDevices[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _getDeviceIcon(device.platform),
                              color: device.isOnline ? Colors.green : Colors.grey,
                            ),
                            title: Text(device.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${device.id}'),
                                Text('平台: ${device.platform}'),
                                Text('IP: ${device.ipAddress}:${device.port}'),
                                Text('最后见到: ${_formatTime(device.lastSeen)}'),
                              ],
                            ),
                            trailing: Icon(
                              device.isOnline ? Icons.circle : Icons.circle_outlined,
                              color: device.isOnline ? Colors.green : Colors.grey,
                              size: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
      default:
        return Icons.device_unknown;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '${difference.inHours}小时前';
    }
  }
}

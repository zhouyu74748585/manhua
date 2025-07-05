import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_providers.dart';

/// 同步设置页面
class SyncSettingsPage extends ConsumerWidget {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(syncSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('同步设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 设备发现设置
          _buildDeviceDiscoveryCard(context, ref, settings),

          const SizedBox(height: 16),

          // 同步选项设置
          _buildSyncOptionsCard(context, ref, settings),

          const SizedBox(height: 16),

          // 冲突解决设置
          _buildConflictResolutionCard(context, ref, settings),

          const SizedBox(height: 16),

          // 网络设置
          _buildNetworkCard(context, ref, settings),

          const SizedBox(height: 16),

          // 安全设置
          _buildSecurityCard(context, ref, settings),

          const SizedBox(height: 16),

          // 高级设置
          _buildAdvancedCard(context, ref, settings),
        ],
      ),
    );
  }

  Widget _buildDeviceDiscoveryCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '设备发现',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('自动发现设备'),
              subtitle: const Text('启动时自动搜索局域网内的其他设备'),
              value: settings.autoDiscovery,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateAutoDiscovery(value);
              },
            ),
            ListTile(
              title: const Text('发现超时'),
              subtitle: Text('${settings.discoveryTimeout}秒'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showTimeoutDialog(context, ref, settings.discoveryTimeout),
            ),
            ListTile(
              title: const Text('设备名称'),
              subtitle: Text(settings.deviceName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showDeviceNameDialog(context, ref, settings.deviceName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptionsCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同步选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('同步封面图片'),
              subtitle: const Text('同步时包含漫画封面图片'),
              value: settings.syncCovers,
              onChanged: (value) {
                ref.read(syncSettingsProvider.notifier).updateSyncCovers(value);
              },
            ),
            SwitchListTile(
              title: const Text('同步缩略图'),
              subtitle: const Text('同步时包含页面缩略图'),
              value: settings.syncThumbnails,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateSyncThumbnails(value);
              },
            ),
            SwitchListTile(
              title: const Text('同步原始文件'),
              subtitle: const Text('同步时包含原始漫画文件'),
              value: settings.syncOriginalFiles,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateSyncOriginalFiles(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictResolutionCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '冲突解决',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('冲突解决策略'),
              subtitle:
                  Text(_getConflictStrategyText(settings.conflictResolution)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConflictStrategyDialog(
                  context, ref, settings.conflictResolution),
            ),
            SwitchListTile(
              title: const Text('自动解决冲突'),
              subtitle: const Text('使用选定策略自动解决冲突'),
              value: settings.autoResolveConflicts,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateAutoResolveConflicts(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '网络设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('连接超时'),
              subtitle: Text('${settings.connectionTimeout}秒'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimeoutDialog(
                  context, ref, settings.connectionTimeout,
                  isConnection: true),
            ),
            ListTile(
              title: const Text('传输超时'),
              subtitle: Text('${settings.transferTimeout}秒'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTimeoutDialog(
                  context, ref, settings.transferTimeout,
                  isTransfer: true),
            ),
            SwitchListTile(
              title: const Text('仅WiFi同步'),
              subtitle: const Text('仅在WiFi网络下进行同步'),
              value: settings.wifiOnly,
              onChanged: (value) {
                ref.read(syncSettingsProvider.notifier).updateWifiOnly(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '安全设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('需要确认'),
              subtitle: const Text('接收同步请求时需要手动确认'),
              value: settings.requireConfirmation,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateRequireConfirmation(value);
              },
            ),
            SwitchListTile(
              title: const Text('启用加密'),
              subtitle: const Text('传输数据时使用加密'),
              value: settings.enableEncryption,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateEnableEncryption(value);
              },
            ),
            ListTile(
              title: const Text('受信任设备'),
              subtitle: Text('${settings.trustedDevices.length} 台设备'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTrustedDevicesDialog(
                  context, ref, settings.trustedDevices),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCard(
      BuildContext context, WidgetRef ref, SyncSettingsData settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '高级设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('最大并发连接'),
              subtitle: Text('${settings.maxConcurrentConnections} 个连接'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConcurrentConnectionsDialog(
                  context, ref, settings.maxConcurrentConnections),
            ),
            ListTile(
              title: const Text('重试次数'),
              subtitle: Text('${settings.retryAttempts} 次'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRetryAttemptsDialog(
                  context, ref, settings.retryAttempts),
            ),
            ListTile(
              title: const Text('分批处理大小'),
              subtitle: Text('${settings.batchSize ?? 50} 项/批'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showBatchSizeDialog(context, ref, settings.batchSize ?? 50),
            ),
            SwitchListTile(
              title: const Text('启用连接池'),
              subtitle: const Text('复用HTTP连接以提升性能'),
              value: settings.enableConnectionPool ?? true,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateConnectionPoolEnabled(value);
              },
            ),
            SwitchListTile(
              title: const Text('详细日志'),
              subtitle: const Text('记录详细的同步日志'),
              value: settings.verboseLogging,
              onChanged: (value) {
                ref
                    .read(syncSettingsProvider.notifier)
                    .updateVerboseLogging(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getConflictStrategyText(ConflictResolutionStrategy strategy) {
    switch (strategy) {
      case ConflictResolutionStrategy.latestWins:
        return '最新优先';
      case ConflictResolutionStrategy.localWins:
        return '本地优先';
      case ConflictResolutionStrategy.remoteWins:
        return '远程优先';
      case ConflictResolutionStrategy.manual:
        return '手动解决';
      case ConflictResolutionStrategy.manualResolve:
        return '手动解决';
      case ConflictResolutionStrategy.sourceWins:
        return '源设备优先';
      case ConflictResolutionStrategy.targetWins:
        return '目标设备优先';
    }
  }

  void _showTimeoutDialog(BuildContext context, WidgetRef ref, int currentValue,
      {bool isConnection = false, bool isTransfer = false}) {
    // TODO: 实现超时设置对话框
  }

  void _showDeviceNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    // TODO: 实现设备名称设置对话框
  }

  void _showConflictStrategyDialog(BuildContext context, WidgetRef ref,
      ConflictResolutionStrategy currentStrategy) {
    // TODO: 实现冲突解决策略选择对话框
  }

  void _showTrustedDevicesDialog(
      BuildContext context, WidgetRef ref, List<String> trustedDevices) {
    // TODO: 实现受信任设备管理对话框
  }

  void _showConcurrentConnectionsDialog(
      BuildContext context, WidgetRef ref, int currentValue) {
    // TODO: 实现并发连接数设置对话框
  }

  void _showRetryAttemptsDialog(
      BuildContext context, WidgetRef ref, int currentValue) {
    // TODO: 实现重试次数设置对话框
  }

  void _showBatchSizeDialog(
      BuildContext context, WidgetRef ref, int currentValue) {
    // TODO: 实现分批处理大小设置对话框
    // 建议范围：10-200，默认50
    // 较小的批次大小可以提供更频繁的进度更新，但可能增加网络开销
    // 较大的批次大小可以提高传输效率，但进度更新较少
  }
}

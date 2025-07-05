import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/library.dart';
import '../../../data/models/sync/device_info.dart';
import '../../../data/models/sync/sync_session.dart';
import '../../providers/library_provider.dart';
import '../../providers/sync_providers.dart';

/// 漫画库同步页面 - 选择要同步的库和同步选项
class LibrarySyncPage extends ConsumerStatefulWidget {
  final DeviceInfo targetDevice;

  const LibrarySyncPage({
    super.key,
    required this.targetDevice,
  });

  @override
  ConsumerState<LibrarySyncPage> createState() => _LibrarySyncPageState();
}

class _LibrarySyncPageState extends ConsumerState<LibrarySyncPage> {
  final Set<String> _selectedLibraryIds = {};
  SyncDirection _syncDirection = SyncDirection.bidirectional;
  bool _syncThumbnails = true;
  bool _syncMetadata = true;
  bool _syncProgress = true;
  bool _resolveConflictsAutomatically = true;

  @override
  Widget build(BuildContext context) {
    final librariesAsync = ref.watch(allLibrariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('同步到 ${widget.targetDevice.name}'),
        actions: [
          TextButton(
            onPressed: _selectedLibraryIds.isEmpty ? null : _startSync,
            child: const Text('开始同步'),
          ),
        ],
      ),
      body: librariesAsync.when(
        data: (libraries) => _buildSyncOptions(libraries),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载漫画库失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allLibrariesProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncOptions(List<MangaLibrary> libraries) {
    final enabledLibraries = libraries.where((lib) => lib.isEnabled).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 目标设备信息
          _buildTargetDeviceCard(),

          const SizedBox(height: 24),

          // 选择漫画库
          _buildLibrarySelection(enabledLibraries),

          const SizedBox(height: 24),

          // 同步方向选择
          _buildSyncDirectionSelection(),

          const SizedBox(height: 24),

          // 同步选项
          _buildSyncOptionsSection(),

          const SizedBox(height: 24),

          // 冲突解决选项
          _buildConflictResolutionSection(),

          const SizedBox(height: 32),

          // 开始同步按钮
          _buildSyncButton(),
        ],
      ),
    );
  }

  Widget _buildTargetDeviceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '目标设备',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('设备名称: ${widget.targetDevice.name}'),
            Text('IP地址: ${widget.targetDevice.ipAddress}'),
            Text('平台: ${widget.targetDevice.platform}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrarySelection(List<MangaLibrary> libraries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '选择漫画库',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedLibraryIds.length == libraries.length) {
                        _selectedLibraryIds.clear();
                      } else {
                        _selectedLibraryIds
                            .addAll(libraries.map((lib) => lib.id));
                      }
                    });
                  },
                  child: Text(_selectedLibraryIds.length == libraries.length
                      ? '取消全选'
                      : '全选'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (libraries.isEmpty)
              const Text('没有可用的漫画库')
            else
              ...libraries.map((library) => _buildLibraryTile(library)),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTile(MangaLibrary library) {
    final isSelected = _selectedLibraryIds.contains(library.id);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (selected) {
        setState(() {
          if (selected == true) {
            _selectedLibraryIds.add(library.id);
          } else {
            _selectedLibraryIds.remove(library.id);
          }
        });
      },
      title: Text(library.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('路径: ${library.path}'),
          Text('类型: ${library.type.displayName}'),
          Text('漫画数量: ${library.mangaCount}'),
        ],
      ),
      secondary: Icon(
        library.type == LibraryType.local
            ? Icons.folder
            : library.type == LibraryType.network
                ? Icons.cloud
                : Icons.cloud_queue,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  Widget _buildSyncDirectionSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同步方向',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<SyncDirection>(
              value: SyncDirection.bidirectional,
              groupValue: _syncDirection,
              onChanged: (value) => setState(() => _syncDirection = value!),
              title: const Text('双向同步'),
              subtitle: const Text('同步两个设备之间的所有差异'),
            ),
            RadioListTile<SyncDirection>(
              value: SyncDirection.toRemote,
              groupValue: _syncDirection,
              onChanged: (value) => setState(() => _syncDirection = value!),
              title: const Text('发送到目标设备'),
              subtitle: const Text('只将本地数据发送到目标设备'),
            ),
            RadioListTile<SyncDirection>(
              value: SyncDirection.fromRemote,
              groupValue: _syncDirection,
              onChanged: (value) => setState(() => _syncDirection = value!),
              title: const Text('从目标设备接收'),
              subtitle: const Text('只从目标设备接收数据'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同步选项',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _syncThumbnails,
              onChanged: (value) => setState(() => _syncThumbnails = value),
              title: const Text('同步缩略图'),
              subtitle: const Text('包含漫画封面和页面缩略图'),
            ),
            SwitchListTile(
              value: _syncMetadata,
              onChanged: (value) => setState(() => _syncMetadata = value),
              title: const Text('同步元数据'),
              subtitle: const Text('包含标题、作者、标签等信息'),
            ),
            SwitchListTile(
              value: _syncProgress,
              onChanged: (value) => setState(() => _syncProgress = value),
              title: const Text('同步阅读进度'),
              subtitle: const Text('包含阅读位置和收藏状态'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictResolutionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '冲突解决',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _resolveConflictsAutomatically,
              onChanged: (value) =>
                  setState(() => _resolveConflictsAutomatically = value),
              title: const Text('自动解决冲突'),
              subtitle: const Text('使用最新数据自动解决冲突，否则需要手动选择'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectedLibraryIds.isEmpty ? null : _startSync,
        icon: const Icon(Icons.sync),
        label: Text('开始同步 (${_selectedLibraryIds.length} 个库)'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _startSync() async {
    // 显示确认对话框
    final confirmed = await _showSyncConfirmationDialog();
    if (!confirmed) return;

    try {
      // 开始同步
      final syncService = ref.read(syncCoordinatorServiceProvider);
      final result = await syncService.syncLibrariesWithDevice(
        targetDevice: widget.targetDevice,
        libraryIds: _selectedLibraryIds.toList(),
        direction: _syncDirection,
        resolveConflictsAutomatically: _resolveConflictsAutomatically,
      );

      if (mounted) {
        // 导航到同步进度页面
        context.pushReplacement('/sync/progress', extra: {
          'sessionId': result.sessionId,
          'targetDevice': widget.targetDevice,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动同步失败: $e')),
        );
      }
    }
  }

  Future<bool> _showSyncConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认同步'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('即将同步 ${_selectedLibraryIds.length} 个漫画库到设备：'),
                Text('• ${widget.targetDevice.name}'),
                const SizedBox(height: 16),
                Text('同步方向: ${_getSyncDirectionText()}'),
                if (_syncThumbnails) const Text('• 包含缩略图'),
                if (_syncMetadata) const Text('• 包含元数据'),
                if (_syncProgress) const Text('• 包含阅读进度'),
                const SizedBox(height: 16),
                const Text(
                  '此操作可能需要较长时间，确定要继续吗？',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确认同步'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getSyncDirectionText() {
    switch (_syncDirection) {
      case SyncDirection.bidirectional:
        return '双向同步';
      case SyncDirection.toRemote:
        return '发送到目标设备';
      case SyncDirection.fromRemote:
        return '从目标设备接收';
      case SyncDirection.upload:
        return '上传到目标设备';
      case SyncDirection.download:
        return '从目标设备下载';
    }
  }
}

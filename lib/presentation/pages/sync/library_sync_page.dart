import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/library.dart';
import '../../../data/models/manga.dart';
import '../../../data/models/sync/device_info.dart';
import '../../../data/models/sync/sync_session.dart';
import '../../providers/library_provider.dart';
import '../../providers/manga_provider.dart';
import '../../providers/sync_providers.dart';

/// 漫画库同步页面 - 选择要同步的库和同步选项
class LibrarySyncPage extends ConsumerStatefulWidget {
  final DeviceInfo targetDevice;
  final String? preSelectedLibraryId; // 预选择的漫画库ID

  const LibrarySyncPage({
    super.key,
    required this.targetDevice,
    this.preSelectedLibraryId,
  });

  @override
  ConsumerState<LibrarySyncPage> createState() => _LibrarySyncPageState();
}

class _LibrarySyncPageState extends ConsumerState<LibrarySyncPage> {
  final Set<String> _selectedLibraryIds = {};
  final Map<String, Set<String>> _selectedMangaIds = {}; // 库ID -> 选中的漫画ID集合
  SyncDirection _syncDirection = SyncDirection.toRemote; // 默认只发送到目标设备
  bool _syncThumbnails = true;
  bool _syncMetadata = true;
  bool _syncProgress = true;

  @override
  void initState() {
    super.initState();
    // 如果有预选择的漫画库，自动选中
    if (widget.preSelectedLibraryId != null) {
      _selectedLibraryIds.add(widget.preSelectedLibraryId!);
    }
  }

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

          // 选择漫画
          _buildMangaSelection(enabledLibraries),

          const SizedBox(height: 24),

          // 同步提示信息
          _buildSyncDirectionInfo(),

          const SizedBox(height: 24),

          // 同步选项
          _buildSyncOptionsSection(),

          const SizedBox(height: 24),

          // 冲突解决提示
          _buildConflictResolutionInfo(),

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

  Widget _buildMangaSelection(List<MangaLibrary> libraries) {
    // 如果有预选择的库，只显示该库的漫画选择
    if (widget.preSelectedLibraryId != null) {
      final preSelectedLibrary = libraries.firstWhere(
        (lib) => lib.id == widget.preSelectedLibraryId,
        orElse: () => throw StateError('预选择的漫画库不存在'),
      );
      return _buildSingleLibraryMangaSelection(preSelectedLibrary);
    }

    // 否则显示所有库的选择界面
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择要同步的漫画',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '请先选择漫画库，然后选择要同步的具体漫画',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (libraries.isEmpty)
              const Text('没有可用的漫画库')
            else
              ...libraries
                  .map((library) => _buildLibraryExpansionTile(library)),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleLibraryMangaSelection(MangaLibrary library) {
    final mangaAsync = ref.watch(mangaByLibraryProvider(library.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        library.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '选择要同步的漫画',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            mangaAsync.when(
              data: (mangaList) => _buildMangaList(library.id, mangaList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加载漫画失败: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryExpansionTile(MangaLibrary library) {
    final isSelected = _selectedLibraryIds.contains(library.id);
    final mangaAsync = ref.watch(mangaByLibraryProvider(library.id));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedLibraryIds.add(library.id);
              } else {
                _selectedLibraryIds.remove(library.id);
                _selectedMangaIds.remove(library.id);
              }
            });
          },
        ),
        title: Text(library.name),
        subtitle: Text(library.path),
        children: [
          if (isSelected)
            mangaAsync.when(
              data: (mangaList) => _buildMangaList(library.id, mangaList),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载漫画失败: $error'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMangaList(String libraryId, List<Manga> mangaList) {
    final selectedMangaIds = _selectedMangaIds[libraryId] ?? <String>{};

    if (mangaList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('该库中没有漫画'),
      );
    }

    return Column(
      children: [
        // 全选/取消全选按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    if (selectedMangaIds.length == mangaList.length) {
                      _selectedMangaIds[libraryId] = <String>{};
                    } else {
                      _selectedMangaIds[libraryId] =
                          mangaList.map((m) => m.id).toSet();
                    }
                  });
                },
                child: Text(selectedMangaIds.length == mangaList.length
                    ? '取消全选'
                    : '全选'),
              ),
              const Spacer(),
              Text('已选择 ${selectedMangaIds.length} / ${mangaList.length}'),
            ],
          ),
        ),
        // 漫画列表
        ...mangaList.map((manga) => _buildMangaTile(libraryId, manga)),
      ],
    );
  }

  Widget _buildMangaTile(String libraryId, Manga manga) {
    final selectedMangaIds = _selectedMangaIds[libraryId] ?? <String>{};
    final isSelected = selectedMangaIds.contains(manga.id);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (selected) {
        setState(() {
          final currentSelected = _selectedMangaIds[libraryId] ?? <String>{};
          if (selected == true) {
            currentSelected.add(manga.id);
          } else {
            currentSelected.remove(manga.id);
          }
          _selectedMangaIds[libraryId] = currentSelected;
        });
      },
      title: Text(manga.title),
      subtitle: Text('${manga.totalPages} 页'),
      secondary: manga.coverPath?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                manga.coverPath!,
                width: 40,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.book, size: 40),
              ),
            )
          : const Icon(Icons.book, size: 40),
    );
  }

  Widget _buildSyncDirectionInfo() {
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.send, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '发送到目标设备',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '将选中的漫画数据发送到目标设备，目标设备将接收并保存这些数据',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildConflictResolutionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '冲突解决策略',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_fix_high, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '自动解决冲突',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '当发现数据冲突时，系统将自动选择最新的数据版本，无需手动干预',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    final totalSelectedManga = _selectedMangaIds.values
        .fold<int>(0, (sum, mangaIds) => sum + mangaIds.length);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: totalSelectedManga == 0 ? null : _startSync,
        icon: const Icon(Icons.sync),
        label: Text('开始同步 ($totalSelectedManga 部漫画)'),
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
        resolveConflictsAutomatically: true, // 自动解决冲突
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

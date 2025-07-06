import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/sync/device_info.dart';
import '../../../data/models/manga.dart';
import '../../../data/models/reading_progress.dart';
import '../../providers/manga_provider.dart';
import '../../providers/sync_providers.dart';

/// 阅读进度同步页面 - 选择要同步的漫画进度
class ProgressSyncPage extends ConsumerStatefulWidget {
  final DeviceInfo targetDevice;
  final String? specificMangaId; // 如果指定了特定漫画ID，只同步该漫画的进度

  const ProgressSyncPage({
    super.key,
    required this.targetDevice,
    this.specificMangaId,
  });

  @override
  ConsumerState<ProgressSyncPage> createState() => _ProgressSyncPageState();
}

class _ProgressSyncPageState extends ConsumerState<ProgressSyncPage> {
  final Set<String> _selectedMangaIds = {};
  bool _useLatestWins = true;
  bool _syncFavorites = true;
  bool _syncBookmarks = true;

  @override
  void initState() {
    super.initState();
    // 如果指定了特定漫画，自动选中
    if (widget.specificMangaId != null) {
      _selectedMangaIds.add(widget.specificMangaId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果是特定漫画同步，直接显示确认界面
    if (widget.specificMangaId != null) {
      return _buildSpecificMangaSyncPage();
    }

    // 否则显示漫画列表选择界面
    return _buildMangaListSyncPage();
  }

  Widget _buildSpecificMangaSyncPage() {
    final mangaAsync = ref.watch(mangaDetailProvider(widget.specificMangaId!));
    final progressAsync = ref.watch(mangaProgressProvider(widget.specificMangaId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('同步阅读进度'),
        actions: [
          TextButton(
            onPressed: _startProgressSync,
            child: const Text('开始同步'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标设备信息
            _buildTargetDeviceCard(),
            
            const SizedBox(height: 24),
            
            // 漫画信息
            mangaAsync.when(
              data: (manga) => manga != null 
                  ? _buildMangaInfoCard(manga, progressAsync.value)
                  : const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('漫画不存在'),
                      ),
                    ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('加载漫画信息失败: $error'),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 同步选项
            _buildSyncOptionsCard(),
            
            const SizedBox(height: 32),
            
            // 开始同步按钮
            _buildSyncButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMangaListSyncPage() {
    // TODO: 实现漫画列表选择界面
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择要同步的漫画'),
      ),
      body: const Center(
        child: Text('漫画列表同步功能待实现'),
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

  Widget _buildMangaInfoCard(Manga manga, ReadingProgress? progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '漫画信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 漫画封面
                if (manga.coverPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      manga.coverPath!,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 40),
                  ),
                
                const SizedBox(width: 16),
                
                // 漫画详情
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (manga.author != null) ...[
                        const SizedBox(height: 4),
                        Text('作者: ${manga.author}'),
                      ],
                      const SizedBox(height: 8),
                      Text('总页数: ${manga.totalPages}'),
                      if (progress != null) ...[
                        Text('当前页: ${progress.currentPage}'),
                        Text('进度: ${(progress.progressPercentage * 100).toStringAsFixed(1)}%'),
                        Text('最后阅读: ${_formatDateTime(progress.lastReadAt)}'),
                      ] else
                        const Text('尚未开始阅读'),
                      const SizedBox(height: 8),
                      if (manga.isFavorite)
                        const Chip(
                          label: Text('已收藏'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptionsCard() {
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
              value: _useLatestWins,
              onChanged: (value) => setState(() => _useLatestWins = value),
              title: const Text('使用最新进度'),
              subtitle: const Text('当存在冲突时，自动选择最新的阅读进度'),
            ),
            SwitchListTile(
              value: _syncFavorites,
              onChanged: (value) => setState(() => _syncFavorites = value),
              title: const Text('同步收藏状态'),
              subtitle: const Text('包含漫画的收藏状态'),
            ),
            SwitchListTile(
              value: _syncBookmarks,
              onChanged: (value) => setState(() => _syncBookmarks = value),
              title: const Text('同步书签'),
              subtitle: const Text('包含页面书签和笔记'),
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
        onPressed: _startProgressSync,
        icon: const Icon(Icons.sync),
        label: const Text('开始同步阅读进度'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _startProgressSync() async {
    // 显示确认对话框
    final confirmed = await _showSyncConfirmationDialog();
    if (!confirmed) return;

    try {
      final syncService = ref.read(syncCoordinatorServiceProvider);
      
      if (widget.specificMangaId != null) {
        // 同步特定漫画的进度
        final result = await syncService.syncReadingProgress(
          targetDevice: widget.targetDevice,
          mangaId: widget.specificMangaId!,
          useLatestWins: _useLatestWins,
        );

        if (mounted) {
          if (result.status.name == 'completed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('阅读进度同步完成')),
            );
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('同步失败: ${result.errorMessage ?? "未知错误"}')),
            );
          }
        }
      } else {
        // 批量同步选中的漫画进度
        final result = await syncService.syncMultipleReadingProgress(
          targetDevice: widget.targetDevice,
          mangaIds: _selectedMangaIds.toList(),
          useLatestWins: _useLatestWins,
          syncFavorites: _syncFavorites,
          syncBookmarks: _syncBookmarks,
        );

        if (mounted) {
          // 导航到同步进度页面
          context.pushReplacement('/sync/progress', extra: {
            'sessionId': result.sessionId,
            'targetDevice': widget.targetDevice,
          });
        }
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
            Text('即将同步阅读进度到设备：'),
            Text('• ${widget.targetDevice.name}'),
            const SizedBox(height: 16),
            if (_useLatestWins) const Text('• 使用最新进度解决冲突'),
            if (_syncFavorites) const Text('• 包含收藏状态'),
            if (_syncBookmarks) const Text('• 包含书签信息'),
            const SizedBox(height: 16),
            const Text(
              '确定要继续吗？',
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
    ) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// 存储设置页面
class StorageSettingsPage extends ConsumerStatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  ConsumerState<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<StorageSettingsPage> {
  String? _cacheDirectory;
  int _cacheSize = 0;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();
      
      setState(() {
        _cacheDirectory = tempDir.path;
      });

      await _calculateCacheSize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取缓存信息失败: $e')),
        );
      }
    }
  }

  Future<void> _calculateCacheSize() async {
    if (_isCalculating) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      int totalSize = 0;
      
      // 计算临时目录大小
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        totalSize += await _calculateDirectorySize(tempDir);
      }

      // 计算应用缓存目录大小
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/cache');
      if (await cacheDir.exists()) {
        totalSize += await _calculateDirectorySize(cacheDir);
      }

      setState(() {
        _cacheSize = totalSize;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('计算缓存大小失败: $e')),
        );
      }
    }
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // 忽略权限错误等
    }
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('存储设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateCacheSize,
            tooltip: '刷新缓存信息',
          ),
        ],
      ),
      body: ListView(
        children: [
          // 缓存信息
          _buildSectionHeader(context, '缓存信息'),
          _buildCacheInfoSection(),

          const Divider(),

          // 缓存管理
          _buildSectionHeader(context, '缓存管理'),
          _buildCacheManagementSection(),

          const Divider(),

          // 存储位置
          _buildSectionHeader(context, '存储位置'),
          _buildStorageLocationSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCacheInfoSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('缓存大小'),
          subtitle: _isCalculating 
              ? const Text('计算中...')
              : Text(_formatBytes(_cacheSize)),
          trailing: _isCalculating 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _calculateCacheSize,
                ),
        ),
        ListTile(
          leading: const Icon(Icons.folder),
          title: const Text('缓存目录'),
          subtitle: Text(_cacheDirectory ?? '获取中...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _cacheDirectory != null ? () => _showCacheDirectoryDialog() : null,
        ),
      ],
    );
  }

  Widget _buildCacheManagementSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.clear_all),
          title: const Text('清除图片缓存'),
          subtitle: const Text('清除所有漫画图片缓存'),
          onTap: () => _showClearCacheDialog('图片缓存'),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('清除缩略图缓存'),
          subtitle: const Text('清除所有漫画缩略图缓存'),
          onTap: () => _showClearCacheDialog('缩略图缓存'),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: const Text('清除所有缓存'),
          subtitle: const Text('清除所有应用缓存数据'),
          onTap: () => _showClearCacheDialog('所有缓存'),
        ),
      ],
    );
  }

  Widget _buildStorageLocationSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('下载目录'),
          subtitle: const Text('/storage/emulated/0/Download/MangaReader'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 设置下载目录
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('下载目录设置功能开发中')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('备份目录'),
          subtitle: const Text('/storage/emulated/0/MangaReader/backup'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 设置备份目录
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('备份目录设置功能开发中')),
            );
          },
        ),
      ],
    );
  }

  void _showCacheDirectoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存目录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前缓存目录:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _cacheDirectory ?? '',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '注意: 缓存目录由系统管理，无法手动修改。',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(String cacheType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清除$cacheType'),
        content: Text('确定要清除$cacheType吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache(cacheType);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(String cacheType) async {
    try {
      // 显示进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在清除缓存...'),
            ],
          ),
        ),
      );

      // 执行清除操作
      await _performClearCache(cacheType);

      // 关闭进度对话框
      if (mounted) Navigator.of(context).pop();

      // 重新计算缓存大小
      await _calculateCacheSize();

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$cacheType清除成功')),
        );
      }
    } catch (e) {
      // 关闭进度对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除$cacheType失败: $e')),
        );
      }
    }
  }

  Future<void> _performClearCache(String cacheType) async {
    switch (cacheType) {
      case '图片缓存':
        await _clearImageCache();
        break;
      case '缩略图缓存':
        await _clearThumbnailCache();
        break;
      case '所有缓存':
        await _clearAllCache();
        break;
    }
  }

  Future<void> _clearImageCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageCache = Directory('${appDir.path}/cache/images');
    if (await imageCache.exists()) {
      await imageCache.delete(recursive: true);
    }
  }

  Future<void> _clearThumbnailCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailCache = Directory('${appDir.path}/cache/thumbnails');
    if (await thumbnailCache.exists()) {
      await thumbnailCache.delete(recursive: true);
    }
  }

  Future<void> _clearAllCache() async {
    // 清除临时目录
    final tempDir = await getTemporaryDirectory();
    if (await tempDir.exists()) {
      await for (final entity in tempDir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (e) {
          // 忽略删除失败的文件
        }
      }
    }

    // 清除应用缓存目录
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/cache');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}

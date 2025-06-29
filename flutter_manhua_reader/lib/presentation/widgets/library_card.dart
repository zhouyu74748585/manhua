import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/library.dart';
import '../../providers/library_provider.dart';
import 'add_library_dialog.dart';

class LibraryCard extends ConsumerWidget {
  final MangaLibrary library;
  
  const LibraryCard({
    super.key,
    required this.library,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanStatus = ref.watch(scanStatusProvider);
    final isScanning = scanStatus.isScanning(library.id);
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        library.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: library.isEnabled 
                              ? null 
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '路径: ${library.path}\n'
                        '类型: ${library.type.displayName}\n'
                        '漫画数量: ${library.mangaCount}\n'
                        '上次扫描: ${library.lastScanAt != null ? _formatDateTime(library.lastScanAt!) : '从未扫描'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: library.isEnabled 
                              ? null 
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: library.isEnabled,
                      onChanged: (_) => _handleToggleEnabled(ref),
                    ),
                    const Text('启用'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('扫描'),
                  onPressed: library.isEnabled && !isScanning
                      ? () => _handleScan(ref)
                      : null,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _handleEdit(context),
                  tooltip: '编辑',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _handleDelete(context, ref),
                  tooltip: '删除',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  Future<void> _handleScan(WidgetRef ref) async {
    try {
      ref.read(scanStatusProvider.notifier).setScanningStatus(library.id, true);
      await ref.read(libraryNotifierProvider.notifier).scanLibrary(library.id);
      
      // 显示成功消息
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('库 "${library.name}" 扫描完成'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 显示错误消息
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('扫描失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(scanStatusProvider.notifier).setScanningStatus(library.id, false);
    }
  }
  
  void _handleEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddLibraryDialog(library: library),
    );
  }
  
  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除漫画库 "${library.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(libraryNotifierProvider.notifier).deleteLibrary(library.id);
    }
  }
  
  Future<void> _handleToggleEnabled(WidgetRef ref) async {
    await ref.read(libraryNotifierProvider.notifier).toggleLibraryEnabled(library.id);
  }
}
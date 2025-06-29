import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../widgets/library_card.dart';
import '../widgets/add_library_dialog.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librariesAsync = ref.watch(libraryNotifierProvider);
    final scanStatus = ref.watch(scanStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画库管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: scanStatus.values.any((isScanning) => isScanning)
                ? null
                : () => _scanAllLibraries(ref),
            tooltip: '扫描所有库',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLibraryDialog(context),
            tooltip: '添加库',
          ),
        ],
      ),
      body: librariesAsync.when(
        data: (libraries) {
          if (libraries.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(libraryNotifierProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: libraries.length,
              itemBuilder: (context, index) {
                final library = libraries[index];
                return LibraryCard(library: library);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(context, error, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLibraryDialog(context),
        tooltip: '添加漫画库',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有漫画库',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加你的第一个漫画库',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLibraryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('添加漫画库'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(libraryNotifierProvider.future),
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  void _showAddLibraryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddLibraryDialog(),
    );
  }
  
  Future<void> _scanAllLibraries(WidgetRef ref) async {
    try {
      await ref.read(libraryNotifierProvider.notifier).scanAllLibraries();
      
      // 显示成功消息
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(
            content: Text('所有库扫描完成'),
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
    }
  }
}
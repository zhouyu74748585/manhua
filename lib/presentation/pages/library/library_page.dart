import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../widgets/library/library_card.dart';
import '../../widgets/library/add_library_dialog.dart';
import '../../../data/models/library.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librariesAsync = ref.watch(allLibrariesProvider);
    final totalStatsAsync = ref.watch(totalStatsProvider);
    final scanState = ref.watch(libraryScanStateProvider);
    final libraryActions = ref.read(libraryActionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画库管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLibraryDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => libraryActions.refreshAllLibraries(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息卡片
          _buildStatsCard(totalStatsAsync),
          const SizedBox(height: 16),
          // 漫画库列表
          Expanded(
            child: librariesAsync.when(
              data: (libraries) =>
                  _buildLibraryList(context, libraries, scanState, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(allLibrariesProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AsyncValue<Map<String, int>> statsAsync) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  '漫画库', stats['totalLibraries'] ?? 0, Icons.library_books),
              _buildStatItem('漫画数量', stats['totalManga'] ?? 0, Icons.book),
            ],
          ),
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 60,
            child: Center(child: Text('统计信息加载失败')),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLibraryList(BuildContext context, List<MangaLibrary> libraries,
      Map<String, bool> scanState, WidgetRef ref) {
    if (libraries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '还没有漫画库',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角的 + 按钮添加第一个漫画库',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddLibraryDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('添加漫画库'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: libraries.length,
      itemBuilder: (context, index) {
        final library = libraries[index];
        final isScanning = scanState[library.id] ?? false;

        return LibraryCard(
          library: library,
          isScanning: isScanning,
          onToggleEnabled: (enabled) =>
              _toggleLibraryEnabled(ref, library, enabled),
          onScan: () => _scanLibrary(context, ref, library.id),
          onEdit: () => _editLibrary(context, ref, library),
          onDelete: () => _deleteLibrary(context, ref, library),
        );
      },
    );
  }

  void _showAddLibraryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddLibraryDialog(
        onAdd: (library) =>
            ref.read(libraryActionsProvider.notifier).addLibrary(library),
      ),
    );
  }

  void _toggleLibraryEnabled(
      WidgetRef ref, MangaLibrary library, bool enabled) {
    final updatedLibrary = library.copyWith(isEnabled: enabled);
    ref.read(libraryActionsProvider.notifier).updateLibrary(updatedLibrary);
  }

  void _scanLibrary(
      BuildContext context, WidgetRef ref, String libraryId) async {
    final scanStateNotifier = ref.read(libraryScanStateProvider.notifier);
    final libraryActions = ref.read(libraryActionsProvider.notifier);

    try {
      scanStateNotifier.setScanningState(libraryId, true);
      await libraryActions.scanLibrary(libraryId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('扫描完成')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描失败: $e')),
        );
      }
    } finally {
      scanStateNotifier.setScanningState(libraryId, false);
    }
  }

  void _editLibrary(BuildContext context, WidgetRef ref, MangaLibrary library) {
    showDialog(
      context: context,
      builder: (context) => AddLibraryDialog(
        library: library,
        onAdd: (updatedLibrary) => ref
            .read(libraryActionsProvider.notifier)
            .updateLibrary(updatedLibrary),
      ),
    );
  }

  void _deleteLibrary(
      BuildContext context, WidgetRef ref, MangaLibrary library) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除漫画库'),
        content:
            Text('确定要删除漫画库 "${library.name}" 吗？\n\n此操作不会删除实际文件，只会从应用中移除该库。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(libraryActionsProvider.notifier)
                  .deleteLibrary(library.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除漫画库 "${library.name}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

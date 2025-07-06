import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/privacy_service.dart';
import '../../../data/models/library.dart';
import '../../providers/library_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../widgets/library/add_library_dialog.dart';
import '../../widgets/library/library_card.dart';
import '../../widgets/library/library_settings_dialog.dart';
import '../../widgets/privacy/unified_password_dialog.dart';

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
      AsyncValue<Map<String, bool>> scanStateAsync, WidgetRef ref) {
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
        final scanState = scanStateAsync.valueOrNull ?? {};
        final isScanning =
            library.isScanning || (scanState[library.id] ?? false);

        return LibraryCard(
          library: library,
          isScanning: isScanning,
          onAccessGranted: () {
            // 隐私验证通过后的回调
            print('隐私验证通过，允许访问: ${library.name}');
          },
          onToggleEnabled: (enabled) =>
              _toggleLibraryEnabled(context, ref, library, enabled),
          onScan: () => _scanLibrary(context, ref, library.id),
          onEdit: () => _editLibrary(context, ref, library),
          onDelete: () => _deleteLibrary(context, ref, library),
          onSettings: () => _showLibrarySettings(context, ref, library),
          onPrivacySettings: () => _showPrivacySettings(context, ref, library),
          onSync: () => _showLibrarySyncOptions(context, library),
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

  void _toggleLibraryEnabled(BuildContext context, WidgetRef ref,
      MangaLibrary library, bool enabled) async {
    // 如果是隐私库且要激活，需要验证身份
    if (library.isPrivate && enabled) {
      final success = await _showPrivacyAuthDialog(context, ref, library);
      if (!success) {
        return; // 验证失败，不执行激活操作
      }
    }

    // 直接更新库的 isEnabled 状态，不再使用独立的激活状态系统
    final updatedLibrary = library.copyWith(isEnabled: enabled);
    ref.read(libraryActionsProvider.notifier).updateLibrary(updatedLibrary);
  }

  /// 显示隐私验证对话框
  Future<bool> _showPrivacyAuthDialog(
      BuildContext context, WidgetRef ref, MangaLibrary library) async {
    final result = await showPasswordVerifyDialog(
      context,
      libraryId: library.id,
      libraryName: library.name,
      title: '激活隐私库',
      message: '请验证身份以激活隐私库 "${library.name}"',
    );

    return result == true;
  }

  void _scanLibrary(
      BuildContext context, WidgetRef ref, String libraryId) async {
    final libraryActions = ref.read(libraryActionsProvider.notifier);

    try {
      await libraryActions.scanLibrary(libraryId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('扫描完成')),
        );
      }
    } catch (e, stackTrace) {
      log('扫描库时出错: $e, 栈跟踪: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
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

  void _showLibrarySettings(
      BuildContext context, WidgetRef ref, MangaLibrary library) {
    showDialog(
      context: context,
      builder: (context) => LibrarySettingsDialog(
        library: library,
        onSave: (settings) {
          final updatedLibrary = library.copyWith(settings: settings);
          ref
              .read(libraryActionsProvider.notifier)
              .updateLibrary(updatedLibrary);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已保存漫画库 "${library.name}" 的设置')),
          );
        },
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

  void _showPrivacySettings(
      BuildContext context, WidgetRef ref, MangaLibrary library) async {
    // 检查是否已设置密码
    final hasPassword = await PrivacyService.hasPassword();

    if (!hasPassword) {
      // 如果没有设置密码，显示提示对话框
      _showPasswordRequiredDialog(context);
      return;
    }

    // 如果已设置密码，直接显示验证对话框
    final result = await showPasswordVerifyDialog(
      context,
      libraryId: library.id,
      libraryName: library.name,
      title: '隐私验证',
      message: '请验证身份以访问隐私库 "${library.name}"',
    );

    if (result == true) {
      // 验证成功，激活隐私库
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
      final success = await privacyNotifier.updateLibraryEnabled(
          library.id, !library.isPrivate);

      if (context.mounted) {
        if (success) {
          ref.refresh(allLibrariesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('隐私库已激活'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('激活失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 显示需要设置密码的对话框
  void _showPasswordRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要设置密码'),
        content: const Text(
          '启用隐私模式前，请先在设置中设置隐私密码。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings/privacy');
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  void _showLibrarySyncOptions(BuildContext context, MangaLibrary library) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '同步 "${library.name}"',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '选择要同步的内容和目标设备',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('同步漫画库'),
              subtitle: const Text('同步库中的漫画和设置'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/sync/library-sync', extra: library);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('同步阅读进度'),
              subtitle: const Text('同步此库中漫画的阅读进度'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/sync/progress-sync', extra: library);
              },
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('设备管理'),
              subtitle: const Text('查看和管理可用设备'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/sync/device-management');
              },
            ),
          ],
        ),
      ),
    );
  }
}

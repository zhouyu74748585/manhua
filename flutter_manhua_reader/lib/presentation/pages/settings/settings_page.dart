import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader(context, '外观'),
          _buildThemeSettings(context, ref),
          
          const Divider(),
          
          // 阅读设置
          _buildSectionHeader(context, '阅读'),
          _buildReaderSettings(context, ref),
          
          const Divider(),
          
          // 存储设置
          _buildSectionHeader(context, '存储'),
          _buildStorageSettings(context, ref),
          
          const Divider(),
          
          // 关于
          _buildSectionHeader(context, '关于'),
          _buildAboutSettings(context, ref),
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
  
  Widget _buildThemeSettings(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    
    return Column(
      children: [
        ListTile(
          leading: Icon(ThemeHelper.getThemeIcon(currentTheme)),
          title: const Text('主题模式'),
          subtitle: Text(ThemeHelper.getThemeDisplayName(currentTheme)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showThemeDialog(context, ref);
          },
        ),
      ],
    );
  }
  
  Widget _buildReaderSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.chrome_reader_mode),
          title: const Text('阅读模式'),
          subtitle: const Text('单页'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 阅读模式设置
          },
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('阅读方向'),
          subtitle: const Text('从左到右'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 阅读方向设置
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.fullscreen),
          title: const Text('全屏阅读'),
          subtitle: const Text('隐藏状态栏和导航栏'),
          value: false,
          onChanged: (value) {
            // TODO: 全屏设置
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.screen_lock_rotation),
          title: const Text('保持屏幕常亮'),
          subtitle: const Text('阅读时防止屏幕自动关闭'),
          value: true,
          onChanged: (value) {
            // TODO: 屏幕常亮设置
          },
        ),
      ],
    );
  }
  
  Widget _buildStorageSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.folder),
          title: const Text('缓存目录'),
          subtitle: const Text('/storage/emulated/0/MangaReader'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 缓存目录设置
          },
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('缓存大小'),
          subtitle: const Text('128 MB'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 缓存管理
          },
        ),
        ListTile(
          leading: const Icon(Icons.clear_all),
          title: const Text('清除缓存'),
          subtitle: const Text('清除所有图片缓存'),
          onTap: () {
            _showClearCacheDialog(context);
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('版本信息'),
          subtitle: const Text('1.0.0'),
          onTap: () {
            // TODO: 版本信息
          },
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('检查更新'),
          onTap: () {
            // TODO: 检查更新
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('帮助与反馈'),
          onTap: () {
            // TODO: 帮助页面
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('隐私政策'),
          onTap: () {
            // TODO: 隐私政策
          },
        ),
      ],
    );
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(ThemeHelper.getThemeDisplayName(mode)),
              value: mode,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有图片缓存吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 清除缓存
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
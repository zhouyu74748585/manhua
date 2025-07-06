import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import 'about_page.dart';
import 'permission_diagnostic_page.dart';
import 'permission_management_page.dart';
import 'privacy_settings_page.dart';
import 'reader_settings_page.dart';
import 'storage_settings_page.dart';

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

          // 隐私设置
          _buildSectionHeader(context, '隐私'),
          _buildPrivacySettings(context, ref),

          const Divider(),

          // 权限设置
          _buildSectionHeader(context, '权限'),
          _buildPermissionSettings(context, ref),

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
          title: const Text('阅读器设置'),
          subtitle: const Text('阅读模式、显示设置、交互设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ReaderSettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('隐私模式'),
          subtitle: const Text('设置密码和生物识别'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacySettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPermissionSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('权限诊断'),
          subtitle: const Text('检查和修复文件访问权限问题'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PermissionDiagnosticPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: const Text('权限管理'),
          subtitle: const Text('管理已授权的文件夹路径'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PermissionManagementPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageSettings(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('存储管理'),
          subtitle: const Text('缓存管理、存储位置设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StorageSettingsPage(),
              ),
            );
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
          title: const Text('关于应用'),
          subtitle: const Text('版本信息、开发者信息、许可证'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
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

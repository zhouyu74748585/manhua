import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/settings.dart';
import '../../providers/settings_provider.dart';

/// 阅读器设置页面
class ReaderSettingsPage extends ConsumerWidget {
  const ReaderSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读器设置'),
      ),
      body: settingsAsync.when(
        data: (settings) =>
            _buildContent(context, ref, settings.readerSettings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载设置失败: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    return ListView(
      children: [
        // 阅读模式
        _buildSectionHeader(context, '阅读模式'),
        _buildReadingModeSettings(context, ref, settings),

        const Divider(),

        // 显示设置
        _buildSectionHeader(context, '显示设置'),
        _buildDisplaySettings(context, ref, settings),

        const Divider(),

        // 交互设置
        _buildSectionHeader(context, '交互设置'),
        _buildInteractionSettings(context, ref, settings),

        const Divider(),

        // 性能设置
        _buildSectionHeader(context, '性能设置'),
        _buildPerformanceSettings(context, ref, settings),
      ],
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

  Widget _buildReadingModeSettings(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.chrome_reader_mode),
          title: const Text('阅读模式'),
          subtitle: Text(_getReadingModeDisplayName(settings.readingMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showReadingModeDialog(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('阅读方向'),
          subtitle:
              Text(_getReadingDirectionDisplayName(settings.readingDirection)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showReadingDirectionDialog(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.fit_screen),
          title: const Text('图片适应模式'),
          subtitle: Text(_getImageFitDisplayName(settings.imageFit)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showImageFitDialog(context, ref, settings),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fullscreen),
          title: const Text('全屏模式'),
          subtitle: const Text('隐藏状态栏和导航栏'),
          value: settings.fullscreen,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(fullscreen: value),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.screen_lock_rotation),
          title: const Text('保持屏幕常亮'),
          subtitle: const Text('阅读时防止屏幕自动关闭'),
          value: settings.keepScreenOn,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(keepScreenOn: value),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('屏幕亮度'),
          subtitle: Text('${(settings.brightness * 100).round()}%'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showBrightnessDialog(context, ref, settings),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.format_list_numbered),
          title: const Text('显示页码'),
          subtitle: const Text('在屏幕上显示当前页码'),
          value: settings.showPageNumber,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(showPageNumber: value),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.battery_std),
          title: const Text('显示电量'),
          subtitle: const Text('在屏幕上显示电池电量'),
          value: settings.showBattery,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(showBattery: value),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.access_time),
          title: const Text('显示时钟'),
          subtitle: const Text('在屏幕上显示当前时间'),
          value: settings.showClock,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(showClock: value),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionSettings(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.volume_up),
          title: const Text('音量键翻页'),
          subtitle: const Text('使用音量键进行翻页操作'),
          value: settings.enableVolumeKeys,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(enableVolumeKeys: value),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.touch_app),
          title: const Text('点击翻页'),
          subtitle: const Text('点击屏幕边缘进行翻页'),
          value: settings.enableTapNavigation,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(enableTapNavigation: value),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.zoom_in),
          title: const Text('双击缩放倍数'),
          subtitle: Text('${settings.doubleTapZoomScale.toStringAsFixed(1)}x'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showZoomScaleDialog(context, ref, settings),
        ),
      ],
    );
  }

  Widget _buildPerformanceSettings(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.cached),
          title: const Text('启用预加载'),
          subtitle: const Text('提前加载下一页图片'),
          value: settings.enablePreloading,
          onChanged: (value) => _updateReaderSettings(
            ref,
            settings.copyWith(enablePreloading: value),
          ),
        ),
        if (settings.enablePreloading)
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text('预加载页数'),
            subtitle: Text('${settings.preloadPages} 页'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPreloadPagesDialog(context, ref, settings),
          ),
      ],
    );
  }

  // 辅助方法
  String _getReadingModeDisplayName(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.single:
        return '单页模式';
      case ReadingMode.double:
        return '双页模式';
    }
  }

  String _getReadingDirectionDisplayName(ReadingDirection direction) {
    switch (direction) {
      case ReadingDirection.leftToRight:
        return '从左到右';
      case ReadingDirection.rightToLeft:
        return '从右到左';
      case ReadingDirection.topToBottom:
        return '从上到下';
    }
  }

  String _getImageFitDisplayName(ImageFitMode fit) {
    switch (fit) {
      case ImageFitMode.fitWidth:
        return '适应宽度';
      case ImageFitMode.fitHeight:
        return '适应高度';
      case ImageFitMode.fitScreen:
        return '适应屏幕';
      case ImageFitMode.originalSize:
        return '原始大小';
    }
  }

  void _updateReaderSettings(WidgetRef ref, ReaderSettings newSettings) {
    ref
        .read(appSettingsNotifierProvider.notifier)
        .updateReaderSettings(newSettings);
  }

  // 对话框方法
  void _showReadingModeDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择阅读模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReadingMode.values.map((mode) {
            return RadioListTile<ReadingMode>(
              title: Text(_getReadingModeDisplayName(mode)),
              value: mode,
              groupValue: settings.readingMode,
              onChanged: (value) {
                if (value != null) {
                  _updateReaderSettings(
                      ref, settings.copyWith(readingMode: value));
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

  void _showReadingDirectionDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择阅读方向'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReadingDirection.values.map((direction) {
            return RadioListTile<ReadingDirection>(
              title: Text(_getReadingDirectionDisplayName(direction)),
              value: direction,
              groupValue: settings.readingDirection,
              onChanged: (value) {
                if (value != null) {
                  _updateReaderSettings(
                      ref, settings.copyWith(readingDirection: value));
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

  void _showImageFitDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片适应模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ImageFitMode.values.map((fit) {
            return RadioListTile<ImageFitMode>(
              title: Text(_getImageFitDisplayName(fit)),
              value: fit,
              groupValue: settings.imageFit,
              onChanged: (value) {
                if (value != null) {
                  _updateReaderSettings(
                      ref, settings.copyWith(imageFit: value));
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

  void _showBrightnessDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('调节屏幕亮度'),
        content: StatefulBuilder(
          builder: (context, setState) {
            double brightness = settings.brightness;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(brightness * 100).round()}%'),
                Slider(
                  value: brightness,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      brightness = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _updateReaderSettings(
                  ref, settings.copyWith(brightness: settings.brightness));
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showZoomScaleDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置双击缩放倍数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1.5, 2.0, 2.5, 3.0, 4.0].map((scale) {
            return RadioListTile<double>(
              title: Text('${scale.toStringAsFixed(1)}x'),
              value: scale,
              groupValue: settings.doubleTapZoomScale,
              onChanged: (value) {
                if (value != null) {
                  _updateReaderSettings(
                      ref, settings.copyWith(doubleTapZoomScale: value));
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

  void _showPreloadPagesDialog(
      BuildContext context, WidgetRef ref, ReaderSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置预加载页数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 5, 10].map((pages) {
            return RadioListTile<int>(
              title: Text('$pages 页'),
              value: pages,
              groupValue: settings.preloadPages,
              onChanged: (value) {
                if (value != null) {
                  _updateReaderSettings(
                      ref, settings.copyWith(preloadPages: value));
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
}

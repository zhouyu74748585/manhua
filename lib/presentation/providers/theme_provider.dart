import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/storage_service.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final savedTheme = StorageService.getThemeMode();
    return _parseThemeMode(savedTheme);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await StorageService.setThemeMode(_themeToString(themeMode));
  }

  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

// 便捷的Provider访问
final themeModeProvider = themeModeNotifierProvider;

// 当前是否为深色模式的Provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      // 获取系统主题
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
  }
});

// 主题切换助手类
class ThemeHelper {
  static void toggleTheme(WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    switch (currentTheme) {
      case ThemeMode.light:
        notifier.setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        notifier.setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        notifier.setThemeMode(ThemeMode.light);
        break;
    }
  }

  static String getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  static IconData getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

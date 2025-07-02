import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  // 平台检测
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWeb => kIsWeb;

  // 平台分组
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  // 获取平台名称
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  // 获取操作系统版本
  static String get operatingSystemVersion {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystemVersion;
  }

  // 检查是否支持文件系统访问
  static bool get supportsFileSystem => !isWeb;

  // 检查是否支持窗口管理
  static bool get supportsWindowManagement => isDesktop;

  // 检查是否支持系统托盘
  static bool get supportsSystemTray => isDesktop;

  // 检查是否支持通知
  static bool get supportsNotifications => !isWeb;

  // 检查是否支持权限管理
  static bool get supportsPermissions => isMobile;

  // 获取默认的网格列数
  static int getDefaultGridColumns() {
    if (isMobile) return 2;
    if (isDesktop) return 4;
    return 3; // Tablet or other
  }

  // 获取默认的侧边栏宽度
  static double getDefaultSidebarWidth() {
    if (isMobile) return 280.0;
    return 320.0;
  }

  // 检查是否应该显示侧边栏
  static bool shouldShowSidebar(double screenWidth) {
    if (isMobile) return false;
    return screenWidth > 768;
  }

  // 获取断点
  static bool isMobileBreakpoint(double width) => width < 768;
  static bool isTabletBreakpoint(double width) => width >= 768 && width < 1024;
  static bool isDesktopBreakpoint(double width) => width >= 1024;

  // 获取响应式列数
  static int getResponsiveColumns(double width) {
    if (isMobileBreakpoint(width)) return 2;
    if (isTabletBreakpoint(width)) return 3;
    return 4;
  }

  // 获取响应式间距
  static double getResponsivePadding(double width) {
    if (isMobileBreakpoint(width)) return 16.0;
    if (isTabletBreakpoint(width)) return 24.0;
    return 32.0;
  }
}

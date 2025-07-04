import 'package:flutter/material.dart';

import '../../../data/models/library.dart';
import '../../../data/services/privacy_service.dart';
import 'privacy_dialog.dart';

class PrivacyAccessHandler {
  /// 检查并处理漫画库的隐私访问
  /// 如果需要验证，显示验证对话框
  /// 返回是否允许访问
  static Future<bool> checkLibraryAccess({
    required BuildContext context,
    required MangaLibrary library,
    VoidCallback? onAccessGranted,
  }) async {
    // 如果没有启用隐私保护，直接允许访问
    if (!library.isPrivate) {
      onAccessGranted?.call();
      return true;
    }

    // 如果已经激活，直接允许访问
    if (library.isPrivateActivated) {
      onAccessGranted?.call();
      return true;
    }

    // 获取认证方式
    final authMethod = await PrivacyService.getLibraryAuthMethod(library.id);

    if (authMethod == PrivacyAuthMethod.none) {
      // 没有设置认证方式，直接允许访问
      onAccessGranted?.call();
      return true;
    }

    // 显示验证对话框
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrivacyVerificationDialog(
        libraryId: library.id,
        libraryName: library.name,
        authMethod: authMethod,
        onVerified: () {
          Navigator.of(context).pop(true);
        },
      ),
    );

    if (result == true) {
      onAccessGranted?.call();
      return true;
    }

    return false;
  }

  /// 显示隐私设置对话框
  static void showPrivacySettings({
    required BuildContext context,
    required MangaLibrary library,
    VoidCallback? onPasswordSet,
    VoidCallback? onBiometricSet,
    VoidCallback? onPrivacyDisabled,
  }) {
    showDialog(
      context: context,
      builder: (context) => PrivacyDialog(
        libraryId: library.id,
        libraryName: library.name,
        isPrivate: library.isPrivate,
        onPasswordSet: onPasswordSet,
        onBiometricSet: onBiometricSet,
        onPrivacyDisabled: onPrivacyDisabled,
      ),
    );
  }

  /// 清除漫画库的激活状态（用于应用重启或超时后重新验证）
  static Future<void> clearActivationStatus(String libraryId) async {
    await PrivacyService.setLibraryActivationStatus(libraryId, false);
  }

  /// 清除所有漫画库的激活状态
  static Future<void> clearAllActivationStatus(List<MangaLibrary> libraries) async {
    for (final library in libraries) {
      if (library.isPrivate) {
        await clearActivationStatus(library.id);
      }
    }
  }
}

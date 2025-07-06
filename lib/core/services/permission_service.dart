import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';

/// 权限管理服务
/// 负责处理Android/iOS文件访问权限的请求、持久化和管理
class PermissionService {
  static const String _permissionGrantedKey = 'file_permission_granted';
  static const String _grantedPathsKey = 'granted_file_paths';
  static const String _lastPermissionCheckKey = 'last_permission_check';

  /// 检查并请求文件访问权限
  /// 返回是否获得权限
  static Future<bool> requestFilePermission() async {
    try {
      if (Platform.isAndroid) {
        return await _requestAndroidFilePermission();
      } else if (Platform.isIOS) {
        return await _requestIOSFilePermission();
      } else {
        // 桌面平台默认有文件访问权限
        return true;
      }
    } catch (e, stackTrace) {
      log('请求文件权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Android文件权限请求
  static Future<bool> _requestAndroidFilePermission() async {
    // 检查Android版本
    final androidInfo = await _getAndroidVersion();

    if (androidInfo >= 33) {
      // Android 13+ 使用细粒度媒体权限
      return await _requestAndroid13Permission();
    } else if (androidInfo >= 30) {
      // Android 11+ 使用作用域存储
      return await _requestScopedStoragePermission();
    } else {
      // Android 10及以下使用传统权限
      return await _requestLegacyStoragePermission();
    }
  }

  /// Android 13+ 细粒度权限请求
  static Future<bool> _requestAndroid13Permission() async {
    try {
      log('开始请求Android 13+权限');

      // 首先尝试请求管理外部存储权限（最高权限）
      final manageStorageStatus =
          await permission_handler.Permission.manageExternalStorage.status;
      log('管理外部存储权限状态: $manageStorageStatus');

      if (manageStorageStatus.isDenied) {
        final manageResult =
            await permission_handler.Permission.manageExternalStorage.request();
        log('管理外部存储权限请求结果: $manageResult');
        if (manageResult.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      } else if (manageStorageStatus.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      // 如果管理权限被拒绝，请求细粒度媒体权限
      final permissions = [
        permission_handler.Permission.photos,
        permission_handler.Permission.videos,
        permission_handler.Permission.audio,
      ];

      log('请求细粒度媒体权限');
      Map<permission_handler.Permission, permission_handler.PermissionStatus>
          statuses = await permissions.request();
      log('细粒度权限请求结果: $statuses');

      // 检查是否有任何权限被授予
      bool hasAnyPermission = statuses.values.any((status) => status.isGranted);

      if (hasAnyPermission) {
        await _savePermissionStatus(true);
        return true;
      }

      log('所有权限请求都被拒绝');
      return false;
    } catch (e, stackTrace) {
      log('请求Android 13+权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Android 11+ 作用域存储权限
  static Future<bool> _requestScopedStoragePermission() async {
    try {
      log('开始请求Android 11+权限');

      // 首先尝试请求管理外部存储权限
      final manageStorageStatus =
          await permission_handler.Permission.manageExternalStorage.status;
      log('管理外部存储权限状态: $manageStorageStatus');

      if (manageStorageStatus.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (manageStorageStatus.isDenied) {
        log('请求管理外部存储权限');
        final result =
            await permission_handler.Permission.manageExternalStorage.request();
        log('管理外部存储权限请求结果: $result');
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      // 如果管理权限被拒绝，尝试基本存储权限
      final storageStatus = await permission_handler.Permission.storage.status;
      log('基本存储权限状态: $storageStatus');

      if (storageStatus.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (storageStatus.isDenied) {
        log('请求基本存储权限');
        final result = await permission_handler.Permission.storage.request();
        log('基本存储权限请求结果: $result');
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      log('所有存储权限请求都被拒绝');
      return false;
    } catch (e, stackTrace) {
      log('请求Android 11+权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Android 10及以下传统存储权限
  static Future<bool> _requestLegacyStoragePermission() async {
    try {
      final status = await permission_handler.Permission.storage.status;

      if (status.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (status.isDenied) {
        final result = await permission_handler.Permission.storage.request();
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      log('请求传统存储权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// iOS文件权限请求
  static Future<bool> _requestIOSFilePermission() async {
    try {
      // iOS通过文件选择器自动获得权限
      // 这里主要是检查照片库权限（如果需要）
      final status = await permission_handler.Permission.photos.status;

      if (status.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (status.isDenied) {
        final result = await permission_handler.Permission.photos.request();
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      // iOS文件访问主要通过文件选择器，这里返回true
      await _savePermissionStatus(true);
      return true;
    } catch (e, stackTrace) {
      log('请求iOS权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 检查权限状态
  static Future<bool> hasFilePermission() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidPermission();
      } else if (Platform.isIOS) {
        return await _checkIOSPermission();
      } else {
        return true; // 桌面平台
      }
    } catch (e, stackTrace) {
      log('检查权限状态失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 检查Android权限状态
  static Future<bool> _checkAndroidPermission() async {
    final androidInfo = await _getAndroidVersion();

    try {
      if (androidInfo >= 33) {
        // Android 13+ 检查细粒度权限
        final permissions = [
          permission_handler.Permission.photos,
          permission_handler.Permission.videos,
          permission_handler.Permission.audio,
        ];

        final statuses = await Future.wait(
          permissions.map((p) => p.status),
        );

        bool hasAnyPermission = statuses.any((status) => status.isGranted);

        if (!hasAnyPermission) {
          final manageStatus =
              await permission_handler.Permission.manageExternalStorage.status;
          hasAnyPermission = manageStatus.isGranted;
        }

        // 验证实际文件访问能力
        if (hasAnyPermission) {
          return await _verifyFileAccess();
        }

        return false;
      } else if (androidInfo >= 30) {
        // Android 11+
        final manageStatus =
            await permission_handler.Permission.manageExternalStorage.status;
        final storageStatus =
            await permission_handler.Permission.storage.status;
        bool hasPermission = manageStatus.isGranted || storageStatus.isGranted;

        if (hasPermission) {
          return await _verifyFileAccess();
        }

        return false;
      } else {
        // Android 10及以下
        final status = await permission_handler.Permission.storage.status;
        bool hasPermission = status.isGranted;

        if (hasPermission) {
          return await _verifyFileAccess();
        }

        return false;
      }
    } catch (e, stackTrace) {
      log('检查Android权限状态失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 验证实际文件访问能力
  static Future<bool> _verifyFileAccess() async {
    try {
      // 尝试访问常见的存储路径
      final testPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
      ];

      for (final path in testPaths) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            final files = await directory.list().take(1).toList();
            // 如果能够列出文件，说明有访问权限
            return true;
          }
        } catch (e) {
          // 继续尝试下一个路径
          continue;
        }
      }

      return false;
    } catch (e, stackTrace) {
      log('验证文件访问失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 检查iOS权限状态
  static Future<bool> _checkIOSPermission() async {
    // iOS主要通过文件选择器获得权限，这里返回保存的状态
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionGrantedKey) ?? false;
  }

  /// 保存权限状态
  static Future<void> _savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionGrantedKey, granted);
    await prefs.setInt(
        _lastPermissionCheckKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 保存已授权的文件路径
  static Future<void> saveGrantedPath(String path) async {
    try {
      // 验证路径有效性
      if (path.trim().isEmpty) {
        log('忽略空路径');
        return;
      }

      // 规范化路径（移除尾部斜杠）
      final normalizedPath = path.endsWith('/') && path.length > 1
          ? path.substring(0, path.length - 1)
          : path;

      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_grantedPathsKey) ?? <String>[];

      if (!grantedPaths.contains(normalizedPath)) {
        grantedPaths.add(normalizedPath);
        await prefs.setStringList(_grantedPathsKey, grantedPaths);
        log('已保存授权路径: $normalizedPath');
      }
    } catch (e, stackTrace) {
      log('保存授权路径失败: $e', stackTrace: stackTrace);
    }
  }

  /// 获取已授权的文件路径列表
  static Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_grantedPathsKey) ?? <String>[];
    } catch (e, stackTrace) {
      log('获取授权路径失败: $e', stackTrace: stackTrace);
      return <String>[];
    }
  }

  /// 检查特定路径是否已授权
  static Future<bool> isPathGranted(String path) async {
    try {
      // 验证路径有效性
      if (path.trim().isEmpty) {
        return false;
      }

      // 规范化路径
      final normalizedPath = path.endsWith('/') && path.length > 1
          ? path.substring(0, path.length - 1)
          : path;

      final grantedPaths = await getGrantedPaths();
      return grantedPaths.any((grantedPath) =>
          normalizedPath.startsWith(grantedPath) ||
          grantedPath.startsWith(normalizedPath));
    } catch (e, stackTrace) {
      log('检查路径授权失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 移除已授权的路径
  static Future<void> removeGrantedPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_grantedPathsKey) ?? <String>[];
      grantedPaths.remove(path);
      await prefs.setStringList(_grantedPathsKey, grantedPaths);
    } catch (e, stackTrace) {
      log('移除授权路径失败: $e', stackTrace: stackTrace);
    }
  }

  /// 清除所有权限数据
  static Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_permissionGrantedKey);
      await prefs.remove(_grantedPathsKey);
      await prefs.remove(_lastPermissionCheckKey);
    } catch (e, stackTrace) {
      log('清除权限数据失败: $e', stackTrace: stackTrace);
    }
  }

  /// 获取Android版本号
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 30; // 非Android平台返回默认值
    } catch (e, stackTrace) {
      log('获取Android版本失败: $e', stackTrace: stackTrace);
      return 28; // 默认返回Android 9
    }
  }

  /// 验证并保存文件夹权限
  static Future<bool> validateAndSaveFolderPermission(String path) async {
    try {
      log('验证文件夹权限: $path');

      // 检查目录是否存在
      final directory = Directory(path);
      if (!await directory.exists()) {
        log('目录不存在: $path');
        return false;
      }

      // 尝试访问目录
      try {
        final contents =
            await directory.list(followLinks: false).take(5).toList();
        log('成功访问目录，包含 ${contents.length} 个项目');

        // 保存授权路径
        await saveGrantedPath(path);

        // 更新权限状态
        await _savePermissionStatus(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            _lastPermissionCheckKey, DateTime.now().millisecondsSinceEpoch);

        return true;
      } catch (e) {
        log('无法访问目录内容: $e');
        return false;
      }
    } catch (e, stackTrace) {
      log('验证文件夹权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 打开应用设置页面
  static Future<void> openAppSettings() async {
    try {
      // 使用permission_handler包的全局函数
      await permission_handler.openAppSettings();
    } catch (e, stackTrace) {
      log('打开应用设置失败: $e', stackTrace: stackTrace);
    }
  }
}

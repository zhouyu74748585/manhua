import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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

    if (androidInfo >= 30) {
      // Android 11+ 使用作用域存储
      return await _requestScopedStoragePermission();
    } else {
      // Android 10及以下使用传统权限
      return await _requestLegacyStoragePermission();
    }
  }

  /// Android 11+ 作用域存储权限
  static Future<bool> _requestScopedStoragePermission() async {
    try {
      // 首先尝试请求管理外部存储权限
      final manageStorageStatus = await Permission.manageExternalStorage.status;

      if (manageStorageStatus.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (manageStorageStatus.isDenied) {
        final result = await Permission.manageExternalStorage.request();
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      // 如果管理权限被拒绝，尝试基本存储权限
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (storageStatus.isDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          await _savePermissionStatus(true);
          return true;
        }
      }

      return false;
    } catch (e, stackTrace) {
      log('请求Android 11+权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Android 10及以下传统存储权限
  static Future<bool> _requestLegacyStoragePermission() async {
    try {
      final status = await Permission.storage.status;

      if (status.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.storage.request();
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
      final status = await Permission.photos.status;

      if (status.isGranted) {
        await _savePermissionStatus(true);
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.photos.request();
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

    if (androidInfo >= 30) {
      // Android 11+
      final manageStatus = await Permission.manageExternalStorage.status;
      final storageStatus = await Permission.storage.status;
      return manageStatus.isGranted || storageStatus.isGranted;
    } else {
      // Android 10及以下
      final status = await Permission.storage.status;
      return status.isGranted;
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
          normalizedPath.startsWith(grantedPath) || grantedPath.startsWith(normalizedPath));
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

  /// 打开应用设置页面
  static Future<void> openAppSettings() async {
    try {
      await Permission.storage.request();
    } catch (e, stackTrace) {
      log('打开应用设置失败: $e', stackTrace: stackTrace);
    }
  }
}

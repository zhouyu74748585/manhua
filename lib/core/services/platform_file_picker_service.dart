import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'permission_service.dart';

/// 平台特定的文件选择器服务
/// 为不同平台提供优化的文件选择和权限管理
abstract class PlatformFilePickerService {
  /// 创建平台特定的文件选择器实例
  static PlatformFilePickerService create() {
    if (Platform.isAndroid) {
      return AndroidFilePickerService();
    } else if (Platform.isIOS) {
      return IOSFilePickerService();
    } else if (Platform.isMacOS) {
      return MacOSFilePickerService();
    } else if (Platform.isWindows) {
      return WindowsFilePickerService();
    } else if (Platform.isLinux) {
      return LinuxFilePickerService();
    } else {
      return DefaultFilePickerService();
    }
  }

  /// 选择文件夹并处理权限持久化
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  });

  /// 检查路径权限
  Future<bool> checkPathPermission(String path);

  /// 保存路径权限
  Future<void> savePathPermission(String path);

  /// 获取已保存的权限路径
  Future<List<String>> getGrantedPaths();

  /// 清除所有权限
  Future<void> clearAllPermissions();

  /// 验证目录访问权限
  Future<bool> verifyDirectoryAccess(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return false;
      }
      await directory.list(followLinks: false).take(1).toList();
      return true;
    } catch (e) {
      log('验证目录访问失败: $path, 错误: $e');
      return false;
    }
  }
}

/// Android平台文件选择器服务
class AndroidFilePickerService extends PlatformFilePickerService {
  static const String _androidGrantedPathsKey = 'android_granted_paths';
  static const String _androidPermissionVersionKey = 'android_permission_version';
  
  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      // 显示Android特定的权限说明
      final shouldProceed = await _showAndroidPermissionDialog(context);
      if (!shouldProceed) return null;

      // 检查并请求权限
      final hasPermission = await PermissionService.requestFilePermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return null;
      }

      // 尝试标准文件选择器
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      // 处理Android特有的根目录问题
      if (result == '/' || result == null) {
        return await _handleAndroidDirectorySelection(context);
      }

      // 验证并保存权限
      if (await verifyDirectoryAccess(result)) {
        await savePathPermission(result);
        await _savePermissionWithTimestamp(result);
        return result;
      } else {
        if (context.mounted) {
          await _showAccessErrorDialog(context, result);
        }
        return null;
      }
    } catch (e, stackTrace) {
      log('Android文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_androidGrantedPathsKey) ?? [];
      
      // 检查路径是否在已授权列表中
      final isGranted = grantedPaths.any((grantedPath) => 
          path.startsWith(grantedPath) || grantedPath.startsWith(path));
      
      if (isGranted) {
        // 验证权限是否仍然有效
        return await verifyDirectoryAccess(path);
      }
      
      return false;
    } catch (e) {
      log('检查Android路径权限失败: $e');
      return false;
    }
  }

  @override
  Future<void> savePathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_androidGrantedPathsKey) ?? [];
      
      if (!grantedPaths.contains(path)) {
        grantedPaths.add(path);
        await prefs.setStringList(_androidGrantedPathsKey, grantedPaths);
        log('Android路径权限已保存: $path');
      }
    } catch (e) {
      log('保存Android路径权限失败: $e');
    }
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_androidGrantedPathsKey) ?? [];
    } catch (e) {
      log('获取Android已授权路径失败: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_androidGrantedPathsKey);
      await prefs.remove(_androidPermissionVersionKey);
      log('Android权限数据已清除');
    } catch (e) {
      log('清除Android权限数据失败: $e');
    }
  }

  /// 保存权限时间戳
  Future<void> _savePermissionWithTimestamp(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('${path}_timestamp', timestamp);
    } catch (e) {
      log('保存权限时间戳失败: $e');
    }
  }

  /// 显示Android权限说明对话框
  Future<bool> _showAndroidPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Android文件访问权限'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Android系统需要特殊权限来访问文件夹：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• 文件和媒体访问权限'),
              Text('• 所有文件访问权限（推荐）'),
              SizedBox(height: 12),
              Text(
                '注意事项：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 选择的文件夹权限将被永久保存'),
              Text('• 重启应用后权限依然有效'),
              Text('• 可在设置中管理已授权的文件夹'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 处理Android目录选择问题
  Future<String?> _handleAndroidDirectorySelection(BuildContext context) async {
    // 获取常用目录
    final commonPaths = await _getAndroidCommonPaths();
    
    if (context.mounted) {
      return await _showAndroidPathSelectionDialog(context, commonPaths);
    }
    
    return null;
  }

  /// 获取Android常用路径
  Future<List<String>> _getAndroidCommonPaths() async {
    final paths = <String>[];
    
    try {
      // 外部存储目录
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        paths.add('${externalDir.path}/manga');
      }
      
      // 常用公共目录
      const commonDirs = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
      ];
      
      for (final dir in commonDirs) {
        if (await Directory(dir).exists()) {
          paths.add(dir);
        }
      }
    } catch (e) {
      log('获取Android常用路径失败: $e');
    }
    
    return paths;
  }

  /// 显示Android路径选择对话框
  Future<String?> _showAndroidPathSelectionDialog(
      BuildContext context, List<String> paths) async {
    if (!context.mounted) return null;

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择文件夹'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: paths.length,
            itemBuilder: (context, index) {
              final path = paths[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(path.split('/').last),
                subtitle: Text(path),
                onTap: () => Navigator.of(context).pop(path),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _showManualPathInput(context),
            child: const Text('手动输入'),
          ),
        ],
      ),
    );
  }

  /// 显示手动路径输入对话框
  Future<String?> _showManualPathInput(BuildContext context) async {
    final controller = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动输入路径'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/storage/emulated/0/Download/manga',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isNotEmpty && await verifyDirectoryAccess(path)) {
                Navigator.of(context).pop(path);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 显示权限被拒绝对话框
  void _showPermissionDeniedDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限被拒绝'),
        content: const Text(
          '无法获取文件访问权限。请在系统设置中手动授权，或选择应用内部目录。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  /// 显示访问错误对话框
  Future<void> _showAccessErrorDialog(BuildContext context, String path) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('无法访问文件夹'),
        content: Text('无法访问选择的路径：\n$path\n\n请选择其他文件夹或检查权限设置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// iOS平台文件选择器服务
class IOSFilePickerService extends PlatformFilePickerService {
  static const String _iosGrantedPathsKey = 'ios_granted_paths';
  static const String _iosBookmarksKey = 'ios_security_bookmarks';

  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      // iOS使用文档选择器，自动处理权限
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      if (result != null) {
        // 保存安全书签（iOS特有）
        await _saveSecurityBookmark(result);
        await savePathPermission(result);
        return result;
      }

      return null;
    } catch (e, stackTrace) {
      log('iOS文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_iosGrantedPathsKey) ?? [];
      
      // 检查是否有安全书签
      final hasBookmark = prefs.containsKey('${path}_bookmark');
      
      return grantedPaths.contains(path) && hasBookmark;
    } catch (e) {
      log('检查iOS路径权限失败: $e');
      return false;
    }
  }

  @override
  Future<void> savePathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_iosGrantedPathsKey) ?? [];
      
      if (!grantedPaths.contains(path)) {
        grantedPaths.add(path);
        await prefs.setStringList(_iosGrantedPathsKey, grantedPaths);
        log('iOS路径权限已保存: $path');
      }
    } catch (e) {
      log('保存iOS路径权限失败: $e');
    }
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_iosGrantedPathsKey) ?? [];
    } catch (e) {
      log('获取iOS已授权路径失败: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_iosGrantedPathsKey);
      await prefs.remove(_iosBookmarksKey);
      log('iOS权限数据已清除');
    } catch (e) {
      log('清除iOS权限数据失败: $e');
    }
  }

  /// 保存iOS安全书签
  Future<void> _saveSecurityBookmark(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 在实际实现中，这里应该保存iOS的安全书签数据
      // 目前只保存路径标记
      await prefs.setString('${path}_bookmark', DateTime.now().toIso8601String());
      log('iOS安全书签已保存: $path');
    } catch (e) {
      log('保存iOS安全书签失败: $e');
    }
  }
}

/// macOS平台文件选择器服务
class MacOSFilePickerService extends PlatformFilePickerService {
  static const String _macosGrantedPathsKey = 'macos_granted_paths';

  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      // 显示macOS权限说明
      final shouldProceed = await _showMacOSPermissionDialog(context);
      if (!shouldProceed) return null;

      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      if (result != null) {
        // 验证目录访问权限
        final canAccess = await verifyDirectoryAccess(result);
        if (!canAccess) {
          if (context.mounted) {
            await _showAccessDeniedDialog(context, result);
          }
          return null;
        }
        
        await savePathPermission(result);
        log('macOS文件夹选择成功: $result');
        return result;
      } else {
        log('macOS文件夹选择被取消');
        return null;
      }
    } catch (e, stackTrace) {
      log('macOS文件夹选择失败: $e', stackTrace: stackTrace);
      
      if (context.mounted) {
        await _showErrorDialog(context, e.toString());
      }
      
      return null;
    }
  }
  
  /// 显示macOS权限说明对话框
  Future<bool> _showMacOSPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('macOS文件访问权限'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'macOS系统需要特殊权限来访问文件夹：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• 应用沙盒文件访问权限'),
              Text('• 用户选择的文件夹读写权限'),
              Text('• 系统文件夹访问权限'),
              SizedBox(height: 12),
              Text(
                '注意事项：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 首次访问时系统可能会弹出权限确认'),
              Text('• 选择的文件夹权限将被保存'),
              Text('• 如果无法访问，请检查系统隐私设置'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// 显示访问被拒绝对话框
  Future<void> _showAccessDeniedDialog(BuildContext context, String path) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('无法访问文件夹'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('无法访问选择的路径：'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                path,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('可能的解决方案：'),
            const SizedBox(height: 8),
            const Text('• 检查系统偏好设置 > 安全性与隐私 > 文件和文件夹'),
            const Text('• 确保应用有访问该文件夹的权限'),
            const Text('• 尝试选择其他文件夹'),
            const Text('• 重启应用后重试'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 打开系统偏好设置（如果可能）
              _openSystemPreferences();
            },
            child: const Text('打开系统设置'),
          ),
        ],
      ),
    );
  }
  
  /// 显示错误对话框
  Future<void> _showErrorDialog(BuildContext context, String error) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('文件选择器错误'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('文件选择器遇到错误：'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                error,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('建议：'),
            const SizedBox(height: 8),
            const Text('• 重启应用后重试'),
            const Text('• 检查macOS版本兼容性'),
            const Text('• 确保file_picker插件已正确安装'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 尝试打开系统偏好设置
  void _openSystemPreferences() {
    try {
      // 在实际实现中，可以使用url_launcher打开系统设置
      log('尝试打开macOS系统偏好设置');
    } catch (e) {
      log('无法打开系统偏好设置: $e');
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    // macOS通常有较好的权限管理，主要检查文件是否可访问
    return await verifyDirectoryAccess(path);
  }

  @override
  Future<void> savePathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_macosGrantedPathsKey) ?? [];
      
      if (!grantedPaths.contains(path)) {
        grantedPaths.add(path);
        await prefs.setStringList(_macosGrantedPathsKey, grantedPaths);
        log('macOS路径权限已保存: $path');
      }
    } catch (e) {
      log('保存macOS路径权限失败: $e');
    }
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_macosGrantedPathsKey) ?? [];
    } catch (e) {
      log('获取macOS已授权路径失败: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_macosGrantedPathsKey);
      log('macOS权限数据已清除');
    } catch (e) {
      log('清除macOS权限数据失败: $e');
    }
  }
}

/// Windows平台文件选择器服务
class WindowsFilePickerService extends PlatformFilePickerService {
  static const String _windowsGrantedPathsKey = 'windows_granted_paths';

  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      if (result != null) {
        await savePathPermission(result);
        return result;
      }

      return null;
    } catch (e, stackTrace) {
      log('Windows文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    return await verifyDirectoryAccess(path);
  }

  @override
  Future<void> savePathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_windowsGrantedPathsKey) ?? [];
      
      if (!grantedPaths.contains(path)) {
        grantedPaths.add(path);
        await prefs.setStringList(_windowsGrantedPathsKey, grantedPaths);
        log('Windows路径权限已保存: $path');
      }
    } catch (e) {
      log('保存Windows路径权限失败: $e');
    }
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_windowsGrantedPathsKey) ?? [];
    } catch (e) {
      log('获取Windows已授权路径失败: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_windowsGrantedPathsKey);
      log('Windows权限数据已清除');
    } catch (e) {
      log('清除Windows权限数据失败: $e');
    }
  }
}

/// Linux平台文件选择器服务
class LinuxFilePickerService extends PlatformFilePickerService {
  static const String _linuxGrantedPathsKey = 'linux_granted_paths';

  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      if (result != null) {
        await savePathPermission(result);
        return result;
      }

      return null;
    } catch (e, stackTrace) {
      log('Linux文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    return await verifyDirectoryAccess(path);
  }

  @override
  Future<void> savePathPermission(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grantedPaths = prefs.getStringList(_linuxGrantedPathsKey) ?? [];
      
      if (!grantedPaths.contains(path)) {
        grantedPaths.add(path);
        await prefs.setStringList(_linuxGrantedPathsKey, grantedPaths);
        log('Linux路径权限已保存: $path');
      }
    } catch (e) {
      log('保存Linux路径权限失败: $e');
    }
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_linuxGrantedPathsKey) ?? [];
    } catch (e) {
      log('获取Linux已授权路径失败: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_linuxGrantedPathsKey);
      log('Linux权限数据已清除');
    } catch (e) {
      log('清除Linux权限数据失败: $e');
    }
  }
}

/// 默认平台文件选择器服务
class DefaultFilePickerService extends PlatformFilePickerService {
  @override
  Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      return await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );
    } catch (e, stackTrace) {
      log('默认文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> checkPathPermission(String path) async {
    return await verifyDirectoryAccess(path);
  }

  @override
  Future<void> savePathPermission(String path) async {
    // 默认实现不保存权限
  }

  @override
  Future<List<String>> getGrantedPaths() async {
    return [];
  }

  @override
  Future<void> clearAllPermissions() async {
    // 默认实现不需要清除权限
  }
}
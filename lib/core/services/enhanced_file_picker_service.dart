import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'permission_service.dart';

/// 增强的文件选择器服务
/// 集成权限管理和路径持久化功能
class EnhancedFilePickerService {
  /// 选择文件夹并处理权限持久化
  /// 返回选择的文件夹路径，如果取消或失败返回null
  static Future<String?> pickDirectoryWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      // 显示权限说明对话框
      final shouldProceed = await _showPermissionExplanationDialog(context);
      if (!shouldProceed) {
        return null;
      }

      // 首先检查并请求基础权限
      final hasPermission = await PermissionService.hasFilePermission();
      if (!hasPermission) {
        final granted = await _showPermissionDialog(context);
        if (!granted) {
          return null;
        }
      }

      // 选择文件夹
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      if (result != null) {
        // 验证路径访问权限
        final canAccess = await _verifyDirectoryAccess(result);
        if (!canAccess) {
          if (context.mounted) {
            // 显示详细的权限修复指导
            await _showDetailedPermissionGuide(context, result);
          }
          return null;
        }

        // 保存已授权的路径
        await PermissionService.saveGrantedPath(result);

        log('文件夹选择成功并保存权限: $result');
        return result;
      }

      return null;
    } catch (e, stackTrace) {
      log('选择文件夹失败: $e', stackTrace: stackTrace);
      if (context.mounted) {
        _showErrorDialog(context, '选择文件夹失败: $e');
      }
      return null;
    }
  }

  /// 选择文件并处理权限
  static Future<List<String>?> pickFilesWithPermission({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    try {
      // 检查权限
      final hasPermission = await PermissionService.hasFilePermission();
      if (!hasPermission) {
        final granted = await _showPermissionDialog(context);
        if (!granted) {
          return null;
        }
      }

      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle ?? '选择文件',
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        withData: withData,
        withReadStream: withReadStream,
        lockParentWindow: lockParentWindow,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePaths = result.files
            .where((file) => file.path != null)
            .map((file) => file.path!)
            .toList();

        // 保存文件所在目录的权限
        for (final filePath in filePaths) {
          final directory = Directory(filePath).parent.path;
          await PermissionService.saveGrantedPath(directory);
        }

        return filePaths;
      }

      return null;
    } catch (e, stackTrace) {
      log('选择文件失败: $e', stackTrace: stackTrace);
      if (context.mounted) {
        _showErrorDialog(context, '选择文件失败: $e');
      }
      return null;
    }
  }

  /// 检查路径是否有访问权限
  static Future<bool> checkPathPermission(String path) async {
    try {
      // 首先检查是否已保存权限
      final isGranted = await PermissionService.isPathGranted(path);
      if (isGranted) {
        return true;
      }

      // 验证实际访问权限
      return await _verifyDirectoryAccess(path);
    } catch (e, stackTrace) {
      log('检查路径权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 重新请求路径权限
  static Future<bool> requestPathPermission({
    required BuildContext context,
    required String path,
  }) async {
    try {
      if (context.mounted) {
        final shouldRequest = await _showReauthorizeDialog(context, path);
        if (!shouldRequest) {
          return false;
        }
      }

      // 请求系统权限
      final hasPermission = await PermissionService.requestFilePermission();
      if (!hasPermission) {
        return false;
      }

      // 验证路径访问
      final canAccess = await _verifyDirectoryAccess(path);
      if (canAccess) {
        await PermissionService.saveGrantedPath(path);
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      log('重新请求路径权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 显示权限说明对话框
  static Future<bool> _showPermissionExplanationDialog(
      BuildContext context) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('文件夹访问权限说明'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '为了访问您的漫画文件，应用需要以下权限：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('• 文件和媒体访问权限'),
                  Text('• 选择文件夹的持久访问权限'),
                  SizedBox(height: 12),
                  Text(
                    '操作步骤：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. 点击"继续"按钮'),
                  Text('2. 在权限请求中选择"允许"'),
                  Text('3. 在文件选择器中选择漫画文件夹'),
                  Text('4. 确认选择以保存访问权限'),
                  SizedBox(height: 12),
                  Text(
                    '注意：选择文件夹后，应用将获得该文件夹的持久访问权限。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
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
        ) ??
        false;
  }

  /// 显示权限请求对话框
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('需要文件访问权限'),
        content: const Text(
          '为了访问您的漫画文件，应用需要文件访问权限。\n\n'
          '请在接下来的权限请求中选择"允许"。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('授权'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await PermissionService.requestFilePermission();
    }

    return false;
  }

  /// 显示重新授权对话框
  static Future<bool> _showReauthorizeDialog(
      BuildContext context, String path) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('需要重新授权'),
            content: Text(
              '无法访问路径：\n$path\n\n'
              '可能是权限已过期或被撤销，是否重新授权？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('重新授权'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 显示详细的权限修复指导
  static Future<void> _showDetailedPermissionGuide(
      BuildContext context, String path) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限配置指导'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('无法访问选择的路径：'),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  path,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const Text(
                '可能的解决方案：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. 手动授权应用权限：'),
              const Text('   • 打开系统设置'),
              const Text('   • 找到本应用'),
              const Text('   • 开启"文件和媒体"权限'),
              const SizedBox(height: 8),
              const Text('2. 选择应用可访问的文件夹：'),
              const Text('   • 选择Downloads、Documents等公共文件夹'),
              const Text('   • 避免选择系统保护的文件夹'),
              const SizedBox(height: 8),
              const Text('3. 重新选择文件夹：'),
              const Text('   • 返回重新选择其他位置'),
              const Text('   • 确保文件夹包含漫画文件'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
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
  static void _showAccessErrorDialog(BuildContext context, String path) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('访问权限不足'),
        content: Text(
          '无法访问选择的路径：\n$path\n\n'
          '请确保应用有足够的权限访问此位置。',
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

  /// 显示通用错误对话框
  static void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('操作失败'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 验证目录访问权限
  static Future<bool> _verifyDirectoryAccess(String path) async {
    try {
      final directory = Directory(path);

      // 检查目录是否存在
      if (!await directory.exists()) {
        return false;
      }

      // 尝试列出目录内容
      await directory.list(followLinks: false).take(1).toList();
      return true;
    } catch (e) {
      log('验证目录访问失败: $path, 错误: $e');
      return false;
    }
  }

  /// 获取已授权的路径列表
  static Future<List<String>> getGrantedPaths() async {
    return await PermissionService.getGrantedPaths();
  }

  /// 清除所有权限数据
  static Future<void> clearAllPermissions() async {
    await PermissionService.clearAllPermissions();
  }
}

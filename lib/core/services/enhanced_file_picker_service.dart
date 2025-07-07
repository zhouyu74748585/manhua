import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'permission_service.dart';

/// Android目录选择选项枚举
enum AndroidDirectoryOption {
  useCommonPaths, // 使用常用目录
  useAppDirectory, // 使用应用目录
  manualInput, // 手动输入路径
  retryPicker, // 重试文件选择器
}

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

      // Android平台特殊处理
      if (Platform.isAndroid) {
        return await _pickDirectoryAndroid(
          context: context,
          dialogTitle: dialogTitle,
          initialDirectory: initialDirectory,
          lockParentWindow: lockParentWindow,
        );
      }

      // 其他平台使用标准方法
      return await _pickDirectoryStandard(
        context: context,
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );
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

  /// Android平台特殊的文件夹选择处理
  static Future<String?> _pickDirectoryAndroid({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
      log('开始Android平台文件夹选择');

      // 尝试使用标准文件选择器
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? '选择漫画库文件夹',
        initialDirectory: initialDirectory,
        lockParentWindow: lockParentWindow,
      );

      log('文件选择器返回结果: $result');

      // 检查是否返回了根目录（Android 11+的已知问题）
      if (result == '/' || result == null) {
        log('检测到根目录返回，使用备用方案');
        return await _handleAndroidRootDirectoryIssue(context);
      }

      // 验证路径访问权限
      final canAccess = await _verifyDirectoryAccess(result);
      if (!canAccess) {
        log('无法访问选择的路径: $result');
        if (context.mounted) {
          await _showDetailedPermissionGuide(context, result);
        }
        return null;
      }

      // 保存已授权的路径
      await PermissionService.saveGrantedPath(result);
      log('Android文件夹选择成功: $result');
      return result;
    } catch (e, stackTrace) {
      log('Android文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 标准平台的文件夹选择处理
  static Future<String?> _pickDirectoryStandard({
    required BuildContext context,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    try {
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
            await _showDetailedPermissionGuide(context, result);
          }
          return null;
        }

        // 保存已授权的路径
        await PermissionService.saveGrantedPath(result);
        log('标准文件夹选择成功: $result');
        return result;
      }

      return null;
    } catch (e, stackTrace) {
      log('标准文件夹选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 处理Android根目录返回问题的备用方案
  static Future<String?> _handleAndroidRootDirectoryIssue(
      BuildContext context) async {
    try {
      log('开始处理Android根目录问题');

      // 显示问题说明和解决方案选择对话框
      final selectedOption = await _showAndroidDirectoryOptionsDialog(context);
      if (selectedOption == null) {
        return null;
      }

      switch (selectedOption) {
        case AndroidDirectoryOption.useCommonPaths:
          return await _selectFromCommonPaths(context);
        case AndroidDirectoryOption.useAppDirectory:
          return await _useAppDirectory(context);
        case AndroidDirectoryOption.manualInput:
          return await _manualPathInput(context);
        case AndroidDirectoryOption.retryPicker:
          // 重新尝试文件选择器
          return await _retryFilePicker(context);
      }
    } catch (e, stackTrace) {
      log('处理Android根目录问题失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 显示Android目录选择选项对话框
  static Future<AndroidDirectoryOption?> _showAndroidDirectoryOptionsDialog(
      BuildContext context) async {
    if (!context.mounted) return null;

    return await showDialog<AndroidDirectoryOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('文件夹选择问题'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '检测到Android系统的文件选择器返回了无效路径。这是Android 11+系统的已知问题。',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                '请选择以下解决方案之一：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(AndroidDirectoryOption.useCommonPaths),
            child: const Text('选择常用目录'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(AndroidDirectoryOption.useAppDirectory),
            child: const Text('使用应用目录'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(AndroidDirectoryOption.manualInput),
            child: const Text('手动输入路径'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(AndroidDirectoryOption.retryPicker),
            child: const Text('重试选择器'),
          ),
        ],
      ),
    );
  }

  /// 从常用路径中选择
  static Future<String?> _selectFromCommonPaths(BuildContext context) async {
    try {
      log('开始从常用路径选择');

      // 获取Android常用路径
      final commonPaths = await _getAndroidCommonPaths();

      if (commonPaths.isEmpty) {
        if (context.mounted) {
          _showErrorDialog(context, '无法获取常用路径，请尝试其他方案');
        }
        return null;
      }

      // 显示路径选择对话框
      final selectedPath = await _showPathSelectionDialog(context, commonPaths);
      if (selectedPath == null) {
        return null;
      }

      // 验证选择的路径
      final canAccess = await _verifyDirectoryAccess(selectedPath);
      if (!canAccess) {
        if (context.mounted) {
          _showErrorDialog(context, '无法访问选择的路径: $selectedPath');
        }
        return null;
      }

      // 保存路径权限
      await PermissionService.saveGrantedPath(selectedPath);
      log('常用路径选择成功: $selectedPath');
      return selectedPath;
    } catch (e, stackTrace) {
      log('从常用路径选择失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 使用应用目录
  static Future<String?> _useAppDirectory(BuildContext context) async {
    try {
      log('开始使用应用目录');

      // 获取应用的外部存储目录
      final appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        if (context.mounted) {
          _showErrorDialog(context, '无法获取应用存储目录');
        }
        return null;
      }

      final mangaDir = '${appDir.path}/manga';
      final directory = Directory(mangaDir);

      // 创建目录（如果不存在）
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 验证目录访问
      final canAccess = await _verifyDirectoryAccess(mangaDir);
      if (!canAccess) {
        if (context.mounted) {
          _showErrorDialog(context, '无法访问应用目录: $mangaDir');
        }
        return null;
      }

      // 保存路径权限
      await PermissionService.saveGrantedPath(mangaDir);
      log('应用目录使用成功: $mangaDir');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已创建应用漫画目录: $mangaDir'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return mangaDir;
    } catch (e, stackTrace) {
      log('使用应用目录失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 手动输入路径
  static Future<String?> _manualPathInput(BuildContext context) async {
    if (!context.mounted) return null;

    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动输入路径'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请输入漫画文件夹的完整路径：'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '例如: /storage/emulated/0/Download/manga',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '提示：常用路径包括 /storage/emulated/0/Download、/storage/emulated/0/Pictures 等',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isEmpty) {
                return;
              }

              // 验证路径
              final canAccess = await _verifyDirectoryAccess(path);
              if (!canAccess) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('无法访问路径: $path'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // 保存路径权限
              await PermissionService.saveGrantedPath(path);
              Navigator.of(context).pop(path);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 重试文件选择器
  static Future<String?> _retryFilePicker(BuildContext context) async {
    try {
      log('重试文件选择器');

      // 再次尝试标准文件选择器
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择漫画库文件夹（重试）',
      );

      log('重试文件选择器结果: $result');

      if (result == null || result == '/') {
        if (context.mounted) {
          _showErrorDialog(context, '文件选择器仍然返回无效路径，请尝试其他方案');
        }
        return null;
      }

      // 验证路径
      final canAccess = await _verifyDirectoryAccess(result);
      if (!canAccess) {
        if (context.mounted) {
          _showErrorDialog(context, '无法访问选择的路径: $result');
        }
        return null;
      }

      // 保存路径权限
      await PermissionService.saveGrantedPath(result);
      log('重试文件选择器成功: $result');
      return result;
    } catch (e, stackTrace) {
      log('重试文件选择器失败: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 获取Android常用路径
  static Future<List<String>> _getAndroidCommonPaths() async {
    try {
      final commonPaths = <String>[];

      // 标准外部存储路径
      const basePaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Music',
      ];

      // 检查每个路径是否存在且可访问
      for (final path in basePaths) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            // 尝试列出目录内容以验证访问权限
            await directory.list().take(1).toList();
            commonPaths.add(path);
          }
        } catch (e) {
          // 忽略无法访问的路径
          log('路径不可访问: $path, 错误: $e');
        }
      }

      // 尝试获取应用特定的外部目录
      try {
        final appDir = await getExternalStorageDirectory();
        if (appDir != null && await appDir.exists()) {
          commonPaths.add(appDir.path);
        }
      } catch (e) {
        log('获取应用目录失败: $e');
      }

      log('找到 ${commonPaths.length} 个可用的常用路径');
      return commonPaths;
    } catch (e, stackTrace) {
      log('获取Android常用路径失败: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// 显示路径选择对话框
  static Future<String?> _showPathSelectionDialog(
      BuildContext context, List<String> paths) async {
    if (!context.mounted) return null;

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择常用目录'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: paths.length,
            itemBuilder: (context, index) {
              final path = paths[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(
                  path.split('/').last,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  path,
                  style: const TextStyle(fontSize: 12),
                ),
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
        ],
      ),
    );
  }
}

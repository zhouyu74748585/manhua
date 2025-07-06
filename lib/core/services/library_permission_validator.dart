import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/library.dart';
import 'enhanced_file_picker_service.dart';
import 'permission_service.dart';

/// 漫画库权限验证服务
/// 负责验证和恢复漫画库的访问权限
class LibraryPermissionValidator {
  
  /// 验证漫画库的访问权限
  /// 返回验证结果和错误信息
  static Future<LibraryPermissionResult> validateLibraryPermission(
    MangaLibrary library,
  ) async {
    try {
      // 检查库类型
      if (library.type != LibraryType.local) {
        // 网络库和云端库暂时跳过权限检查
        return LibraryPermissionResult.success();
      }

      // 检查路径是否存在
      final directory = Directory(library.path);
      if (!await directory.exists()) {
        return LibraryPermissionResult.error(
          '路径不存在: ${library.path}',
          LibraryPermissionErrorType.pathNotFound,
        );
      }

      // 检查是否有访问权限
      final hasPermission = await EnhancedFilePickerService.checkPathPermission(library.path);
      if (!hasPermission) {
        return LibraryPermissionResult.error(
          '没有访问权限: ${library.path}',
          LibraryPermissionErrorType.permissionDenied,
        );
      }

      // 尝试访问目录
      try {
        await directory.list(followLinks: false).take(1).toList();
        return LibraryPermissionResult.success();
      } catch (e) {
        return LibraryPermissionResult.error(
          '无法访问目录: $e',
          LibraryPermissionErrorType.accessDenied,
        );
      }
    } catch (e, stackTrace) {
      log('验证漫画库权限失败: ${library.path}, 错误: $e', stackTrace: stackTrace);
      return LibraryPermissionResult.error(
        '验证权限时发生错误: $e',
        LibraryPermissionErrorType.unknown,
      );
    }
  }

  /// 批量验证多个漫画库的权限
  static Future<Map<String, LibraryPermissionResult>> validateMultipleLibraries(
    List<MangaLibrary> libraries,
  ) async {
    final results = <String, LibraryPermissionResult>{};
    
    for (final library in libraries) {
      results[library.id] = await validateLibraryPermission(library);
    }
    
    return results;
  }

  /// 尝试修复漫画库权限
  static Future<bool> repairLibraryPermission({
    required BuildContext context,
    required MangaLibrary library,
  }) async {
    try {
      if (library.type != LibraryType.local) {
        return true; // 非本地库不需要修复
      }

      // 显示修复对话框
      final shouldRepair = await _showRepairDialog(context, library);
      if (!shouldRepair) {
        return false;
      }

      // 重新请求权限
      final hasPermission = await EnhancedFilePickerService.requestPathPermission(
        context: context,
        path: library.path,
      );

      if (hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('漫画库 "${library.name}" 权限修复成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('漫画库 "${library.name}" 权限修复失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e, stackTrace) {
      log('修复漫画库权限失败: ${library.path}, 错误: $e', stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修复权限时发生错误: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// 显示权限修复对话框
  static Future<bool> _showRepairDialog(BuildContext context, MangaLibrary library) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限问题'),
        content: Text(
          '漫画库 "${library.name}" 无法访问。\n\n'
          '路径: ${library.path}\n\n'
          '这可能是因为应用权限已过期或被撤销。\n'
          '是否重新授权访问？',
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
    ) ?? false;
  }

  /// 检查应用整体权限状态
  static Future<AppPermissionStatus> checkAppPermissionStatus() async {
    try {
      final hasFilePermission = await PermissionService.hasFilePermission();
      final grantedPaths = await PermissionService.getGrantedPaths();
      
      return AppPermissionStatus(
        hasFilePermission: hasFilePermission,
        grantedPathsCount: grantedPaths.length,
        grantedPaths: grantedPaths,
      );
    } catch (e, stackTrace) {
      log('检查应用权限状态失败: $e', stackTrace: stackTrace);
      return AppPermissionStatus(
        hasFilePermission: false,
        grantedPathsCount: 0,
        grantedPaths: [],
      );
    }
  }

  /// 显示权限状态信息
  static void showPermissionStatus({
    required BuildContext context,
    required AppPermissionStatus status,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('权限状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文件访问权限: ${status.hasFilePermission ? "已授权" : "未授权"}'),
            const SizedBox(height: 8),
            Text('已授权路径数量: ${status.grantedPathsCount}'),
            if (status.grantedPaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('已授权路径:'),
              const SizedBox(height: 4),
              ...status.grantedPaths.map((path) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Text(
                  path,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
          if (!status.hasFilePermission)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await PermissionService.requestFilePermission();
              },
              child: const Text('请求权限'),
            ),
        ],
      ),
    );
  }
}

/// 漫画库权限验证结果
class LibraryPermissionResult {
  final bool isSuccess;
  final String? errorMessage;
  final LibraryPermissionErrorType? errorType;

  const LibraryPermissionResult._({
    required this.isSuccess,
    this.errorMessage,
    this.errorType,
  });

  factory LibraryPermissionResult.success() {
    return const LibraryPermissionResult._(isSuccess: true);
  }

  factory LibraryPermissionResult.error(
    String message,
    LibraryPermissionErrorType type,
  ) {
    return LibraryPermissionResult._(
      isSuccess: false,
      errorMessage: message,
      errorType: type,
    );
  }
}

/// 权限错误类型
enum LibraryPermissionErrorType {
  pathNotFound,      // 路径不存在
  permissionDenied,  // 权限被拒绝
  accessDenied,      // 访问被拒绝
  unknown,           // 未知错误
}

/// 应用权限状态
class AppPermissionStatus {
  final bool hasFilePermission;
  final int grantedPathsCount;
  final List<String> grantedPaths;

  const AppPermissionStatus({
    required this.hasFilePermission,
    required this.grantedPathsCount,
    required this.grantedPaths,
  });
}

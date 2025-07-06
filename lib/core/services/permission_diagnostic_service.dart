import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_service.dart';

/// 权限诊断结果
class PermissionDiagnosticResult {
  final bool hasBasicPermission;
  final bool hasFileAccess;
  final bool hasManageStoragePermission;
  final List<String> accessiblePaths;
  final List<String> issues;
  final List<String> recommendations;
  final int androidVersion;

  const PermissionDiagnosticResult({
    required this.hasBasicPermission,
    required this.hasFileAccess,
    required this.hasManageStoragePermission,
    required this.accessiblePaths,
    required this.issues,
    required this.recommendations,
    required this.androidVersion,
  });

  bool get isHealthy => hasFileAccess && accessiblePaths.isNotEmpty && issues.isEmpty;
}

/// 权限诊断服务
/// 提供详细的权限状态检查和问题诊断
class PermissionDiagnosticService {
  /// 执行完整的权限诊断
  static Future<PermissionDiagnosticResult> runDiagnostic() async {
    final issues = <String>[];
    final recommendations = <String>[];
    final accessiblePaths = <String>[];
    
    // 获取Android版本
    int androidVersion = 0;
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        androidVersion = androidInfo.version.sdkInt;
      } catch (e) {
        issues.add('无法获取Android版本信息: $e');
      }
    }

    // 检查基本权限状态
    bool hasBasicPermission = false;
    bool hasManageStoragePermission = false;
    
    if (Platform.isAndroid) {
      try {
        if (androidVersion >= 33) {
          // Android 13+ 检查细粒度权限
          final photoStatus = await Permission.photos.status;
          final videoStatus = await Permission.videos.status;
          final audioStatus = await Permission.audio.status;
          
          hasBasicPermission = photoStatus.isGranted || videoStatus.isGranted || audioStatus.isGranted;
          
          if (!hasBasicPermission) {
            issues.add('Android 13+ 细粒度媒体权限未授予');
            recommendations.add('请在应用设置中授予照片、视频或音频访问权限');
          }
        } else if (androidVersion >= 30) {
          // Android 11+ 检查作用域存储权限
          final storageStatus = await Permission.storage.status;
          hasBasicPermission = storageStatus.isGranted;
          
          if (!hasBasicPermission) {
            issues.add('Android 11+ 存储权限未授予');
            recommendations.add('请在应用设置中授予存储访问权限');
          }
        } else {
          // Android 10及以下
          final storageStatus = await Permission.storage.status;
          hasBasicPermission = storageStatus.isGranted;
          
          if (!hasBasicPermission) {
            issues.add('传统存储权限未授予');
            recommendations.add('请在应用设置中授予存储访问权限');
          }
        }

        // 检查管理外部存储权限
        final manageStatus = await Permission.manageExternalStorage.status;
        hasManageStoragePermission = manageStatus.isGranted;
        
        if (!hasManageStoragePermission && androidVersion >= 30) {
          recommendations.add('建议授予"管理所有文件"权限以获得完整的文件访问能力');
        }
      } catch (e) {
        issues.add('检查权限状态失败: $e');
      }
    }

    // 测试实际文件访问能力
    bool hasFileAccess = false;
    if (Platform.isAndroid) {
      final testPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Music',
      ];

      for (final path in testPaths) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            final files = await directory.list().take(1).toList();
            accessiblePaths.add(path);
            hasFileAccess = true;
          }
        } catch (e) {
          log('无法访问路径 $path: $e');
        }
      }

      if (!hasFileAccess) {
        issues.add('无法访问任何存储路径');
        recommendations.add('请检查权限设置并重新授予文件访问权限');
      } else if (accessiblePaths.length < 3) {
        issues.add('可访问的存储路径较少 (${accessiblePaths.length}/6)');
        recommendations.add('考虑授予"管理所有文件"权限以访问更多路径');
      }
    } else {
      // iOS 或其他平台
      hasFileAccess = true;
      accessiblePaths.add('iOS文件访问通过文件选择器');
    }

    return PermissionDiagnosticResult(
      hasBasicPermission: hasBasicPermission,
      hasFileAccess: hasFileAccess,
      hasManageStoragePermission: hasManageStoragePermission,
      accessiblePaths: accessiblePaths,
      issues: issues,
      recommendations: recommendations,
      androidVersion: androidVersion,
    );
  }

  /// 尝试自动修复权限问题
  static Future<bool> autoFixPermissions() async {
    try {
      log('开始自动修复权限问题...');
      
      // 首先运行诊断
      final diagnostic = await runDiagnostic();
      
      if (diagnostic.isHealthy) {
        log('权限状态正常，无需修复');
        return true;
      }

      // 尝试请求权限
      final permissionGranted = await PermissionService.requestFilePermission();
      
      if (!permissionGranted) {
        log('权限请求失败');
        return false;
      }

      // 再次运行诊断验证修复结果
      final postFixDiagnostic = await runDiagnostic();
      
      if (postFixDiagnostic.isHealthy) {
        log('权限修复成功');
        return true;
      } else {
        log('权限修复后仍有问题: ${postFixDiagnostic.issues}');
        return false;
      }
    } catch (e, stackTrace) {
      log('自动修复权限失败: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// 生成权限状态报告
  static String generateReport(PermissionDiagnosticResult result) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== 权限诊断报告 ===');
    buffer.writeln('Android版本: ${result.androidVersion}');
    buffer.writeln('基本权限状态: ${result.hasBasicPermission ? "✓ 已授予" : "✗ 未授予"}');
    buffer.writeln('文件访问能力: ${result.hasFileAccess ? "✓ 正常" : "✗ 异常"}');
    buffer.writeln('管理存储权限: ${result.hasManageStoragePermission ? "✓ 已授予" : "✗ 未授予"}');
    
    buffer.writeln('\n可访问路径 (${result.accessiblePaths.length}):');
    for (final path in result.accessiblePaths) {
      buffer.writeln('  ✓ $path');
    }
    
    if (result.issues.isNotEmpty) {
      buffer.writeln('\n发现的问题 (${result.issues.length}):');
      for (int i = 0; i < result.issues.length; i++) {
        buffer.writeln('  ${i + 1}. ${result.issues[i]}');
      }
    }
    
    if (result.recommendations.isNotEmpty) {
      buffer.writeln('\n建议操作 (${result.recommendations.length}):');
      for (int i = 0; i < result.recommendations.length; i++) {
        buffer.writeln('  ${i + 1}. ${result.recommendations[i]}');
      }
    }
    
    buffer.writeln('\n整体状态: ${result.isHealthy ? "✓ 健康" : "✗ 需要修复"}');
    
    return buffer.toString();
  }
}

import 'dart:async';
import 'dart:developer' as dev;

import 'package:smb_connect/smb_connect.dart';

import '../../../data/models/network_config.dart';

/// SMB连接辅助工具类
/// 专门处理SMB协议的连接问题和异常情况
class SMBConnectionHelper {
  /// 测试SMB连接
  ///
  /// [config] 网络配置
  /// [timeout] 超时时间
  /// 返回连接测试结果
  static Future<SMBConnectionResult> testConnection(
    NetworkConfig config, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    SmbConnect? smbClient;
    final stopwatch = Stopwatch()..start();

    try {
      // 创建SMB连接
      smbClient = await SmbConnect.connectAuth(
        host: config.host,
        domain: '',
        username: config.username ?? '',
        password: config.password ?? '',
      ).timeout(timeout);

      // 测试连接是否可用
      await smbClient.listShares().timeout(timeout);

      stopwatch.stop();
      return SMBConnectionResult.success(
        message: 'SMB连接成功',
        responseTime: stopwatch.elapsed,
      );
    } on TimeoutException {
      stopwatch.stop();
      return SMBConnectionResult.failure(
        message: 'SMB连接超时',
        errorCode: 'SMB_TIMEOUT',
        responseTime: stopwatch.elapsed,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      dev.log('SMB连接测试失败: $e', stackTrace: stackTrace);

      // 分析错误类型，包括堆栈跟踪信息
      final errorInfo = _analyzeError(e, stackTrace);
      return SMBConnectionResult.failure(
        message: errorInfo.message,
        errorCode: errorInfo.code,
        responseTime: stopwatch.elapsed,
        details: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    } finally {
      // 确保清理连接
      try {
        await smbClient?.close();
      } catch (e) {
        dev.log('关闭SMB连接时发生错误: $e');
      }
    }
  }

  /// 分析SMB错误
  static _SMBErrorInfo _analyzeError(dynamic error, [StackTrace? stackTrace]) {
    final errorString = error.toString().toLowerCase();
    final stackTraceString = stackTrace?.toString().toLowerCase() ?? '';

    // 添加调试日志
    dev.log('分析SMB错误: $errorString');
    dev.log('堆栈跟踪: $stackTraceString');

    // 首先检查StreamSink错误 - 这是最常见的问题
    // 检查堆栈跟踪中是否包含StreamSink错误或特定的SMB错误路径
    if (stackTraceString.contains('streamsink is closed') ||
        stackTraceString.contains('bad state: streamsink is closed') ||
        errorString.contains('streamsink is closed') ||
        errorString.contains('bad state: streamsink is closed') ||
        stackTraceString.contains('socket_writer.dart') ||
        stackTraceString.contains('smb_transport.dart')) {
      return _SMBErrorInfo(
        code: 'SMB_PROTOCOL_ERROR',
        message: 'SMB协议连接失败 - 可能是服务器兼容性问题',
      );
    }

    if (errorString.contains('authentication') ||
        errorString.contains('login') ||
        errorString.contains('access denied')) {
      return _SMBErrorInfo(
        code: 'SMB_AUTH_FAILED',
        message: 'SMB认证失败，请检查用户名和密码',
      );
    }

    if (errorString.contains('timeout') ||
        errorString.contains('connection timeout')) {
      return _SMBErrorInfo(
        code: 'SMB_TIMEOUT',
        message: 'SMB连接超时，请检查网络连接',
      );
    }

    if (errorString.contains('connection refused') ||
        errorString.contains('no route to host')) {
      return _SMBErrorInfo(
        code: 'SMB_CONNECTION_REFUSED',
        message: 'SMB服务器拒绝连接，请检查服务器状态',
      );
    }

    if (errorString.contains('socket')) {
      return _SMBErrorInfo(
        code: 'SMB_SOCKET_ERROR',
        message: 'SMB网络连接异常，请重试',
      );
    }

    if (errorString.contains('host not found') ||
        errorString.contains('name resolution')) {
      return _SMBErrorInfo(
        code: 'SMB_HOST_NOT_FOUND',
        message: 'SMB服务器地址无法解析，请检查主机名或IP地址',
      );
    }

    // 默认错误
    return _SMBErrorInfo(
      code: 'SMB_UNKNOWN_ERROR',
      message: 'SMB连接失败: ${error.toString()}',
    );
  }

  /// 获取SMB连接建议
  static List<String> getConnectionSuggestions(String errorCode) {
    switch (errorCode) {
      case 'SMB_AUTH_FAILED':
        return [
          '检查用户名和密码是否正确',
          '确认账户未被锁定或禁用',
          '尝试使用域用户格式：domain\\username',
          '检查SMB服务器的认证设置',
        ];

      case 'SMB_TIMEOUT':
        return [
          '检查网络连接是否稳定',
          '确认SMB服务器正在运行',
          '检查防火墙是否阻止了445端口',
          '尝试增加连接超时时间',
        ];

      case 'SMB_CONNECTION_REFUSED':
        return [
          '确认SMB服务已启动',
          '检查端口445是否开放',
          '验证防火墙设置',
          '确认服务器允许SMB连接',
        ];

      case 'SMB_PROTOCOL_ERROR':
        return [
          '检查SMB服务器版本兼容性',
          '尝试使用SMB 1.0协议',
          '检查服务器SMB配置',
          '验证用户名和密码格式',
          '联系系统管理员检查服务器设置',
        ];

      case 'SMB_SOCKET_ERROR':
        return [
          '检查网络连接稳定性',
          '重启网络适配器',
          '尝试重新连接',
          '检查是否存在网络代理',
        ];

      case 'SMB_HOST_NOT_FOUND':
        return [
          '检查主机名或IP地址是否正确',
          '确认DNS解析正常',
          '尝试使用IP地址而不是主机名',
          '检查网络连接',
        ];

      default:
        return [
          '检查SMB服务器配置',
          '验证网络连接',
          '查看服务器日志',
          '联系系统管理员',
        ];
    }
  }
}

/// SMB连接测试结果
class SMBConnectionResult {
  final bool isSuccess;
  final String message;
  final String? errorCode;
  final Duration? responseTime;
  final Map<String, dynamic>? details;

  const SMBConnectionResult({
    required this.isSuccess,
    required this.message,
    this.errorCode,
    this.responseTime,
    this.details,
  });

  factory SMBConnectionResult.success({
    required String message,
    Duration? responseTime,
    Map<String, dynamic>? details,
  }) {
    return SMBConnectionResult(
      isSuccess: true,
      message: message,
      responseTime: responseTime,
      details: details,
    );
  }

  factory SMBConnectionResult.failure({
    required String message,
    String? errorCode,
    Duration? responseTime,
    Map<String, dynamic>? details,
  }) {
    return SMBConnectionResult(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
      responseTime: responseTime,
      details: details,
    );
  }
}

/// SMB错误信息
class _SMBErrorInfo {
  final String code;
  final String message;

  const _SMBErrorInfo({
    required this.code,
    required this.message,
  });
}

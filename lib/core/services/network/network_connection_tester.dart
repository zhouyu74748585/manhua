import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../data/models/network_config.dart';
import 'network_file_system.dart';
import 'network_file_system_factory.dart';
import 'smb_connection_helper.dart';

/// 网络连接测试结果
class NetworkConnectionTestResult {
  final bool isSuccess;
  final String message;
  final Duration? responseTime;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const NetworkConnectionTestResult({
    required this.isSuccess,
    required this.message,
    this.responseTime,
    this.errorCode,
    this.details,
  });

  factory NetworkConnectionTestResult.success({
    required String message,
    Duration? responseTime,
    Map<String, dynamic>? details,
  }) {
    return NetworkConnectionTestResult(
      isSuccess: true,
      message: message,
      responseTime: responseTime,
      details: details,
    );
  }

  factory NetworkConnectionTestResult.failure({
    required String message,
    String? errorCode,
    Map<String, dynamic>? details,
  }) {
    return NetworkConnectionTestResult(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
      details: details,
    );
  }
}

/// 网络连接测试器
class NetworkConnectionTester {
  static const Duration _defaultTimeout = Duration(seconds: 10);

  /// 测试网络连接
  static Future<NetworkConnectionTestResult> testConnection(
    NetworkConfig config, {
    Duration timeout = _defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 基础连接测试
      final basicTest = await _testBasicConnection(config, timeout);
      if (!basicTest.isSuccess) {
        return basicTest;
      }

      // 协议特定测试
      final protocolTest = await _testProtocolSpecific(config, timeout);
      if (!protocolTest.isSuccess) {
        return protocolTest;
      }

      stopwatch.stop();
      return NetworkConnectionTestResult.success(
        message: '连接测试成功',
        responseTime: stopwatch.elapsed,
        details: {
          'protocol': config.protocol,
          'host': config.host,
          'port': config.port,
        },
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      dev.log('网络连接测试失败: $e', stackTrace: stackTrace);

      return NetworkConnectionTestResult.failure(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        details: {
          'protocol': config.protocol,
          'host': config.host,
          'port': config.port,
          'error': e.toString(),
        },
      );
    }
  }

  /// 基础连接测试（TCP连接）
  static Future<NetworkConnectionTestResult> _testBasicConnection(
    NetworkConfig config,
    Duration timeout,
  ) async {
    try {
      final socket = await Socket.connect(
        config.host,
        config.port ?? 80,
        timeout: timeout,
      );
      await socket.close();

      return NetworkConnectionTestResult.success(
        message: 'TCP连接成功',
        details: {'test': 'basic_tcp'},
      );
    } on SocketException catch (e) {
      return NetworkConnectionTestResult.failure(
        message: '无法连接到服务器: ${e.message}',
        errorCode: 'SOCKET_ERROR',
        details: {'test': 'basic_tcp', 'socket_error': e.message},
      );
    } on TimeoutException {
      return NetworkConnectionTestResult.failure(
        message: '连接超时',
        errorCode: 'TIMEOUT',
        details: {'test': 'basic_tcp'},
      );
    }
  }

  /// 协议特定测试
  static Future<NetworkConnectionTestResult> _testProtocolSpecific(
    NetworkConfig config,
    Duration timeout,
  ) async {
    // 对于SMB协议，使用专门的测试方法
    if (config.protocol == NetworkProtocol.smb) {
      return await _testSMBProtocol(config, timeout);
    }

    // 其他协议使用通用测试方法
    return await _testGenericProtocol(config, timeout);
  }

  /// SMB协议专门测试
  static Future<NetworkConnectionTestResult> _testSMBProtocol(
    NetworkConfig config,
    Duration timeout,
  ) async {
    try {
      final result =
          await SMBConnectionHelper.testConnection(config, timeout: timeout);

      if (result.isSuccess) {
        return NetworkConnectionTestResult.success(
          message: result.message,
          responseTime: result.responseTime,
          details: {
            'test': 'smb_specific',
            'protocol': 'smb',
            ...?result.details,
          },
        );
      } else {
        return NetworkConnectionTestResult.failure(
          message: result.message,
          errorCode: result.errorCode,
          details: {
            'test': 'smb_specific',
            'protocol': 'smb',
            'suggestions': SMBConnectionHelper.getConnectionSuggestions(
                result.errorCode ?? ''),
            ...?result.details,
          },
        );
      }
    } catch (e, stackTrace) {
      dev.log('SMB协议测试失败: $e', stackTrace: stackTrace);
      return NetworkConnectionTestResult.failure(
        message: 'SMB协议测试异常: ${e.toString()}',
        errorCode: 'SMB_TEST_ERROR',
        details: {'test': 'smb_specific', 'error': e.toString()},
      );
    }
  }

  /// 通用协议测试
  static Future<NetworkConnectionTestResult> _testGenericProtocol(
    NetworkConfig config,
    Duration timeout,
  ) async {
    NetworkFileSystem? fileSystem;
    try {
      fileSystem = NetworkFileSystemFactory.create(config);

      // 先建立连接
      await fileSystem.connect().timeout(timeout);

      // 尝试列出根目录
      await fileSystem.listDirectory('/').timeout(timeout);

      return NetworkConnectionTestResult.success(
        message: '协议测试成功',
        details: {
          'test': 'protocol_specific',
          'protocol': config.protocol.toString()
        },
      );
    } on TimeoutException {
      return NetworkConnectionTestResult.failure(
        message: '协议测试超时',
        errorCode: 'PROTOCOL_TIMEOUT',
        details: {'test': 'protocol_specific'},
      );
    } on DioException catch (e, stackTrace) {
      dev.log('协议测试失败: $e', stackTrace: stackTrace);
      return NetworkConnectionTestResult.failure(
        message: '协议测试失败: ${_getDioErrorMessage(e)}',
        errorCode: 'PROTOCOL_ERROR',
        details: {
          'test': 'protocol_specific',
          'dio_error': e.type.toString(),
          'status_code': e.response?.statusCode,
        },
      );
    } catch (e, stackTrace) {
      dev.log('协议测试失败: $e', stackTrace: stackTrace);
      return NetworkConnectionTestResult.failure(
        message: '协议测试失败: ${e.toString()}',
        errorCode: 'PROTOCOL_ERROR',
        details: {'test': 'protocol_specific', 'error': e.toString()},
      );
    } finally {
      // 确保断开连接，释放资源
      try {
        await fileSystem?.disconnect();
      } catch (e) {
        dev.log('断开连接时发生错误: $e');
      }
    }
  }

  /// 获取错误消息
  static String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return '网络连接失败: ${error.message}';
    } else if (error is TimeoutException) {
      return '连接超时，请检查网络设置';
    } else if (error is DioException) {
      return _getDioErrorMessage(error);
    } else if (error is FormatException) {
      return '配置格式错误: ${error.message}';
    } else {
      return '未知错误: ${error.toString()}';
    }
  }

  /// 获取Dio错误消息
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '发送超时';
      case DioExceptionType.receiveTimeout:
        return '接收超时';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return '认证失败，请检查用户名和密码';
        } else if (statusCode == 403) {
          return '访问被拒绝，权限不足';
        } else if (statusCode == 404) {
          return '路径不存在';
        } else {
          return 'HTTP错误: $statusCode';
        }
      case DioExceptionType.cancel:
        return '请求被取消';
      case DioExceptionType.connectionError:
        return '连接错误，请检查网络设置';
      case DioExceptionType.unknown:
        return '未知网络错误';
      default:
        return '网络请求失败';
    }
  }

  /// 获取错误代码
  static String _getErrorCode(dynamic error) {
    if (error is SocketException) {
      return 'SOCKET_ERROR';
    } else if (error is TimeoutException) {
      return 'TIMEOUT';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'TIMEOUT';
        case DioExceptionType.badResponse:
          return 'HTTP_${error.response?.statusCode ?? 'UNKNOWN'}';
        case DioExceptionType.connectionError:
          return 'CONNECTION_ERROR';
        default:
          return 'NETWORK_ERROR';
      }
    } else {
      return 'UNKNOWN_ERROR';
    }
  }

  /// 测试多个配置
  static Future<Map<String, NetworkConnectionTestResult>> testMultipleConfigs(
    List<NetworkConfig> configs, {
    Duration timeout = _defaultTimeout,
  }) async {
    final results = <String, NetworkConnectionTestResult>{};

    for (final config in configs) {
      final key = '${config.protocol}://${config.host}:${config.port}';
      results[key] = await testConnection(config, timeout: timeout);
    }

    return results;
  }

  /// 获取连接建议
  static List<String> getConnectionSuggestions(
      NetworkConnectionTestResult result) {
    final suggestions = <String>[];

    if (!result.isSuccess) {
      // 如果结果中已包含建议，直接使用
      if (result.details?['suggestions'] is List<String>) {
        return List<String>.from(result.details!['suggestions']);
      }

      switch (result.errorCode) {
        case 'SOCKET_ERROR':
          suggestions.addAll([
            '检查服务器地址和端口是否正确',
            '确认服务器正在运行',
            '检查防火墙设置',
            '尝试使用其他网络连接',
          ]);
          break;
        case 'TIMEOUT':
        case 'PROTOCOL_TIMEOUT':
          suggestions.addAll([
            '检查网络连接是否稳定',
            '尝试增加超时时间',
            '确认服务器响应正常',
            '检查是否存在网络代理',
          ]);
          break;
        case 'HTTP_401':
          suggestions.addAll([
            '检查用户名和密码是否正确',
            '确认账户未被锁定',
            '尝试重新输入认证信息',
          ]);
          break;
        case 'HTTP_403':
          suggestions.addAll([
            '检查账户权限设置',
            '确认有访问该路径的权限',
            '联系管理员获取访问权限',
          ]);
          break;
        case 'HTTP_404':
          suggestions.addAll([
            '检查路径是否存在',
            '确认路径格式正确',
            '尝试使用根路径进行测试',
          ]);
          break;
        // SMB特定错误代码
        case 'SMB_AUTH_FAILED':
        case 'SMB_CONNECTION_ERROR':
        case 'SMB_PING_FAILED':
        case 'SMB_SOCKET_ERROR':
        case 'SMB_TIMEOUT':
        case 'SMB_CONNECTION_REFUSED':
        case 'SMB_HOST_NOT_FOUND':
        case 'SMB_TEST_ERROR':
          // 使用SMB连接辅助工具的建议
          suggestions.addAll(
              SMBConnectionHelper.getConnectionSuggestions(result.errorCode!));
          break;
        default:
          suggestions.addAll([
            '检查网络配置是否正确',
            '尝试重新配置连接',
            '联系技术支持获取帮助',
          ]);
      }
    }

    return suggestions;
  }
}

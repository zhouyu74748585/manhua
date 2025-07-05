import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';

/// HTTP连接池管理器
///
/// 负责管理HTTP连接的创建、复用和清理，提升网络通信效率
class ConnectionPoolManager {
  static ConnectionPoolManager? _instance;
  static ConnectionPoolManager get instance =>
      _instance ??= ConnectionPoolManager._();

  ConnectionPoolManager._();

  // 配置参数
  static const int _maxConnections = 10;
  static const int _maxConnectionsPerHost = 5;
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(minutes: 10);
  static const Duration _sendTimeout = Duration(minutes: 5);
  static const Duration _idleTimeout = Duration(minutes: 5);
  static const Duration _cleanupInterval = Duration(minutes: 2);

  // 连接池存储
  final Map<String, Dio> _connectionPool = {};
  final Map<String, DateTime> _lastUsed = {};
  final Map<String, int> _connectionCount = {};

  // 清理定时器
  Timer? _cleanupTimer;
  bool _isDisposed = false;

  /// 初始化连接池管理器
  void initialize() {
    if (_isDisposed) {
      // 重置状态以支持重新初始化
      _isDisposed = false;
      _connectionPool.clear();
      _lastUsed.clear();
      _connectionCount.clear();
      _cleanupTimer?.cancel();
    }

    _startCleanupTimer();
    log('ConnectionPoolManager初始化完成');
  }

  /// 获取连接
  ///
  /// [baseUrl] 目标服务器地址
  /// [headers] 自定义请求头
  /// 返回配置好的Dio实例
  Dio getConnection(String baseUrl, {Map<String, String>? headers}) {
    if (_isDisposed) {
      throw StateError('ConnectionPoolManager已释放');
    }

    final host = _extractHost(baseUrl);

    // 检查连接池中是否已有可用连接
    if (_connectionPool.containsKey(host)) {
      _lastUsed[host] = DateTime.now();
      final dio = _connectionPool[host]!;

      // 更新请求头
      if (headers != null) {
        dio.options.headers.addAll(headers);
      }

      log('复用现有连接: $host');
      return dio;
    }

    // 检查连接数限制
    if (_connectionPool.length >= _maxConnections) {
      _cleanupOldestConnection();
    }

    final hostConnections = _connectionCount[host] ?? 0;
    if (hostConnections >= _maxConnectionsPerHost) {
      _cleanupHostConnections(host);
    }

    // 创建新连接
    final dio = _createNewConnection(baseUrl, headers: headers);
    _connectionPool[host] = dio;
    _lastUsed[host] = DateTime.now();
    _connectionCount[host] = hostConnections + 1;

    log('创建新连接: $host (总连接数: ${_connectionPool.length})');
    return dio;
  }

  /// 释放指定主机的连接
  void releaseConnection(String baseUrl) {
    if (_isDisposed) return;

    final host = _extractHost(baseUrl);

    if (_connectionPool.containsKey(host)) {
      _connectionPool[host]?.close();
      _connectionPool.remove(host);
      _lastUsed.remove(host);

      final count = _connectionCount[host] ?? 0;
      if (count > 1) {
        _connectionCount[host] = count - 1;
      } else {
        _connectionCount.remove(host);
      }

      log('释放连接: $host');
    }
  }

  /// 获取连接池状态
  ConnectionPoolStats getStats() {
    return ConnectionPoolStats(
      totalConnections: _connectionPool.length,
      connectionsByHost: Map.from(_connectionCount),
      lastUsedTimes: Map.from(_lastUsed),
    );
  }

  /// 清理空闲连接
  void cleanupIdleConnections() {
    if (_isDisposed) return;

    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _lastUsed.entries) {
      final host = entry.key;
      final lastUsed = entry.value;

      if (now.difference(lastUsed) > _idleTimeout) {
        toRemove.add(host);
      }
    }

    for (final host in toRemove) {
      _connectionPool[host]?.close();
      _connectionPool.remove(host);
      _lastUsed.remove(host);
      _connectionCount.remove(host);
      log('清理空闲连接: $host');
    }

    if (toRemove.isNotEmpty) {
      log('清理了${toRemove.length}个空闲连接');
    }
  }

  /// 释放所有资源
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    // 停止清理定时器
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    // 关闭所有连接
    for (final dio in _connectionPool.values) {
      try {
        dio.close();
      } catch (e) {
        log('关闭连接时发生错误: $e');
      }
    }

    // 清理数据
    _connectionPool.clear();
    _lastUsed.clear();
    _connectionCount.clear();

    log('ConnectionPoolManager资源释放完成');
  }

  /// 创建新的Dio连接
  Dio _createNewConnection(String baseUrl, {Map<String, String>? headers}) {
    final dio = Dio();

    // 基础配置
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _connectionTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'MangaReader-MultiDeviceSync/1.0',
        ...?headers,
      },
    );

    // 添加拦截器
    dio.interceptors.add(_createLoggingInterceptor());
    dio.interceptors.add(_createRetryInterceptor());

    return dio;
  }

  /// 创建日志拦截器
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        log('HTTP请求: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        log('HTTP响应: ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        log('HTTP错误: ${error.message} ${error.requestOptions.uri}');
        handler.next(error);
      },
    );
  }

  /// 创建重试拦截器
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // 对于网络错误进行重试
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          final options = error.requestOptions;
          final retryCount = options.extra['retryCount'] ?? 0;

          if (retryCount < 3) {
            options.extra['retryCount'] = retryCount + 1;

            // 指数退避延迟
            final delay =
                Duration(milliseconds: (1000 * (retryCount + 1)).round());
            await Future.delayed(delay);

            log('重试HTTP请求 (第${retryCount + 1}次): ${options.uri}');

            try {
              final dio = error.requestOptions.extra['dio'] as Dio?;
              if (dio != null) {
                final response = await dio.fetch(options);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              log('重试失败: $e');
            }
          }
        }

        handler.next(error);
      },
    );
  }

  /// 提取主机名
  String _extractHost(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}:${uri.port}';
    } catch (e) {
      log('解析URL失败: $url, 错误: $e');
      return url;
    }
  }

  /// 清理最旧的连接
  void _cleanupOldestConnection() {
    if (_lastUsed.isEmpty) return;

    String? oldestHost;
    DateTime? oldestTime;

    for (final entry in _lastUsed.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestHost = entry.key;
        oldestTime = entry.value;
      }
    }

    if (oldestHost != null) {
      releaseConnection(oldestHost);
    }
  }

  /// 清理指定主机的连接
  void _cleanupHostConnections(String host) {
    releaseConnection(host);
  }

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      cleanupIdleConnections();
    });
  }
}

/// 连接池统计信息
class ConnectionPoolStats {
  final int totalConnections;
  final Map<String, int> connectionsByHost;
  final Map<String, DateTime> lastUsedTimes;

  const ConnectionPoolStats({
    required this.totalConnections,
    required this.connectionsByHost,
    required this.lastUsedTimes,
  });

  @override
  String toString() {
    return 'ConnectionPoolStats(总连接数: $totalConnections, 各主机连接数: $connectionsByHost)';
  }
}

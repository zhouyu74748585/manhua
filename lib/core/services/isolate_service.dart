import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

/// Isolate服务，用于在后台线程执行耗时操作
class IsolateService {
  static final Map<String, Isolate> _isolates = {};
  static final Map<String, SendPort> _sendPorts = {};
  static final Map<String, ReceivePort> _receivePorts = {};
  static final Map<String, Stream<dynamic>> _broadcastStreams = {};

  /// 启动一个新的Isolate
  static Future<String> startIsolate({
    required String name,
    required void Function(Map<String, dynamic>) entryPoint,
    dynamic message,
    bool allowConcurrent = false,
  }) async {
    // 如果不允许并发且已存在同名isolate，则停止旧的
    if (!allowConcurrent && _isolates.containsKey(name)) {
      await stopIsolate(name);
    }

    // 如果允许并发，生成唯一名称
    String uniqueName = name;
    if (allowConcurrent) {
      int counter = 1;
      while (_isolates.containsKey(uniqueName)) {
        uniqueName = '${name}_$counter';
        counter++;
      }
    }

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      entryPoint,
      {
        'sendPort': receivePort.sendPort,
        'message': message,
      },
    );

    _isolates[uniqueName] = isolate;
    _receivePorts[uniqueName] = receivePort;

    // 将ReceivePort转换为广播流，避免多次监听问题
    final broadcastStream = receivePort.asBroadcastStream();
    _broadcastStreams[uniqueName] = broadcastStream;

    // 等待Isolate发送SendPort
    final completer = Completer<SendPort>();
    late StreamSubscription subscription;

    subscription = broadcastStream.listen((data) {
      if (data is SendPort) {
        _sendPorts[uniqueName] = data;
        completer.complete(data);
        subscription.cancel();
      }
    });

    await completer.future;
    log('Isolate [$uniqueName] 启动成功');
    return uniqueName;
  }

  /// 向Isolate发送消息
  static void sendMessage(String name, dynamic message) {
    final sendPort = _sendPorts[name];
    if (sendPort != null) {
      sendPort.send(message);
    } else {
      log('Isolate [$name] 的SendPort不存在');
    }
  }

  /// 监听Isolate的消息
  static Stream<dynamic> listenToIsolate(String name) {
    final broadcastStream = _broadcastStreams[name];
    if (broadcastStream != null) {
      return broadcastStream;
    } else {
      log('Isolate [$name] 的BroadcastStream不存在');
      return const Stream.empty();
    }
  }

  /// 停止Isolate
  static Future<void> stopIsolate(String name) async {
    final isolate = _isolates[name];
    final receivePort = _receivePorts[name];

    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      _isolates.remove(name);
      log('Isolate [$name] 已停止');
    }

    if (receivePort != null) {
      receivePort.close();
      _receivePorts.remove(name);
    }

    _sendPorts.remove(name);
    _broadcastStreams.remove(name);
  }

  /// 停止所有Isolate
  static Future<void> stopAllIsolates() async {
    final names = List<String>.from(_isolates.keys);
    for (final name in names) {
      await stopIsolate(name);
    }
  }

  /// 检查Isolate是否正在运行
  static bool isIsolateRunning(String name) {
    return _isolates.containsKey(name);
  }

  /// 检查指定类型的Isolate是否正在运行
  static bool isIsolateTypeRunning(String namePrefix) {
    return _isolates.keys.any((name) => name.startsWith(namePrefix));
  }

  /// 获取指定类型的所有运行中的Isolate名称
  static List<String> getRunningIsolatesByType(String namePrefix) {
    return _isolates.keys.where((name) => name.startsWith(namePrefix)).toList();
  }

  /// 停止指定类型的所有Isolate
  static Future<void> stopIsolatesByType(String namePrefix) async {
    final names = getRunningIsolatesByType(namePrefix);
    for (final name in names) {
      await stopIsolate(name);
    }
  }
}

/// Isolate消息类型
enum IsolateMessageType {
  start,
  progress,
  batchProcessed,
  complete,
  error,
  stop,
}

/// Isolate消息
class IsolateMessage {
  final IsolateMessageType type;
  final dynamic data;
  final String? error;
  final double? progress;

  const IsolateMessage({
    required this.type,
    this.data,
    this.error,
    this.progress,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'data': data,
        'error': error,
        'progress': progress,
      };

  factory IsolateMessage.fromJson(Map<String, dynamic> json) {
    return IsolateMessage(
      type: IsolateMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IsolateMessageType.progress,
      ),
      data: json['data'],
      error: json['error'],
      progress: json['progress']?.toDouble(),
    );
  }
}

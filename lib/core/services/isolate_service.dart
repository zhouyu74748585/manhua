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
  }) async {
    if (_isolates.containsKey(name)) {
      await stopIsolate(name);
    }

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      entryPoint,
      {
        'sendPort': receivePort.sendPort,
        'message': message,
      },
    );

    _isolates[name] = isolate;
    _receivePorts[name] = receivePort;

    // 将ReceivePort转换为广播流，避免多次监听问题
    final broadcastStream = receivePort.asBroadcastStream();
    _broadcastStreams[name] = broadcastStream;

    // 等待Isolate发送SendPort
    final completer = Completer<SendPort>();
    late StreamSubscription subscription;

    subscription = broadcastStream.listen((data) {
      if (data is SendPort) {
        _sendPorts[name] = data;
        completer.complete(data);
        subscription.cancel();
      }
    });

    await completer.future;
    log('Isolate [$name] 启动成功');
    return name;
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

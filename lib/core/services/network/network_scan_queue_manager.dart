import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:crypto/crypto.dart';

import '../../../data/models/library.dart';
import '../../../data/models/manga.dart';
import '../../../data/models/manga_page.dart';
import '../../../data/models/network_config.dart';
import 'network_file_system.dart';
import 'network_file_system_factory.dart';

/// 网络扫描队列管理器
/// 负责管理多线程网络漫画库扫描任务
class NetworkScanQueueManager {
  static NetworkScanQueueManager? _instance;
  static NetworkScanQueueManager get instance =>
      _instance ??= NetworkScanQueueManager._();

  NetworkScanQueueManager._();

  final Map<String, NetworkScanTask> _activeTasks = {};
  final StreamController<NetworkScanProgress> _progressController =
      StreamController.broadcast();

  /// 扫描进度流
  Stream<NetworkScanProgress> get progressStream => _progressController.stream;

  /// 开始扫描网络漫画库
  /// [library] 要扫描的漫画库
  /// [config] 网络配置
  /// [taskId] 可选的任务ID，如果不提供则自动生成
  /// 返回扫描任务ID
  Future<String> startScan(MangaLibrary library, NetworkConfig config,
      {String? taskId}) async {
    // 检查是否已有相同库的扫描任务
    final existingTask = _activeTasks.values
        .where(
          (task) => task.libraryId == library.id,
        )
        .firstOrNull;

    if (existingTask != null) {
      throw NetworkScanException('漫画库 ${library.name} 正在扫描中，请等待完成');
    }

    final finalTaskId =
        taskId ?? '${library.id}_${DateTime.now().millisecondsSinceEpoch}';

    // 创建新的扫描任务
    final task = NetworkScanTask(
      id: finalTaskId,
      libraryId: library.id,
      libraryName: library.name,
      config: config,
    );

    _activeTasks[finalTaskId] = task;

    // 在独立的Isolate中执行扫描
    _startScanInIsolate(task);

    return finalTaskId;
  }

  /// 取消扫描任务
  Future<void> cancelScan(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancel();
      _activeTasks.remove(taskId);

      _progressController.add(NetworkScanProgress(
        taskId: taskId,
        libraryId: task.libraryId,
        status: NetworkScanStatus.cancelled,
        message: '扫描已取消',
      ));
    }
  }

  /// 获取任务状态
  NetworkScanTask? getTask(String taskId) {
    return _activeTasks[taskId];
  }

  /// 获取所有活动任务
  List<NetworkScanTask> getActiveTasks() {
    return _activeTasks.values.toList();
  }

  /// 检查库是否正在扫描
  bool isLibraryScanning(String libraryId) {
    return _activeTasks.values.any((task) => task.libraryId == libraryId);
  }

  /// 在Isolate中启动扫描
  Future<void> _startScanInIsolate(NetworkScanTask task) async {
    try {
      // 创建接收端口
      final receivePort = ReceivePort();

      // 启动Isolate
      final isolate = await Isolate.spawn(
        _scanIsolateEntryPoint,
        _ScanIsolateMessage(
          sendPort: receivePort.sendPort,
          task: task,
        ),
      );

      // 监听Isolate消息
      receivePort.listen((message) {
        if (message is NetworkScanProgress) {
          _progressController.add(message);

          // 如果扫描完成或失败，清理任务
          if (message.status == NetworkScanStatus.completed ||
              message.status == NetworkScanStatus.failed ||
              message.status == NetworkScanStatus.cancelled) {
            _activeTasks.remove(task.id);
            receivePort.close();
            isolate.kill();
          }
        }
      });
    } catch (e) {
      _activeTasks.remove(task.id);
      _progressController.add(NetworkScanProgress(
        taskId: task.id,
        libraryId: task.libraryId,
        status: NetworkScanStatus.failed,
        message: '启动扫描失败: $e',
      ));
    }
  }

  /// 释放资源
  void dispose() {
    for (final task in _activeTasks.values) {
      task.cancel();
    }
    _activeTasks.clear();
    _progressController.close();
  }
}

/// Isolate入口点
void _scanIsolateEntryPoint(_ScanIsolateMessage message) async {
  final sendPort = message.sendPort;
  final task = message.task;
  NetworkFileSystem? fileSystem;

  try {
    // 发送开始扫描消息
    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.scanning,
      message: '开始扫描网络漫画库...',
    ));

    // 创建网络文件系统
    fileSystem = NetworkFileSystemFactory.create(task.config);

    // 连接到服务器（带重试机制）
    await _connectWithRetry(fileSystem, task, sendPort);

    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.scanning,
      message: '已连接到服务器，开始扫描文件...',
    ));

    // 扫描根目录
    final results = await _scanDirectory(fileSystem, "/", task, sendPort);

    // 发送完成消息
    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.completed,
      message: '扫描完成，发现 ${results.length} 个漫画',
      foundMangas: results,
      scannedCount: results.length,
    ));
  } catch (e) {
    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.failed,
      message: '扫描失败: $e',
    ));
  } finally {
    // 确保断开连接
    if (fileSystem != null) {
      try {
        await fileSystem.disconnect();
      } catch (e) {
        // 忽略断开连接时的错误
      }
    }
  }
}

/// 递归扫描目录
Future<List<NetworkMangaInfo>> _scanDirectory(
  NetworkFileSystem fileSystem,
  String path,
  NetworkScanTask task,
  SendPort sendPort,
) async {
  final results = <NetworkMangaInfo>[];

  try {
    // 发送当前扫描目录信息
    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.scanning,
      message: '正在扫描目录: $path',
    ));

    final files = await fileSystem.listDirectory(path);

    for (final file in files) {
      // 检查是否取消
      if (task.isCancelled) {
        break;
      }

      if (file.isDirectory) {
        // 发送子目录扫描信息
        sendPort.send(NetworkScanProgress(
          taskId: task.id,
          libraryId: task.libraryId,
          status: NetworkScanStatus.scanning,
          message: '扫描子目录: ${file.name}',
          scannedCount: results.length,
        ));

        // 递归扫描子目录
        final subResults =
            await _scanDirectory(fileSystem, file.path, task, sendPort);
        results.addAll(subResults);
      } else if (file.isMangaFile) {
        // 发现漫画文件
        final networkMangaInfo = NetworkMangaInfo(
          name: file.name,
          path: file.path,
          size: file.size,
          lastModified: file.lastModified,
        );
        results.add(networkMangaInfo);

        // 实时处理：立即创建漫画记录并获取封面
        try {
          final processedManga = await _processAndCreateMangaRecord(
              networkMangaInfo, task.libraryId, fileSystem);

          if (processedManga != null) {
            // 发送实时处理结果
            sendPort.send(NetworkScanProgress(
              taskId: task.id,
              libraryId: task.libraryId,
              status: NetworkScanStatus.scanning,
              message: '处理漫画文件: ${file.name}',
              scannedCount: results.length,
              processedMangas: [processedManga], // 发送处理过的漫画
            ));
          }
        } catch (e) {
          dev.log('处理漫画文件失败: ${file.name}, 错误: $e');
          // 即使处理失败，也发送进度更新
          sendPort.send(NetworkScanProgress(
            taskId: task.id,
            libraryId: task.libraryId,
            status: NetworkScanStatus.scanning,
            message: '发现漫画文件: ${file.name}',
            scannedCount: results.length,
          ));
        }
      }
    }

    // 检查目录是否包含图片（可能是漫画目录）
    if (NetworkFileSystem.isPotentialMangaDirectory(files)) {
      final imageFiles = files.where((f) => f.isImageFile).toList();
      if (imageFiles.isNotEmpty) {
        final directoryName =
            path.split('/').last.isEmpty ? 'Root' : path.split('/').last;

        final networkMangaInfo = NetworkMangaInfo(
          name: directoryName,
          path: path,
          size: imageFiles.fold(0, (sum, f) => sum + f.size),
          isDirectory: true,
          imageCount: imageFiles.length,
          lastModified:
              imageFiles.isNotEmpty ? imageFiles.first.lastModified : null,
        );
        results.add(networkMangaInfo);

        // 实时处理：立即创建漫画记录并获取封面
        try {
          final processedManga = await _processAndCreateMangaRecord(
              networkMangaInfo, task.libraryId, fileSystem);

          if (processedManga != null) {
            // 发送实时处理结果
            sendPort.send(NetworkScanProgress(
              taskId: task.id,
              libraryId: task.libraryId,
              status: NetworkScanStatus.scanning,
              message: '处理漫画目录: $directoryName (${imageFiles.length}张图片)',
              scannedCount: results.length,
              processedMangas: [processedManga], // 发送处理过的漫画
            ));
          }
        } catch (e) {
          dev.log('处理漫画目录失败: $directoryName, 错误: $e');
          // 即使处理失败，也发送进度更新
          sendPort.send(NetworkScanProgress(
            taskId: task.id,
            libraryId: task.libraryId,
            status: NetworkScanStatus.scanning,
            message: '发现漫画目录: $directoryName (${imageFiles.length}张图片)',
            scannedCount: results.length,
          ));
        }
      }
    }
  } catch (e) {
    // 记录错误但继续扫描其他目录
    sendPort.send(NetworkScanProgress(
      taskId: task.id,
      libraryId: task.libraryId,
      status: NetworkScanStatus.scanning,
      message: '扫描目录失败: $path - $e',
    ));
  }

  return results;
}

/// 带重试机制的连接方法
Future<void> _connectWithRetry(NetworkFileSystem fileSystem,
    NetworkScanTask task, SendPort sendPort) async {
  const maxRetries = 3;
  const retryDelay = Duration(seconds: 2);

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      sendPort.send(NetworkScanProgress(
        taskId: task.id,
        libraryId: task.libraryId,
        status: NetworkScanStatus.scanning,
        message: '正在连接服务器... (尝试 $attempt/$maxRetries)',
      ));

      await fileSystem.connect();
      return; // 连接成功，退出重试循环
    } catch (e) {
      if (attempt == maxRetries) {
        // 最后一次尝试失败，抛出异常
        throw Exception('连接失败，已重试 $maxRetries 次: $e');
      }

      sendPort.send(NetworkScanProgress(
        taskId: task.id,
        libraryId: task.libraryId,
        status: NetworkScanStatus.scanning,
        message: '连接失败，${retryDelay.inSeconds}秒后重试... ($e)',
      ));

      // 等待后重试
      await Future.delayed(retryDelay);
    }
  }
}

/// Isolate消息类
class _ScanIsolateMessage {
  final SendPort sendPort;
  final NetworkScanTask task;

  _ScanIsolateMessage({
    required this.sendPort,
    required this.task,
  });
}

/// 网络扫描任务
class NetworkScanTask {
  final String id;
  final String libraryId;
  final String libraryName;
  final NetworkConfig config;
  final DateTime startTime;

  bool _isCancelled = false;

  NetworkScanTask({
    required this.id,
    required this.libraryId,
    required this.libraryName,
    required this.config,
  }) : startTime = DateTime.now();

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// 处理过的漫画信息
class ProcessedMangaInfo {
  final NetworkMangaInfo networkMangaInfo;
  final Manga manga;
  final List<MangaPage> pageInfos;

  ProcessedMangaInfo({
    required this.networkMangaInfo,
    required this.manga,
    required this.pageInfos,
  });
}

/// 漫画页面信息
class MangaPageInfo {
  final String id;
  final String mangaId;
  final int pageIndex;
  final String localPath;

  MangaPageInfo({
    required this.id,
    required this.mangaId,
    required this.pageIndex,
    required this.localPath,
  });
}

/// 网络扫描进度
class NetworkScanProgress {
  final String taskId;
  final String libraryId;
  final NetworkScanStatus status;
  final String message;
  final int scannedCount;
  final List<NetworkMangaInfo>? foundMangas;
  final List<ProcessedMangaInfo>? processedMangas; // 新增：处理过的漫画信息

  NetworkScanProgress({
    required this.taskId,
    required this.libraryId,
    required this.status,
    required this.message,
    this.scannedCount = 0,
    this.foundMangas,
    this.processedMangas, // 新增参数
  });
}

/// 网络扫描状态
enum NetworkScanStatus {
  scanning,
  completed,
  failed,
  cancelled,
}

/// 网络漫画信息
class NetworkMangaInfo {
  final String name;
  final String path;
  final int size;
  final DateTime? lastModified;
  final bool isDirectory;
  final int imageCount;

  NetworkMangaInfo({
    required this.name,
    required this.path,
    required this.size,
    this.lastModified,
    this.isDirectory = false,
    this.imageCount = 0,
  });
}

/// 网络扫描异常
class NetworkScanException implements Exception {
  final String message;

  NetworkScanException(this.message);

  @override
  String toString() => 'NetworkScanException: $message';
}

/// 处理并创建漫画记录
/// 这个方法在扫描过程中被调用，用于实时处理发现的漫画
Future<ProcessedMangaInfo?> _processAndCreateMangaRecord(
  NetworkMangaInfo networkMangaInfo,
  String libraryId,
  NetworkFileSystem fileSystem,
) async {
  try {
    // 生成唯一ID
    final pathBytes = utf8.encode('${libraryId}_${networkMangaInfo.path}');
    final digest = md5.convert(pathBytes);
    final mangaId = digest.toString();

    // 创建漫画对象
    final manga = Manga(
      id: mangaId,
      title: networkMangaInfo.name,
      libraryId: libraryId,
      path: networkMangaInfo.path,
      type: networkMangaInfo.isDirectory ? MangaType.folder : MangaType.archive,
      totalPages: networkMangaInfo.imageCount,
      currentPage: 0,
      lastReadAt: null,
      createdAt: DateTime.now(),
      fileSize: networkMangaInfo.size,
    );

    // 生成页面信息
    final pageInfos = <MangaPage>[];
    if (networkMangaInfo.isDirectory) {
      // 对于目录，扫描其中的图片文件
      try {
        final files = await fileSystem.listDirectory(networkMangaInfo.path);
        final imageFiles = files.where((f) => f.isImageFile).toList();

        // 按文件名排序
        imageFiles.sort((a, b) => a.name.compareTo(b.name));

        for (int i = 0; i < imageFiles.length; i++) {
          pageInfos.add(MangaPage(
            id: '${mangaId}_page_${i + 1}',
            mangaId: mangaId,
            pageIndex: i,
            localPath: imageFiles[i].path,
          ));
        }
      } catch (e) {
        dev.log('扫描漫画目录页面失败: ${networkMangaInfo.path}, 错误: $e');
      }
    } else {
      // 对于压缩文件，暂时创建一个占位页面信息
      // 实际的页面信息会在用户首次打开时生成
      pageInfos.add(MangaPage(
        id: '${mangaId}_page_1',
        mangaId: mangaId,
        pageIndex: 0,
        localPath: networkMangaInfo.path,
      ));
    }

    return ProcessedMangaInfo(
      networkMangaInfo: networkMangaInfo,
      manga: manga,
      pageInfos: pageInfos,
    );
  } catch (e) {
    dev.log('创建漫画记录失败: ${networkMangaInfo.name}, 错误: $e');
    return null;
  }
}

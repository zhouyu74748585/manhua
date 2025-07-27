import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:manhua_reader_flutter/core/services/isolate_service.dart';
import 'package:manhua_reader_flutter/core/services/task_tracker_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/services/cover_cache_service.dart';
import 'package:manhua_reader_flutter/data/services/drift_isolate_database_service.dart';
import 'package:path_provider/path_provider.dart';

/// 封面生成Isolate服务
class CoverIsolateService {
  static const String _isolateNamePrefix = 'cover_generator';

  /// 为单个漫画生成封面
  static Future<void> generateCoverInIsolate(
    Manga manga, {
    Function(Manga)? onComplete,
  }) async {
    // 检查是否已有封面生成任务在运行
    if (TaskTrackerService.isTaskRunning(TaskType.coverGeneration, manga.id)) {
      log('封面生成任务已在运行，跳过: ${manga.title}');
      return;
    }

    log('开始为单个漫画生成封面: ${manga.title}');

    // 使用任务包装器执行封面生成
    await TaskWrapper.execute(
      TaskType.coverGeneration,
      manga.id,
      () async {
        await generateCoversInIsolate(
          [manga],
          onComplete: onComplete,
          onProgress: (current, total) {
            log('单个封面生成进度: $current/$total');
          },
        );
      },
    );
  }

  /// 在Isolate中批量生成封面（单线程处理）
  static Future<void> generateCoversInIsolate(
    List<Manga> mangas, {
    Function(Manga)? onComplete,
    Function(int, int)? onProgress,
  }) async {
    if (mangas.isEmpty) return;

    log('开始启动封面生成Isolate，漫画数量: ${mangas.length}');

    String? isolateName;
    try {
      // 获取缓存目录路径，传递给Isolate
      final appDir = await getApplicationDocumentsDirectory();
      final cachePath = appDir.path;

      // 启动单个Isolate处理所有漫画，不允许并发
      isolateName = await IsolateService.startIsolate(
        name: _isolateNamePrefix,
        entryPoint: _coverGeneratorIsolate,
        allowConcurrent: false, // 改为不允许并发，确保单线程处理
        message: {
          'mangas': mangas.map((m) => m.toJson()).toList(),
          'cachePath': cachePath,
          'rootIsolateToken': RootIsolateToken.instance!,
        },
      );

      // 监听Isolate消息
      final stream = IsolateService.listenToIsolate(isolateName);
      await for (final data in stream) {
        if (data is Map<String, dynamic>) {
          final message = IsolateMessage.fromJson(data);

          switch (message.type) {
            case IsolateMessageType.progress:
              if (onProgress != null && message.data is Map) {
                final progressData = message.data as Map;
                onProgress(progressData['current'], progressData['total']);
              }
              break;

            case IsolateMessageType.batchProcessed:
              if (onComplete != null && message.data is Map) {
                final mangaData = message.data as Map;
                final manga = Manga.fromJson(mangaData.cast<String, dynamic>());
                onComplete(manga);
              }
              break;

            case IsolateMessageType.complete:
              log('封面生成完成: $isolateName');
              await IsolateService.stopIsolate(isolateName);
              return;

            case IsolateMessageType.error:
              log('封面生成错误: ${message.error}');
              await IsolateService.stopIsolate(isolateName);
              throw Exception(message.error);

            default:
              break;
          }
        }
      }
    } catch (e, stackTrace) {
      log('封面生成Isolate执行失败: $e,堆栈:$stackTrace');
      if (isolateName != null) {
        await IsolateService.stopIsolate(isolateName);
      }
      rethrow;
    }
  }

  /// 停止所有封面生成任务
  static Future<void> stopAllCoverGeneration() async {
    await IsolateService.stopIsolatesByType(_isolateNamePrefix);
  }

  /// 检查是否有封面生成任务正在运行
  static bool isCoverGenerationRunning() {
    return IsolateService.isIsolateTypeRunning(_isolateNamePrefix);
  }

  /// 获取正在运行的封面生成任务数量
  static int getRunningCoverGenerationCount() {
    return IsolateService.getRunningIsolatesByType(_isolateNamePrefix).length;
  }
}

/// 封面生成Isolate入口点
void _coverGeneratorIsolate(Map<String, dynamic> params) async {
  final SendPort mainSendPort = params['sendPort'];
  final ReceivePort isolateReceivePort = ReceivePort();

  // 发送SendPort给主线程
  mainSendPort.send(isolateReceivePort.sendPort);

  DriftIsolateDatabaseService? databaseService;
  try {
    // 初始化BackgroundIsolateBinaryMessenger以支持Flutter插件
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        params['message']['rootIsolateToken']);

    final Map<String, dynamic> messageData = params['message'];
    final List<dynamic> mangaJsonList = messageData['mangas'];
    final String cachePath = messageData['cachePath'];

    final List<Manga> mangas = mangaJsonList
        .map((json) => Manga.fromJson(json.cast<String, dynamic>()))
        .toList();

    // 初始化CoverCacheService，使用传入的缓存路径
    await CoverCacheService.init(cachePath);

    // 在Isolate中初始化数据库连接
    databaseService = await DriftIsolateDatabaseService.create();

    for (int i = 0; i < mangas.length; i++) {
      final manga = mangas[i];
      log('开始生成封面: ${manga.title}');
      try {
        // 发送进度更新
        mainSendPort.send(IsolateMessage(
          type: IsolateMessageType.progress,
          data: {'current': i + 1, 'total': mangas.length},
        ).toJson());

        // 生成封面，传递缓存路径
        Manga? updatedManga = await _generateCoverForManga(manga, cachePath);

        if (updatedManga != null) {
          // 发送单个漫画完成消息
          databaseService?.updateManga(updatedManga);
          mainSendPort.send(IsolateMessage(
            type: IsolateMessageType.batchProcessed,
            data: updatedManga.toJson(),
          ).toJson());
        }
      } catch (e, stackTrace) {
        log('生成漫画封面失败: ${manga.title}, 错误: $e,堆栈:$stackTrace');
        // 继续处理下一个，不中断整个流程
      }
    }

    // 发送完成消息
    mainSendPort.send(const IsolateMessage(
      type: IsolateMessageType.complete,
    ).toJson());
  } catch (e, stackTrace) {
    log('封面生成Isolate执行失败: $e,堆栈:$stackTrace');
    // 发送错误消息
    mainSendPort.send(IsolateMessage(
      type: IsolateMessageType.error,
      error: e.toString(),
    ).toJson());
  } finally {
    // 关闭数据库连接
    await databaseService?.close();
  }

  isolateReceivePort.close();
}

/// 为单个漫画生成封面
Future<Manga?> _generateCoverForManga(Manga manga, String cachePath) async {
  if (manga.type == MangaType.folder) {
    return null; // 文件夹类型不需要生成封面
  }

  if (manga.coverPath != null && manga.coverPath!.isNotEmpty) {
    return null; // 已有封面，跳过
  }

  try {
    if (manga.type == MangaType.archive) {
      File zipFile = File(manga.path);
      final result = await CoverCacheService.extractAndCacheCoverFromZip(
        zipFile,
        manga.id,
        cachePath,
      );

      if (result != null) {
        final updatedManga = manga.copyWith(
          coverPath: result['cover'],
          totalPages: result['pages'] ?? 0,
        );
        return updatedManga;
      }
    } else if (manga.type == MangaType.pdf) {
      File pdfFile = File(manga.path);
      final result = await CoverCacheService.extractAndCacheCoverFromPdf(
        pdfFile,
        cachePath,
      );

      if (result != null) {
        final updatedManga = manga.copyWith(
          coverPath: result['cover'],
          totalPages: result['pages'] ?? 0,
        );
        // await mangaRepository.updateManga(updatedManga);
        return updatedManga;
      }
    }
  } catch (e, stackTrace) {
    log('生成封面失败: ${manga.title}, 错误: $e,堆栈:$stackTrace');
  }

  return null;
}

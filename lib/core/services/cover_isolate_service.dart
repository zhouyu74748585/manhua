import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:manhua_reader_flutter/core/services/isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/services/cover_cache_service.dart';
import 'package:path_provider/path_provider.dart';

/// 封面生成Isolate服务
class CoverIsolateService {
  static const String _isolateName = 'cover_generator';

  /// 在Isolate中生成封面
  static Future<void> generateCoversInIsolate(
    List<Manga> mangas, {
    Function(Manga)? onComplete,
    Function(int, int)? onProgress,
  }) async {
    if (mangas.isEmpty) return;

    // 检查是否已有Isolate在运行
    if (IsolateService.isIsolateRunning(_isolateName)) {
      log('封面生成Isolate已在运行，跳过重复启动');
      return;
    }

    try {
      // 获取缓存目录路径，传递给Isolate
      final appDir = await getApplicationDocumentsDirectory();
      final cachePath = appDir.path;

      // 启动Isolate
      await IsolateService.startIsolate(
        name: _isolateName,
        entryPoint: _coverGeneratorIsolate,
        message: {
          'mangas': mangas.map((m) => m.toJson()).toList(),
          'cachePath': cachePath,
        },
      );

      // 监听Isolate消息
      final stream = IsolateService.listenToIsolate(_isolateName);
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
              log('封面生成完成');
              await IsolateService.stopIsolate(_isolateName);
              return;

            case IsolateMessageType.error:
              log('封面生成错误: ${message.error}');
              await IsolateService.stopIsolate(_isolateName);
              throw Exception(message.error);

            default:
              break;
          }
        }
      }
    } catch (e,stackTrace) {
      log('封面生成Isolate执行失败: $e,堆栈:$stackTrace');
      await IsolateService.stopIsolate(_isolateName);
      rethrow;
    }
  }

  /// 停止封面生成
  static Future<void> stopCoverGeneration() async {
    await IsolateService.stopIsolate(_isolateName);
  }
}

/// 封面生成Isolate入口点
void _coverGeneratorIsolate(Map<String, dynamic> params) async {
  final SendPort mainSendPort = params['sendPort'];
  final ReceivePort isolateReceivePort = ReceivePort();

  // 发送SendPort给主线程
  mainSendPort.send(isolateReceivePort.sendPort);

  try {
    final Map<String, dynamic> messageData = params['message'];
    final List<dynamic> mangaJsonList = messageData['mangas'];
    final String cachePath = messageData['cachePath'];

    final List<Manga> mangas = mangaJsonList
        .map((json) => Manga.fromJson(json.cast<String, dynamic>()))
        .toList();

    // 初始化CoverCacheService，使用传入的缓存路径
    await CoverCacheService.init(cachePath);

    // 注意：在Isolate中需要重新初始化数据库连接
    // 这里暂时注释掉，因为Isolate中无法直接使用主线程的数据库连接
    // final mangaRepository = MangaRepositoryImpl();

    for (int i = 0; i < mangas.length; i++) {
      final manga = mangas[i];

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
          mainSendPort.send(IsolateMessage(
            type: IsolateMessageType.batchProcessed,
            data: updatedManga.toJson(),
          ).toJson());
        }

      } catch (e,stackTrace) {
        log('生成漫画封面失败: ${manga.title}, 错误: $e,堆栈:$stackTrace');
        // 继续处理下一个，不中断整个流程
      }
    }

    // 发送完成消息
    mainSendPort.send(const IsolateMessage(
      type: IsolateMessageType.complete,
    ).toJson());

  } catch (e,stackTrace) {
    // 发送错误消息
    mainSendPort.send(IsolateMessage(
      type: IsolateMessageType.error,
      error: e.toString(),
    ).toJson());
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
        // await mangaRepository.updateManga(updatedManga);
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
  } catch (e,stackTrace) {
    log('生成封面失败: ${manga.title}, 错误: $e,堆栈:$stackTrace');
  }

  return null;
}

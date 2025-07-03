import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:manhua_reader_flutter/core/services/isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/services/file_scanner_service.dart';
import 'package:manhua_reader_flutter/data/services/thumbnail_service.dart';

import '../../data/services/drift_isolate_database_service.dart';

/// 缩略图生成Isolate服务
class ThumbnailIsolateService {
  static const String _isolateName = 'thumbnail_generator';

  /// 在Isolate中生成缩略图
  static Future<void> generateThumbnailsInIsolate(
    Manga manga, {
    void Function()? onComplete,
    Function(List<MangaPage>)? onBatchProcessed,
  }) async {
    final receivePort = ReceivePort();

    final isolate = await Isolate.spawn(
      _thumbnailGeneratorIsolate,
      {
        'sendPort': receivePort.sendPort,
        'manga': manga.toJson(),
        'rootIsolateToken': RootIsolateToken.instance!,
      },
    );

    await for (final message in receivePort) {
      if (message is Map<String, dynamic>) {
        final type = IsolateMessageType.values[message['type']];

        switch (type) {
          case IsolateMessageType.batchProcessed:
            final batchData = message['batch'] as List<dynamic>;
            final batchPages = batchData
                .map((pageData) => MangaPage.fromJson(pageData))
                .toList();
            onBatchProcessed?.call(batchPages);
            break;

          case IsolateMessageType.complete:
            onComplete?.call();
            receivePort.close();
            isolate.kill();
            return;

          case IsolateMessageType.error:
            final error = message['error'] as String;
            print('Thumbnail generation error: $error');
            receivePort.close();
            isolate.kill();
            throw Exception(error);

          case IsolateMessageType.start:
          case IsolateMessageType.progress:
          case IsolateMessageType.stop:
            // 这些消息类型在此上下文中不处理
            break;
        }
      }
    }
  }

  static Future<List<Map<String, String>>> generateThumbnailsBatch(
    List<Map<String, dynamic>> pageData,
  ) async {
    final receivePort = ReceivePort();

    final isolate = await Isolate.spawn(
      _batchThumbnailGeneratorIsolate,
      {
        'sendPort': receivePort.sendPort,
        'pageData': pageData,
        'rootIsolateToken': RootIsolateToken.instance!,
      },
    );

    final completer = Completer<List<Map<String, String>>>();

    await for (final message in receivePort) {
      if (message is Map<String, dynamic>) {
        final type = IsolateMessageType.values[message['type']];

        switch (type) {
          case IsolateMessageType.complete:
            final results = (message['results'] as List<dynamic>)
                .cast<Map<String, String>>();
            completer.complete(results);
            receivePort.close();
            isolate.kill();
            return results;

          case IsolateMessageType.error:
            final error = message['error'] as String;
            completer.completeError(Exception(error));
            receivePort.close();
            isolate.kill();
            throw Exception(error);

          case IsolateMessageType.start:
          case IsolateMessageType.progress:
          case IsolateMessageType.batchProcessed:
          case IsolateMessageType.stop:
            // 这些消息类型在此上下文中不处理
            break;
        }
      }
    }

    return completer.future;
  }

  /// Isolate入口点 - 批量缩略图生成
  static void _batchThumbnailGeneratorIsolate(
      Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    final pageData = params['pageData'] as List<Map<String, dynamic>>;

    try {
      // Initialize BackgroundIsolateBinaryMessenger for Flutter services
      BackgroundIsolateBinaryMessenger.ensureInitialized(
          params['rootIsolateToken']);

      // Initialize Drift database for isolate
      final databaseService = await DriftIsolateDatabaseService.create();

      final List<Map<String, String>> results = [];

      for (final data in pageData) {
        final mangaId = data['mangaId'] as String;
        final localPath = data['localPath'] as String;

        // 生成缩略图
        final thumbnailMap = await ThumbnailService.generateThumbnails(
          mangaId,
          localPath,
        );

        results.add(thumbnailMap);
      }

      // Close database connection
      await databaseService.close();

      // 发送完成消息
      sendPort.send({
        'type': IsolateMessageType.complete.index,
        'results': results,
      });
    } catch (e, stackTrace) {
      // 发送错误消息
      sendPort.send({
        'type': IsolateMessageType.error.index,
        'error': e.toString(),
      });
    }
  }

  /// 停止缩略图生成
  static Future<void> stopThumbnailGeneration() async {
    await IsolateService.stopIsolate(_isolateName);
  }
}

/// 缩略图生成Isolate入口点
void _thumbnailGeneratorIsolate(Map<String, dynamic> params) async {
  final SendPort mainSendPort = params['sendPort'];
  final ReceivePort isolateReceivePort = ReceivePort();
  // 发送SendPort给主线程
  mainSendPort.send(isolateReceivePort.sendPort);

  DriftIsolateDatabaseService? databaseService;

  try {
    // Initialize BackgroundIsolateBinaryMessenger for Flutter services
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        params['rootIsolateToken']);

    // Initialize Drift database for isolate
    databaseService = await DriftIsolateDatabaseService.create();

    final Map<String, dynamic> mangaJson = params['manga'];
    final Manga manga = Manga.fromJson(mangaJson);
    await _generateThumbnailsForManga(manga, databaseService, mainSendPort);

    // 发送完成消息
    mainSendPort.send({
      'type': IsolateMessageType.complete.index,
    });
  } catch (e, stackTrace) {
    // 发送错误消息
    mainSendPort.send({
      'type': IsolateMessageType.error.index,
      'error': e.toString(),
    });
  } finally {
    // Close database connection
    await databaseService?.close();
    isolateReceivePort.close();
  }
}

/// 为漫画生成缩略图
Future<void> _generateThumbnailsForManga(
  Manga manga,
  DriftIsolateDatabaseService databaseService,
  SendPort mainSendPort,
) async {
  log('开始生成漫画[${manga.title}]的缩略图');

  List<MangaPage> pages = await databaseService.getPagesByMangaId(manga.id);
  String? thumbnailPath;

  if (manga.type != MangaType.folder) {
    if (manga.type == MangaType.archive) {
      // 处理压缩包类型
      List<MangaPage> extractedPages =
          await FileScannerService.extractFileToDisk(
        manga,
        onBatchProcessed: (batchPages) async {
          // 保存当前批次的页面到数据库
          await databaseService.batchInsertPages(batchPages);
          log("生成[${manga.title}]的${batchPages.length}页的缩略图");

          // 发送批次完成消息
          mainSendPort.send({
            'type': IsolateMessageType.batchProcessed.index,
            'batch': batchPages.map((page) => page.toJson()).toList(),
          });
        },
      );

      thumbnailPath = extractedPages.isNotEmpty
          ? extractedPages[0].largeThumbnail?.split("large").first
          : null;

      // 更新漫画元数据
      manga.metadata.putIfAbsent("thumbnail", () => thumbnailPath);
      manga.metadata
          .putIfAbsent("thumbnailGenerteDate", () => DateTime.now().toString());

      if (thumbnailPath != null) {
        await databaseService.updateManga(manga);
        // 最终保存所有页面（确保完整性）
        await databaseService.batchInsertPages(extractedPages);
      }

      log("生成[${manga.title}]共${extractedPages.length}页的缩略图,路径地址$thumbnailPath");
    } else if (manga.type == MangaType.pdf) {
      // PDF类型的处理逻辑
      // 这里可以添加PDF缩略图生成逻辑
      log("PDF类型缩略图生成暂未实现");
    }
  } else {
    // 目录类型漫画的分批处理
    const int batchSize = 10;
    List<MangaPage> updatedPages = [];

    for (int i = 0; i < pages.length; i += batchSize) {
      int endIndex = (i + batchSize).clamp(0, pages.length);
      List<MangaPage> batch = pages.sublist(i, endIndex);
      List<MangaPage> batchUpdatedPages = [];

      for (MangaPage page in batch) {
        String localPath = page.localPath;
        Map<String, String> thumbnailMap =
            await ThumbnailService.generateThumbnails(page.mangaId, localPath);
        String? smallThumbnail = thumbnailMap["small"];
        String? mediumThumbnail = thumbnailMap["medium"];
        String? largeThumbnail = thumbnailMap["large"];

        if (thumbnailPath == null && largeThumbnail != null) {
          thumbnailPath = largeThumbnail.split("large").first;
        }

        final updatePages = page.copyWith(
          smallThumbnail: smallThumbnail,
          mediumThumbnail: mediumThumbnail,
          largeThumbnail: largeThumbnail,
        );
        await databaseService.updatePageThumbnails(
          updatePages.id,
          largeThumbnail: largeThumbnail,
          mediumThumbnail: mediumThumbnail,
          smallThumbnail: smallThumbnail,
        );
        batchUpdatedPages.add(updatePages);
      }

      updatedPages.addAll(batchUpdatedPages);

      // 每批处理完成后发送消息
      mainSendPort.send({
        'type': IsolateMessageType.batchProcessed.index,
        'batch': batchUpdatedPages.map((page) => page.toJson()).toList(),
      });

      log("生成[${manga.title}]的${batchUpdatedPages.length}页的缩略图");

      // 添加小延迟避免过度占用资源
      await Future.delayed(const Duration(milliseconds: 50));
    }

    manga.metadata.putIfAbsent("thumbnail", () => thumbnailPath);
    manga.metadata
        .putIfAbsent("thumbnailGenerteDate", () => DateTime.now().toString());
    if (thumbnailPath != null) {
      await databaseService.updateManga(manga);
    }
    log("生成[${manga.title}]共${pages.length}页的缩略图,路径地址$thumbnailPath");
  }
}

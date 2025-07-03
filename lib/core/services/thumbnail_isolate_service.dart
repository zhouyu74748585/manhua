import 'dart:async';
import 'dart:isolate';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:manhua_reader_flutter/data/models/manga.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/repositories/manga_repository.dart';
import 'package:manhua_reader_flutter/data/services/file_scanner_service.dart';
import 'package:manhua_reader_flutter/data/services/thumbnail_service.dart';
import 'package:manhua_reader_flutter/data/services/database_service.dart';
import 'package:manhua_reader_flutter/core/services/isolate_service.dart';

/// 缩略图生成Isolate服务
class ThumbnailIsolateService {
  static const String _isolateName = 'thumbnail_generator';

  /// 在Isolate中生成缩略图
  static Future<void> generateThumbnailsInIsolate(
    Manga manga,
    {
    void Function()? onComplete,
    Function(List<MangaPage>)? onBatchProcessed,
  }) async {
    // 在主线程获取应用文档目录路径
    final appDir = await getApplicationDocumentsDirectory();
    final cachePath = appDir.path;
    final dbPath = '${appDir.path}/manhua_reader.db';
    
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _thumbnailGeneratorIsolate,
      {
        'sendPort': receivePort.sendPort,
        'manga': manga.toJson(),
        'cachePath': cachePath,
        'dbPath': dbPath,
      },
    );

    await for (final message in receivePort) {
      if (message is Map<String, dynamic>) {
        final type = IsolateMessageType.values[message['type']];
        
        switch (type) {
           case IsolateMessageType.batchProcessed:
             final batchData = message['batch'] as List<dynamic>;
             final batchPages = batchData.map((pageData) => MangaPage.fromJson(pageData)).toList();
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
    // 在主线程获取应用文档目录路径
    final appDir = await getApplicationDocumentsDirectory();
    final cachePath = appDir.path;
    final dbPath = '${appDir.path}/manhua_reader.db';
    
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _batchThumbnailGeneratorIsolate,
      {
        'sendPort': receivePort.sendPort,
        'pageData': pageData,
        'cachePath': cachePath,
        'dbPath': dbPath,
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
  static void _batchThumbnailGeneratorIsolate(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    final pageData = params['pageData'] as List<Map<String, dynamic>>;
    final cachePath = params['cachePath'] as String;
    final dbPath = params['dbPath'] as String;

    try {
      // 在Isolate中初始化数据库服务
      await DatabaseService.initForIsolate(dbPath);
      
      final List<Map<String, String>> results = [];
      
      for (final data in pageData) {
        final mangaId = data['mangaId'] as String;
        final localPath = data['localPath'] as String;
        
        // 生成缩略图，传入缓存路径
        final thumbnailMap = await ThumbnailService.generateThumbnails(
          mangaId,
          localPath,
          cachePath,
        );
        
        results.add(thumbnailMap);
      }

      // 发送完成消息
      sendPort.send({
        'type': IsolateMessageType.complete.index,
        'results': results,
      });
    } catch (e,stackTrace) {
      // 发送错误消息
      log("生成缩略图失败：$e, 堆栈: $stackTrace");
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
  final cachePath = params['cachePath'] as String;
  final dbPath = params['dbPath'] as String;
  final ReceivePort isolateReceivePort = ReceivePort();
  // 发送SendPort给主线程
  mainSendPort.send(isolateReceivePort.sendPort);
  
  try {
    // 在Isolate中初始化数据库服务
    await DatabaseService.initForIsolate(dbPath);
    
    // 在 Isolate 中初始化数据库和 Repository
     final mangaRepository = LocalMangaRepository();

    final Map<String, dynamic> mangaJson = params['manga'];
    final Manga manga = Manga.fromJson(mangaJson);
    await _generateThumbnailsForManga(manga, mangaRepository, mainSendPort, cachePath);
    
    // 发送完成消息
    mainSendPort.send({
      'type': IsolateMessageType.complete.index,
    });
    
  } catch (e,stackTrace) {
    // 发送错误消息
    log("生成缩略图失败：$e, 堆栈: $stackTrace");
    mainSendPort.send({
      'type': IsolateMessageType.error.index,
      'error': e.toString(),
    });
  }
  
  isolateReceivePort.close();
}

/// 为漫画生成缩略图
Future<void> _generateThumbnailsForManga(
   Manga manga,
   MangaRepository mangaRepository,
    SendPort mainSendPort,
    String cachePath,
) async {
  log('开始生成漫画[${manga.title}]的缩略图');
  
   List<MangaPage> pages = await mangaRepository.getPageByMangaId(manga.id);
  String? thumbnailPath;
  
  if (manga.type != MangaType.folder) {
    if (manga.type == MangaType.archive) {
      // 处理压缩包类型
      List<MangaPage> extractedPages = await FileScannerService.extractFileToDisk(
        manga,
        cachePath: cachePath,
        onBatchProcessed: (batchPages) async {
          // 保存当前批次的页面到数据库
          await mangaRepository.savePageList(batchPages);
          log("生成[${manga.title}]的${batchPages.length}页的缩略图-A");
          
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
      if (thumbnailPath != null) {
        final updatedMetadata = Map<String, dynamic>.from(manga.metadata);
        updatedMetadata["thumbnail"] = thumbnailPath;
        updatedMetadata["thumbnailGenerteDate"] = DateTime.now().toString();
        
        final updatedManga = manga.copyWith(metadata: updatedMetadata);
        await mangaRepository.updateManga(updatedManga);
        // 最终保存所有页面（确保完整性）
        await mangaRepository.savePageList(extractedPages);
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
            await ThumbnailService.generateThumbnails(
                page.mangaId, localPath, cachePath);
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
        await mangaRepository.updatePage(updatePages);
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

    if (thumbnailPath != null) {
      final updatedMetadata = Map<String, dynamic>.from(manga.metadata);
      updatedMetadata["thumbnail"] = thumbnailPath;
      updatedMetadata["thumbnailGenerteDate"] = DateTime.now().toString();
      
      final updatedManga = manga.copyWith(metadata: updatedMetadata);
      await mangaRepository.updateManga(updatedManga);
    }
    log("生成[${manga.title}]共${pages.length}页的缩略图,路径地址$thumbnailPath");
  }
}
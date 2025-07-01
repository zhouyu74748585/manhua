import 'dart:developer';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/services/thumbnail_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import '../models/manga.dart';
import '../models/library.dart';
import 'cover_cache_service.dart';

class FileScannerService {
  // 支持的漫画文件格式
  static const List<String> supportedFormats = [
    '.cbz',
    '.cbr',
    '.zip',
    '.rar',
    '.pdf',
  ];

  // 支持的图片格式
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];

  /// 扫描漫画库，返回发现的漫画列表
  static Future<Tuple2<List<Manga>, List<MangaPage>>> scanLibrary(
      MangaLibrary library) async {
    final List<Manga> mangas = [];
    final List<MangaPage> mangaPages = [];
    final libraryDir = Directory(library.path);

    if (!await libraryDir.exists()) {
      throw Exception('漫画库路径不存在: ${library.path}');
    }

    try {
      await _scanDirectoryRecursive(libraryDir, library.id, mangas, mangaPages);
    } catch (e) {
      throw Exception('扫描漫画库时发生错误: $e');
    }

    return Tuple2(mangas, mangaPages);
  }

  /// 递归扫描目录
  static Future<void> _scanDirectoryRecursive(Directory directory,
      String libraryId, List<Manga> mangas, List<MangaPage> mangaPages) async {
    // 首先检查当前目录是否包含图片文件
    final hasImages = await _directoryContainsImages(directory);

    if (hasImages) {
      // 如果包含图片，将整个目录作为一个漫画对象，不再下钻
      await _createMangaFromImageDirectory(
          directory, libraryId, mangas, mangaPages);
      return;
    }

    // 如果不包含图片，检查是否包含单体漫画文件，并继续下钻扫描子目录
    await for (final entity in directory.list()) {
      if (entity is File) {
        final manga = await _scanMangaFile(entity, libraryId);
        if (manga != null) {
          mangas.add(manga);
          log('扫描到漫画: ${manga.path}');
        }
      } else if (entity is Directory) {
        // 递归扫描子目录
        await _scanDirectoryRecursive(entity, libraryId, mangas, mangaPages);
      }
    }
  }

  /// 检查目录是否包含图片文件
  static Future<bool> _directoryContainsImages(Directory directory) async {
    try {
      await for (final entity in directory.list()) {
        if (entity is File) {
          final fileExtension = path.extension(entity.path).toLowerCase();
          if (supportedImageFormats.contains(fileExtension)) {
            return true;
          }
        }
      }
    } catch (e) {
      // 如果无法访问目录，返回false
      return false;
    }
    return false;
  }

  /// 从包含图片的目录创建漫画对象
  static Future<void> _createMangaFromImageDirectory(Directory directory,
      String libraryId, List<Manga> mangas, List<MangaPage> mangaPages) async {
    try {
      final List<String> imageFiles = [];

      // 收集所有图片文件
      await for (final entity in directory.list()) {
        if (entity is File) {
          final fileExtension = path.extension(entity.path).toLowerCase();
          if (supportedImageFormats.contains(fileExtension)) {
            imageFiles.add(entity.path);
          }
        }
      }

      if (imageFiles.isEmpty) {
        return;
      }

      // 按文件名排序
      imageFiles.sort();

      final mangaId = generateMangaId(directory.path);
      final title = path.basename(directory.path);

      // 获取目录的修改时间
      final dirStats = await directory.stat();

      // 提取并缓存封面
      String? coverPath;
      if (imageFiles.isNotEmpty) {
        // 尝试从缓存中获取封面，如果没有则提取并缓存
        coverPath = await CoverCacheService.extractAndCacheCoverFromDirectory(
            directory.path);
        // 如果缓存失败，使用原始路径
        coverPath ??= 'file://${imageFiles.first}';
      }

      // 创建初始化的阅读进度
      final totalPages = imageFiles.length;
      Manga manga = Manga(
        id: mangaId,
        libraryId: libraryId,
        title: title,
        path: directory.path,
        type: MangaType.folder,
        totalPages: totalPages,
        subtitle: null,
        author: null,
        description: null,
        coverPath: coverPath,
        tags: [],
        status: MangaStatus.completed,
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: dirStats.modified,
      );
      List<MangaPage> pages = [];
      for (var element in imageFiles) {
        pages.add(MangaPage(
          id: generateMangaId(element),
          mangaId: mangaId,
          pageIndex: 0,
          localPath: element,
        ));
      }
      pages.sort((a, b) => b.localPath.compareTo(a.localPath));
      for (int i = 0; i < pages.length; i++) {
        pages[i].pageIndex = i+1;
      }

      mangas.add(manga);
      mangaPages.addAll(pages);
      log('扫描到漫画: ${manga.path}');
    } catch (e) {
      log('从图片目录创建漫画失败: ${directory.path}, 错误: $e');
      return null;
    }
  }

  /// 扫描单个漫画文件
  static Future<Manga?> _scanMangaFile(File file, String libraryId) async {
    final fileName = path.basename(file.path);
    final fileExtension = path.extension(file.path).toLowerCase();

    // 检查是否为支持的漫画格式
    if (!supportedFormats.contains(fileExtension)) {
      return null;
    }

    try {
      final fileStats = await file.stat();
      final mangaId = generateMangaId(file.path);

      // 提取漫画标题（从文件名）
      final title = _extractTitleFromFileName(fileName);

      // 尝试提取封面
      String? coverPath;
      int pages = 0;

      // 创建初始化的阅读进度
      final fileSize = await file.length() / 1024;
      final totalPages = pages;
      return Manga(
          id: mangaId,
          libraryId: libraryId,
          title: title,
          path: file.path,
          type: fileExtension == '.pdf' ? MangaType.pdf : MangaType.archive,
          totalPages: totalPages,
          subtitle: null,
          author: null,
          description: null,
          coverPath: coverPath,
          tags: [],
          status: MangaStatus.completed,
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: fileStats.modified,
          fileSize: fileSize.toInt());
    } catch (e) {
      log('扫描文件失败: ${file.path}, 错误: $e');
      return null;
    }
  }

  /// 从文件名提取漫画标题
  static String _extractTitleFromFileName(String fileName) {
    // 移除文件扩展名
    String title = path.basenameWithoutExtension(fileName);

    // 移除常见的版本标识
    // title = title.replaceAll(RegExp(r'\[.*?\]'), ''); // 移除方括号内容
    // title = title.replaceAll(RegExp(r'\(.*?\)'), ''); // 移除圆括号内容
    // title = title.replaceAll(RegExp(r'_+'), ' '); // 下划线替换为空格
    // title = title.replaceAll(RegExp(r'-+'), ' '); // 连字符替换为空格
    // title = title.replaceAll(RegExp(r'\s+'), ' '); // 多个空格合并为一个

    return title.trim();
  }

  /// 生成漫画ID
  static String generateMangaId(String filePath) {
    // 使用文件路径的哈希值作为ID
    return 'manga_${filePath.hashCode.abs()}';
  }

  static String generatePageId(String filePath) {
    // 使用文件路径的哈希值作为ID
    return 'page_${filePath.hashCode.abs()}';
  }

  /// 获取文件的基本信息
  static Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final fileStats = await file.stat();
    final fileName = path.basename(filePath);
    final fileExtension = path.extension(filePath).toLowerCase();

    return {
      'name': fileName,
      'path': filePath,
      'extension': fileExtension,
      'size': fileStats.size,
      'modified': fileStats.modified,
      'isSupported': supportedFormats.contains(fileExtension),
    };
  }

  static Future<List<MangaPage>> extractFileToDisk(Manga manga) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      //为当前漫画创建目录
      final mangaDir = Directory(path.join(appDir.path, "thumbnails/${manga.id}/pages"));
      if (!await mangaDir.exists()) {
        await mangaDir.create(recursive: true);
      }

      final inputStream = InputFileStream(manga.path);
      final archive = ZipDecoder().decodeStream(inputStream);
      List<MangaPage> pages = [];
      for (final file in archive) {
        if (!file.isFile || file.name.startsWith('__MACOSX')) {
          continue;
        }
        if (!supportedImageFormats
            .contains(path.extension(file.name).toLowerCase())) {
          continue;
        }
        //生成文件
        final imageData = file.content;
        final pageFile = File(path.join(mangaDir.path, file.name));
        await pageFile.writeAsBytes(imageData);
        Map<String, String> thumbnailMap =await ThumbnailService.generateThumbnailsByData(manga.id, file.name, imageData);
        String? smallThumbnail = thumbnailMap["small"];
        String? mediumThumbnail = thumbnailMap["medium"];
        String? largeThumbnail = thumbnailMap["large"];
        MangaPage page = MangaPage(
          id: generatePageId(file.name),
          mangaId: manga.id,
          pageIndex: 0,
          localPath: pageFile.path,
          largeThumbnail: largeThumbnail,
          mediumThumbnail: mediumThumbnail,
          smallThumbnail: smallThumbnail
        );
        pages.add(page);
      }
      pages.sort((a, b) => b.localPath.compareTo(a.localPath));
      for (int i = 0; i < pages.length; i++) {
        pages[i].pageIndex = i+1;
      }
      return pages;
    } catch (e,stackTrace) {
      log('从ZIP文件解压缩失败: ${manga.title}, 错误: $e, 堆栈: $stackTrace');
      return [];
    }
  }
}

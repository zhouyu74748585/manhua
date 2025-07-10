import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/network/network_file_system_factory.dart';
import '../../core/services/network/network_manga_cache_service.dart';
import '../../core/services/network/network_scan_queue_manager.dart';
import '../../presentation/providers/manga_provider.dart';
import '../models/library.dart';
import '../models/manga.dart';
import '../models/manga_page.dart';
import '../models/network_config.dart';
import '../repositories/library_repository.dart';
import '../repositories/manga_repository.dart';

part 'library_service.g.dart';

@riverpod
LibraryService libraryService(Ref ref) {
  return LibraryService(
    ref.read(libraryRepositoryProvider),
    ref.read(mangaRepositoryProvider),
  );
}

class LibraryService {
  final LibraryRepository _repository;
  final MangaRepository _mangaRepository;

  LibraryService(this._repository, this._mangaRepository);

  Future<List<MangaLibrary>> getAllLibraries() async {
    return await _repository.getAllLibraries();
  }

  Future<MangaLibrary?> getLibraryById(String id) async {
    return await _repository.getLibraryById(id);
  }

  Future<void> addLibrary(MangaLibrary library) async {
    // 验证库路径
    await _validateLibraryPath(library.path, library.type);

    // 生成唯一ID
    final libraryWithId = library.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );

    await _repository.addLibrary(libraryWithId);
  }

  Future<void> updateLibrary(MangaLibrary library) async {
    // 如果路径发生变化，需要重新验证
    final existingLibrary = await _repository.getLibraryById(library.id);
    if (existingLibrary != null && existingLibrary.path != library.path) {
      await _validateLibraryPath(library.path, library.type);
    }

    await _repository.updateLibrary(library);
  }

  Future<void> deleteLibrary(String id) async {
    await _repository.deleteLibrary(id);
  }

  Future<void> scanLibrary(String id) async {
    final library = await _repository.getLibraryById(id);
    if (library == null || !library.isEnabled) {
      throw Exception('库不存在或已禁用');
    }

    try {
      // 根据库类型执行不同的扫描逻辑
      int mangaCount = 0;
      switch (library.type) {
        case LibraryType.local:
          mangaCount = await _scanLocalLibrary(library);
          break;
        case LibraryType.network:
          mangaCount = await _scanNetworkLibrary(library);
          break;
        case LibraryType.cloud:
          mangaCount = await _scanCloudLibrary(library);
          break;
      }

      // 更新扫描时间和漫画数量
      final updatedLibrary = library.copyWith(
        lastScanAt: DateTime.now(),
        mangaCount: mangaCount,
      );

      await _repository.updateLibrary(updatedLibrary);
    } catch (e, stackTrace) {
      throw Exception('扫描库失败: $e,堆栈:$stackTrace');
    }
  }

  Future<void> scanAllLibraries() async {
    final libraries = await _repository.getAllLibraries();
    final enabledLibraries = libraries.where((lib) => lib.isEnabled);

    for (final library in enabledLibraries) {
      try {
        await scanLibrary(library.id);
      } catch (e, stackTrace) {
        // 记录错误但继续扫描其他库
        dev.log('扫描库 ${library.name} 失败: $e,堆栈:$stackTrace');
      }
    }
  }

  Future<bool> validateLibraryPath(String path, LibraryType type) async {
    try {
      await _validateLibraryPath(path, type);
      return true;
    } catch (e, stackTrace) {
      dev.log('验证路径失败: $e, 堆栈: $stackTrace');
      return false;
    }
  }

  Future<void> _validateLibraryPath(String path, LibraryType type) async {
    switch (type) {
      case LibraryType.local:
        await _validateLocalPath(path);
        break;
      case LibraryType.network:
        await _validateNetworkPath(path);
        break;
      case LibraryType.cloud:
        await _validateCloudPath(path);
        break;
    }
  }

  Future<void> _validateLocalPath(String path) async {
    if (path.isEmpty) {
      throw Exception('路径不能为空');
    }

    try {
      final directory = Directory(path);

      // 检查路径是否存在
      if (!await directory.exists()) {
        throw Exception('路径不存在: $path');
      }

      // 检查是否为目录
      final stat = await directory.stat();
      if (stat.type != FileSystemEntityType.directory) {
        throw Exception('指定路径不是一个目录: $path');
      }

      // 检查读取权限（尝试列出目录内容）
      try {
        await directory.list().take(1).toList();
      } catch (e, stackTrace) {
        dev.log('检查目录权限时出错: $e, 栈跟踪: $stackTrace');
        throw Exception('没有读取权限: $path');
      }
    } catch (e, stackTrace) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('路径验证失败: $e,堆栈:$stackTrace');
    }
  }

  Future<void> _validateNetworkPath(String path) async {
    if (path.isEmpty) {
      throw Exception('网络路径不能为空');
    }

    try {
      // 检查是否为有效的网络路径格式
      final uri = Uri.tryParse(path);
      if (uri == null ||
          (!uri.hasScheme ||
              !['http', 'https', 'ftp', 'sftp', 'smb', 'nfs', 'webdav']
                  .contains(uri.scheme.toLowerCase()))) {
        throw Exception(
            '无效的网络路径格式，支持的协议: http, https, ftp, sftp, smb, nfs, webdav');
      }

      // 对于HTTP/HTTPS路径，尝试发送HEAD请求验证可访问性
      if (['http', 'https'].contains(uri.scheme.toLowerCase())) {
        final client = HttpClient();
        try {
          final request = await client.openUrl('HEAD', uri);
          request.headers.set('User-Agent', 'MangaReader/1.0');
          final response = await request.close();

          if (response.statusCode >= 400) {
            throw Exception('网络路径不可访问，状态码: ${response.statusCode}');
          }
        } finally {
          client.close();
        }
      }

      // 对于其他协议，暂时只验证格式
    } catch (e, stackTrace) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('网络路径验证失败: $e,堆栈:$stackTrace');
    }
  }

  Future<void> _validateCloudPath(String path) async {
    if (path.isEmpty) {
      throw Exception('云端路径不能为空');
    }

    try {
      // 检查是否为有效的云端路径格式
      final uri = Uri.tryParse(path);
      if (uri == null) {
        throw Exception('无效的云端路径格式');
      }

      // 检查支持的云端服务
      final supportedServices = {
        'drive.google.com': 'Google Drive',
        'onedrive.live.com': 'OneDrive',
        'dropbox.com': 'Dropbox',
        's3.amazonaws.com': 'Amazon S3',
        'api.box.com': 'Box',
      };

      bool isSupported = false;

      for (final entry in supportedServices.entries) {
        if (uri.host.contains(entry.key) ||
            path.toLowerCase().contains(entry.key)) {
          isSupported = true;
          break;
        }
      }

      if (!isSupported) {
        final supportedList = supportedServices.values.join(', ');
        throw Exception('不支持的云端服务，支持的服务: $supportedList');
      }

      // 对于云端路径，需要检查是否包含必要的认证信息或API密钥
      // 这里只做基本格式验证，实际的API验证需要在扫描时进行
      if (!uri.hasScheme ||
          !['http', 'https'].contains(uri.scheme.toLowerCase())) {
        throw Exception('云端路径必须使用 HTTPS 协议');
      }
    } catch (e, stackTrace) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('云端路径验证失败: $e,堆栈:$stackTrace');
    }
  }

  Future<int> _scanLocalLibrary(MangaLibrary library) async {
    try {
      List<Manga> mangas = await _repository.scanLibrary(library.id);
      return mangas.length;
    } catch (e, stackTrace) {
      throw Exception('扫描本地库失败: $e,堆栈:$stackTrace');
    }
  }

  Future<int> _scanNetworkLibrary(MangaLibrary library) async {
    try {
      // 优先从settings中读取网络配置，包含完整的认证信息
      NetworkConfig config;
      if (library.settings.networkConfig != null) {
        config = library.settings.networkConfig!;
      } else {
        // 兼容旧版本：从path中解析网络配置
        config = NetworkConfig.fromConnectionString(library.path);
      }

      // 检查协议是否支持
      if (!NetworkFileSystemFactory.isProtocolSupported(config.protocol)) {
        throw Exception(
            '协议 ${NetworkFileSystemFactory.getProtocolDisplayName(config.protocol)} 暂不支持');
      }

      // 使用网络扫描队列管理器进行异步扫描
      final taskId =
          await NetworkScanQueueManager.instance.startScan(library, config);

      // 监听扫描进度 - 实时处理模式
      int mangaCount = 0;
      final List<Manga> allProcessedMangas = []; // 收集所有处理过的漫画

      await for (final progress
          in NetworkScanQueueManager.instance.progressStream) {
        if (progress.taskId == taskId) {
          // 实时处理：每发现一个漫画就立即保存并获取封面
          if (progress.processedMangas != null &&
              progress.processedMangas!.isNotEmpty) {
            try {
              // 从ProcessedMangaInfo中提取Manga对象
              final mangas = progress.processedMangas!
                  .map((processedInfo) => processedInfo.manga)
                  .toList();

              // 并行处理：获取封面和保存数据库
              final mangasWithCovers =
                  await _processMangaCovers(mangas, config);
              await _saveProcessedMangas(mangasWithCovers);
              allProcessedMangas.addAll(mangasWithCovers);

              // 通知UI更新书架显示
              // 注意：这里暂时注释掉UI通知，因为在服务层无法直接访问ref
              // 实际的UI更新会通过扫描完成后的回调处理
              // _notifyMangaAdded(mangasWithCovers);

              dev.log('实时保存 ${mangasWithCovers.length} 个漫画（含封面），用户可立即在书架看到');
            } catch (e) {
              dev.log('实时保存处理过的漫画失败: $e');
            }
          }

          if (progress.status == NetworkScanStatus.completed) {
            mangaCount = allProcessedMangas.length;
            dev.log('扫描完成，共处理 $mangaCount 个漫画');
            break;
          } else if (progress.status == NetworkScanStatus.failed) {
            throw Exception('网络扫描失败: ${progress.message}');
          }
        }
      }

      return mangaCount;
    } catch (e, stackTrace) {
      throw Exception('扫描网络库失败: $e,堆栈:$stackTrace');
    }
  }

  Future<int> _scanHttpLibrary(Uri uri) async {
    final client = HttpClient();
    try {
      // 发送GET请求获取目录列表
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'MangaReader/1.0');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }

      // 读取响应内容
      final content = await response.transform(utf8.decoder).join();

      // 简单的HTML解析，查找漫画文件链接
      final supportedExtensions = {
        '.cbz',
        '.cbr',
        '.zip',
        '.rar',
        '.pdf',
        '.epub'
      };
      int mangaCount = 0;

      // 使用正则表达式查找文件链接
      final linkPattern = RegExp('', caseSensitive: false);
      final matches = linkPattern.allMatches(content);

      for (final match in matches) {
        final link = match.group(1);
        if (link != null) {
          final extension = link.toLowerCase().split('.').last;
          if (supportedExtensions.contains('.$extension')) {
            mangaCount++;
          }
        }
      }

      return mangaCount;
    } finally {
      client.close();
    }
  }

  Future<int> _scanCloudLibrary(MangaLibrary library) async {
    try {
      final uri = Uri.parse(library.path);

      // 根据不同的云端服务提供商进行扫描
      if (uri.host.contains('drive.google.com')) {
        return await _scanGoogleDrive(uri);
      } else if (uri.host.contains('onedrive.live.com')) {
        return await _scanOneDrive(uri);
      } else if (uri.host.contains('dropbox.com')) {
        return await _scanDropbox(uri);
      } else if (uri.host.contains('s3.amazonaws.com')) {
        return await _scanAmazonS3(uri);
      } else {
        // 对于其他云端服务，尝试通用的HTTP扫描
        return await _scanHttpLibrary(uri);
      }
    } catch (e, stackTrace) {
      throw Exception('扫描云端库失败: $e,堆栈:$stackTrace');
    }
  }

  Future<int> _scanGoogleDrive(Uri uri) async {
    // Google Drive API 扫描
    // 注意：这需要 Google Drive API 密钥和认证
    throw Exception('Google Drive 扫描需要配置 API 密钥，请联系开发者');
  }

  Future<int> _scanOneDrive(Uri uri) async {
    // OneDrive API 扫描
    throw Exception('OneDrive 扫描需要配置 API 密钥，请联系开发者');
  }

  Future<int> _scanDropbox(Uri uri) async {
    // Dropbox API 扫描
    throw Exception('Dropbox 扫描需要配置 API 密钥，请联系开发者');
  }

  Future<int> _scanAmazonS3(Uri uri) async {
    // Amazon S3 API 扫描
    throw Exception('Amazon S3 扫描需要配置 AWS 凭证，请联系开发者');
  }

  /// 生成漫画ID
  String _generateMangaId(String name, String path) {
    // 使用路径和名称的哈希值生成稳定的ID，确保同一漫画的ID一致
    final hash = (name + path).hashCode.abs();
    return 'manga_network_$hash';
  }

  /// 从路径提取漫画标题
  String _extractTitleFromPath(String pathOrName) {
    // 移除路径分隔符，获取文件名或目录名
    String title = pathOrName.split('/').last;

    // 移除文件扩展名
    if (title.contains('.')) {
      final parts = title.split('.');
      if (parts.length > 1) {
        // 检查是否为已知的漫画文件扩展名
        final extension = parts.last.toLowerCase();
        if (['cbz', 'cbr', 'zip', 'rar', '7z', 'pdf', 'epub']
            .contains(extension)) {
          title = parts.sublist(0, parts.length - 1).join('.');
        }
      }
    }

    // 清理标题：移除特殊字符，替换下划线和连字符为空格
    title = title.replaceAll(RegExp(r'[_-]+'), ' ');
    title = title.replaceAll(RegExp(r'\s+'), ' ');

    return title.trim().isEmpty ? pathOrName : title.trim();
  }

  /// 为处理过的漫画获取封面
  Future<List<Manga>> _processMangaCovers(
      List<Manga> mangas, NetworkConfig config) async {
    final List<Manga> mangasWithCovers = [];

    for (final manga in mangas) {
      try {
        // 使用网络漫画缓存服务获取封面
        final cacheService = NetworkMangaCacheService.instance;
        final coverPath = await cacheService.cacheMangaCover(manga, config);

        if (coverPath != null) {
          // 更新漫画对象包含封面路径
          final updatedManga = manga.copyWith(coverPath: coverPath);
          mangasWithCovers.add(updatedManga);
          dev.log('成功获取封面: ${manga.title} -> $coverPath');
        } else {
          // 即使没有封面也保存漫画
          mangasWithCovers.add(manga);
          dev.log('未能获取封面，但保留漫画: ${manga.title}');
        }
      } catch (e) {
        dev.log('获取封面失败: ${manga.title}, 错误: $e');
        // 即使获取封面失败也保存漫画
        mangasWithCovers.add(manga);
      }
    }

    return mangasWithCovers;
  }

  /// 保存处理过的漫画到数据库
  /// 这些漫画已经在扫描过程中完成了封面获取等处理
  Future<void> _saveProcessedMangas(List<Manga> processedMangas) async {
    try {
      // 批量保存漫画
      await _mangaRepository.saveMangaList(processedMangas);
      dev.log('批量保存 ${processedMangas.length} 个处理过的漫画成功');

      // 为每个漫画创建页面占位符（如果需要）
      final List<MangaPage> pagesToSave = [];
      for (final manga in processedMangas) {
        if (manga.type == MangaType.folder && manga.totalPages > 0) {
          for (int i = 0; i < manga.totalPages; i++) {
            final page = MangaPage(
              id: '${manga.id}_page_$i',
              mangaId: manga.id,
              pageIndex: i + 1,
              localPath: '${manga.path}/page_${i + 1}', // 网络路径占位符
            );
            pagesToSave.add(page);
          }
        }
      }

      // 保存页面占位符
      if (pagesToSave.isNotEmpty) {
        await _mangaRepository.savePageList(pagesToSave);
        dev.log('批量保存 ${pagesToSave.length} 个页面占位符成功');
      }
    } catch (e, stackTrace) {
      dev.log('保存处理过的漫画失败: $e, 堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 通知UI更新书架显示
  /// 注意：这个方法需要在有Ref上下文的地方调用
  static void notifyMangaAdded(Ref ref, List<Manga> mangas) {
    try {
      // 通过Riverpod刷新漫画列表，让用户立即在书架看到新漫画
      for (final manga in mangas) {
        // 触发漫画提供者的刷新
        ref.invalidate(allMangaProvider);
        dev.log('通知UI更新：新增漫画 ${manga.title}');
      }
    } catch (e) {
      dev.log('通知UI更新失败: $e');
    }
  }

  /// 确定漫画类型
  MangaType _determineMangaType(NetworkMangaInfo mangaInfo) {
    if (mangaInfo.isDirectory) {
      return MangaType.folder;
    }

    // 根据文件扩展名确定类型
    final extension = mangaInfo.path.toLowerCase().split('.').last;
    switch (extension) {
      case 'cbz':
      case 'zip':
      case 'cbr':
      case 'rar':
      case '7z':
      case 'cb7':
        return MangaType.archive;
      case 'pdf':
        return MangaType.pdf;
      default:
        // 如果是目录或其他格式，根据是否包含子目录判断
        return mangaInfo.isDirectory ? MangaType.folder : MangaType.online;
    }
  }
}

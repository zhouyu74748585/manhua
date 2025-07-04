import 'dart:developer';

import 'package:manhua_reader_flutter/core/services/cover_isolate_service.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/services/thumbnail_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/providers/manga_provider.dart';
import '../models/library.dart';
import '../models/manga.dart';
import '../services/cover_cache_service.dart';
import '../services/drift_database_service.dart';
import '../services/file_scanner_service.dart';
import 'manga_repository.dart';

part 'library_repository.g.dart';

@riverpod
LibraryRepository libraryRepository(LibraryRepositoryRef ref) {
  return LocalLibraryRepository(
    ref.read(mangaRepositoryProvider),
  );
}

abstract class LibraryRepository {
  // 漫画库管理
  Future<List<MangaLibrary>> getAllLibraries();
  Future<MangaLibrary?> getLibraryById(String id);
  Future<void> addLibrary(MangaLibrary library);
  Future<void> deleteLibrary(String id);
  Future<void> updateLibrary(MangaLibrary library);

  // 扫描和同步
  Future<List<Manga>> scanLibrary(String libraryId);
  Future<void> syncLibrary(String libraryId);
  Future<void> refreshLibrary(String libraryId);

  // 设置管理
  Future<LibrarySettings> getLibrarySettings(String libraryId);
  Future<void> saveLibrarySettings(String libraryId, LibrarySettings settings);

  // 统计信息
  Future<Map<String, int>> getLibraryStats(String libraryId);
  Future<int> getTotalMangaCount();
  Future<int> getTotalLibraryCount();

  // 隐私模式管理
  Future<void> setLibraryPrivate(String libraryId, bool isPrivate);
  Future<void> updateLibraryPrivateActivation(
      String libraryId, bool isActivated);
  Future<List<MangaLibrary>> getPrivateLibraries();
  Future<List<MangaLibrary>> getActivatedPrivateLibraries();
}

class LocalLibraryRepository implements LibraryRepository {
  final MangaRepository _mangaRepository;

  LocalLibraryRepository(this._mangaRepository);

  // 内存缓存，避免频繁数据库查询
  static List<MangaLibrary>? _cachedLibraries;
  static DateTime? _lastCacheTime;

  @override
  Future<List<MangaLibrary>> getAllLibraries() async {
    // 检查缓存是否有效（5分钟内）
    if (_cachedLibraries != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!).inMinutes < 5) {
      return List.from(_cachedLibraries!);
    }

    try {
      // 从数据库获取漫画库
      final libraries = await DriftDatabaseService.getAllLibraries();

      // 更新缓存
      _cachedLibraries = libraries;
      _lastCacheTime = DateTime.now();

      return List.from(libraries);
    } catch (e, stackTrace) {
      log('从数据库获取漫画库失败: $e,堆栈:$stackTrace');
      // 如果数据库查询失败，返回空列表
      return [];
    }
  }

  @override
  Future<MangaLibrary?> getLibraryById(String id) async {
    try {
      // 先尝试从缓存中查找
      if (_cachedLibraries != null) {
        final cachedLibrary =
            _cachedLibraries!.where((lib) => lib.id == id).firstOrNull;
        if (cachedLibrary != null) {
          return cachedLibrary;
        }
      }

      // 从数据库获取
      return await DriftDatabaseService.getLibraryById(id);
    } catch (e, stackTrace) {
      log('获取漫画库失败: $id, 错误: $e,堆栈:$stackTrace');
      return null;
    }
  }

  @override
  Future<void> addLibrary(MangaLibrary library) async {
    try {
      // 从数据库检查是否已存在相同名称或路径的库
      final allLibraries = await DriftDatabaseService.getAllLibraries();
      final existingByName =
          allLibraries.any((lib) => lib.name == library.name);
      final existingByPath =
          allLibraries.any((lib) => lib.path == library.path);

      if (existingByName) {
        throw Exception('已存在同名的漫画库');
      }

      if (existingByPath) {
        throw Exception('该路径已被其他漫画库使用');
      }

      // 保存到数据库
      await DriftDatabaseService.insertLibrary(library);

      // 清除缓存，强制下次重新从数据库加载
      _cachedLibraries = null;
      _lastCacheTime = null;
    } catch (e, stackTrace) {
      log('添加漫画库失败: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteLibrary(String id) async {
    try {
      // 获取该库下的所有漫画
      final libraryMangas = await DriftDatabaseService.getMangaByLibraryId(id);

      // 删除每个漫画的相关数据
      for (final manga in libraryMangas) {
        try {
          // 删除漫画页面信息
          await _mangaRepository.deletePageByMangaId(manga.id);
          // 删除阅读进度
          await _mangaRepository.deleteProgressByMangaId(manga.id);
          // 删除缩略图缓存
          if (manga.metadata.containsKey('thumbnail')) {
            await ThumbnailService.deleteDirectory(manga.metadata['thumbnail']);
          }
          // 删除封面缓存
          await CoverCacheService.deleteCacheForFile(manga.path);
          // 删除漫画记录
          await _mangaRepository.deleteManga(manga.id);
          log('已删除漫画及其相关数据: ${manga.title}');
        } catch (e, stackTrace) {
          log('删除漫画数据失败: ${manga.title}, 错误: $e,堆栈:$stackTrace');
        }
      }

      // 从数据库删除漫画库
      await DriftDatabaseService.deleteLibrary(id);

      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;

      log('成功删除漫画库及其所有相关数据: $id');
    } catch (e, stackTrace) {
      log('删除漫画库失败: $id, 错误: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> updateLibrary(MangaLibrary library) async {
    try {
      // 检查漫画库是否存在
      final existingLibrary =
          await DriftDatabaseService.getLibraryById(library.id);
      if (existingLibrary == null) {
        throw Exception('漫画库不存在');
      }

      // 检查名称和路径是否与其他库冲突
      final allLibraries = await DriftDatabaseService.getAllLibraries();
      final otherLibraries = allLibraries.where((lib) => lib.id != library.id);
      final existingByName =
          otherLibraries.any((lib) => lib.name == library.name);
      final existingByPath =
          otherLibraries.any((lib) => lib.path == library.path);

      if (existingByName) {
        throw Exception('已存在同名的漫画库');
      }

      if (existingByPath) {
        throw Exception('该路径已被其他漫画库使用');
      }

      // 更新数据库
      await DriftDatabaseService.updateLibrary(library);

      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;
    } catch (e, stackTrace) {
      log('更新漫画库失败: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Manga>> scanLibrary(String libraryId) async {
    final library = await getLibraryById(libraryId);
    if (library == null) {
      throw Exception('漫画库不存在: $libraryId');
    }

    if (!library.isEnabled) {
      throw Exception('漫画库已禁用: ${library.name}');
    }

    try {
      // 获取数据库中现有的漫画
      final existingMangas =
          await DriftDatabaseService.getMangaByLibraryId(libraryId);
      final existingMangaPaths = existingMangas.map((m) => m.path).toSet();

      // 使用文件扫描服务进行实际扫描
      final scannedMangas = await FileScannerService.scanLibrary(library);
      final scannedMangaPaths = scannedMangas.item1.map((m) => m.path).toSet();

      // 找出需要删除的漫画（在数据库中但不在扫描结果中）
      final pathsToDelete = existingMangaPaths.difference(scannedMangaPaths);
      final idToAdd = scannedMangas.item1
          .map((m) => m.id)
          .toSet()
          .difference(existingMangas.map((m) => m.id).toSet());
      // 删除不存在的漫画
      for (final pathToDelete in pathsToDelete) {
        final mangaToDelete = existingMangas.firstWhere(
          (m) => m.path == pathToDelete,
          orElse: () => throw StateError('找不到要删除的漫画'),
        );

        try {
          // 删除漫画
          await _mangaRepository.deleteManga(mangaToDelete.id);
          //删除页面信息
          await _mangaRepository.deletePageByMangaId(mangaToDelete.id);
          //删除进度信息
          await _mangaRepository.deleteProgressByMangaId(mangaToDelete.id);
          //删除缩略图
          await ThumbnailService.deleteDirectory(
              mangaToDelete.metadata['thumbnail']);
          // 删除封面缓存
          await CoverCacheService.deleteCacheForFile(mangaToDelete.path);
          log('已删除不存在的漫画: ${mangaToDelete.title} (${mangaToDelete.path})');
        } catch (e, stackTrace) {
          log('删除漫画失败: ${mangaToDelete.title}, 错误: $e,堆栈:$stackTrace');
        }
      }
      // 将扫描到的漫画保存到数据库
      List<Manga> mangaToAdd =
          scannedMangas.item1.where((e) => idToAdd.contains(e.id)).toList();
      List<MangaPage> pageToAdd = scannedMangas.item2
          .where((e) => idToAdd.contains(e.mangaId))
          .toList();
      try {
        await _mangaRepository.saveMangaList(mangaToAdd);
        await _mangaRepository.savePageList(pageToAdd);
      } catch (e, stackTrace) {
        log('保存漫画失败: $e,堆栈:$stackTrace');
      }

      // 更新库的漫画数量和最后扫描时间
      final updatedLibrary = library.copyWith(
        mangaCount: scannedMangas.item1.length,
        lastScanAt: DateTime.now(),
      );
      await updateLibrary(updatedLibrary);
      getCovers(scannedMangas.item1);
      return scannedMangas.item1;
    } catch (e, stackTrace) {
      throw Exception('扫描漫画库失败: $e,堆栈:$stackTrace');
    }
  }

  Future<void> getCovers(List<Manga> mangas) async {
    // 过滤需要生成封面的漫画
    final mangasNeedingCovers = mangas
        .where((m) =>
            m.type != MangaType.folder &&
            (m.coverPath == null || m.coverPath!.isEmpty))
        .toList();

    if (mangasNeedingCovers.isEmpty) return;

    // 使用 Isolate 处理封面提取
    await CoverIsolateService.generateCoversInIsolate(
      mangasNeedingCovers,
      onComplete: (updatedManga) {
        _mangaRepository.saveManga(updatedManga);
        log('封面生成完成: ${updatedManga.title}');
      },
      onProgress: (current, total) {
        log('封面生成进度: $current/$total');
      },
    );
  }

  @override
  Future<void> syncLibrary(String libraryId) async {
    try {
      // 获取漫画库
      final library = await DriftDatabaseService.getLibraryById(libraryId);
      if (library != null) {
        // 更新最后扫描时间
        final updatedLibrary = library.copyWith(
          lastScanAt: DateTime.now(),
        );
        await DriftDatabaseService.updateLibrary(updatedLibrary);

        // 清除缓存
        _cachedLibraries = null;
        _lastCacheTime = null;
      }
    } catch (e, stackTrace) {
      log('同步漫画库失败: $libraryId, 错误: $e,堆栈:$stackTrace');
    }
  }

  @override
  Future<void> refreshLibrary(String libraryId) async {
    await syncLibrary(libraryId);
  }

  @override
  Future<LibrarySettings> getLibrarySettings(String libraryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const LibrarySettings(
      autoScan: true,
      scanInterval: Duration(hours: 24),
      supportedFormats: ['.cbz', '.cbr', '.zip', '.rar', '.pdf'],
      includeSubfolders: true,
      generateThumbnails: true,
    );
  }

  @override
  Future<void> saveLibrarySettings(
      String libraryId, LibrarySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 简化实现
  }

  @override
  Future<Map<String, int>> getLibraryStats(String libraryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      // 从数据库获取该库的实际漫画数量
      final libraryManga =
          await DriftDatabaseService.getMangaByLibraryId(libraryId);
      final totalManga = libraryManga.length;
      final readProgress =
          await DriftDatabaseService.getReadingProgressByLibraryId(libraryId);
      // 计算已读和收藏数量（简化实现）
      final readManga = readProgress
          .where((readProgres) => readProgres.progressPercentage >= 1.0)
          .length;
      final favoriteManga =
          libraryManga.where((manga) => manga.isFavorite == true).length;

      return {
        'totalManga': totalManga,
        'readManga': readManga,
        'unreadManga': totalManga - readManga,
        'favoriteManga': favoriteManga,
      };
    } catch (e, stackTrace) {
      log('获取库统计信息失败: $e,堆栈:$stackTrace');
      // 如果数据库查询失败，返回默认值
      return {
        'totalManga': 0,
        'readManga': 0,
        'unreadManga': 0,
        'favoriteManga': 0,
      };
    }
  }

  @override
  Future<int> getTotalMangaCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      // 从数据库获取实际的漫画数量
      final allManga = await DriftDatabaseService.getAllManga();
      return allManga.length;
    } catch (e, stackTrace) {
      log('获取漫画总数失败: $e,堆栈:$stackTrace');
      // 如果数据库查询失败，返回内存中的示例数据数量
      return 3;
    }
  }

  @override
  Future<int> getTotalLibraryCount() async {
    try {
      final libraries = await DriftDatabaseService.getAllLibraries();
      return libraries.length;
    } catch (e, stackTrace) {
      log('获取漫画库总数失败: $e,堆栈:$stackTrace');
      return 0;
    }
  }

  @override
  Future<void> setLibraryPrivate(String libraryId, bool isPrivate) async {
    try {
      final library = await DriftDatabaseService.getLibraryById(libraryId);
      if (library == null) {
        throw Exception('漫画库不存在: $libraryId');
      }

      final updatedLibrary = library.copyWith(
        isPrivate: isPrivate,
        isPrivateActivated: false, // 设置隐私模式时重置激活状态
      );

      await DriftDatabaseService.updateLibrary(updatedLibrary);

      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;

      log('已${isPrivate ? "启用" : "禁用"}漫画库隐私模式: ${library.name}');
    } catch (e, stackTrace) {
      log('设置漫画库隐私模式失败: $libraryId, 错误: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> updateLibraryPrivateActivation(
      String libraryId, bool isActivated) async {
    try {
      final library = await DriftDatabaseService.getLibraryById(libraryId);
      if (library == null) {
        throw Exception('漫画库不存在: $libraryId');
      }

      if (!library.isPrivate) {
        throw Exception('该漫画库未启用隐私模式: ${library.name}');
      }

      final updatedLibrary = library.copyWith(
        isPrivateActivated: isActivated,
      );

      await DriftDatabaseService.updateLibrary(updatedLibrary);

      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;

      log('已${isActivated ? "激活" : "取消激活"}隐私漫画库: ${library.name}');
    } catch (e, stackTrace) {
      log('更新漫画库隐私激活状态失败: $libraryId, 错误: $e,堆栈:$stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<MangaLibrary>> getPrivateLibraries() async {
    try {
      final allLibraries = await getAllLibraries();
      return allLibraries.where((library) => library.isPrivate).toList();
    } catch (e, stackTrace) {
      log('获取隐私漫画库列表失败: $e,堆栈:$stackTrace');
      return [];
    }
  }

  @override
  Future<List<MangaLibrary>> getActivatedPrivateLibraries() async {
    try {
      final allLibraries = await getAllLibraries();
      return allLibraries
          .where((library) => library.isPrivate && library.isPrivateActivated)
          .toList();
    } catch (e, stackTrace) {
      log('获取已激活的隐私漫画库列表失败: $e,堆栈:$stackTrace');
      return [];
    }
  }
}

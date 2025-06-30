import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/library.dart';
import '../models/manga.dart';
import '../datasources/local_storage.dart';
import '../services/file_scanner_service.dart';
import '../services/database_service.dart';
import '../services/cover_cache_service.dart';
import 'manga_repository.dart';
import '../../presentation/providers/manga_provider.dart';

part 'library_repository.g.dart';

@riverpod
LibraryRepository libraryRepository(LibraryRepositoryRef ref) {
  return LocalLibraryRepository(
    ref.read(localStorageProvider),
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
}

class LocalLibraryRepository implements LibraryRepository {
  final LocalStorage _localStorage;
  final MangaRepository _mangaRepository;
  static const String _librariesKey = 'manga_libraries';
  
  LocalLibraryRepository(this._localStorage, this._mangaRepository);
  
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
      final libraries = await DatabaseService.getAllLibraries();
      
      // 更新缓存
      _cachedLibraries = libraries;
      _lastCacheTime = DateTime.now();
      
      return List.from(libraries);
    } catch (e) {
      print('从数据库获取漫画库失败: $e');
      // 如果数据库查询失败，返回空列表
      return [];
    }
  }
  
  @override
  Future<MangaLibrary?> getLibraryById(String id) async {
    try {
      // 先尝试从缓存中查找
      if (_cachedLibraries != null) {
        final cachedLibrary = _cachedLibraries!.where((lib) => lib.id == id).firstOrNull;
        if (cachedLibrary != null) {
          return cachedLibrary;
        }
      }
      
      // 从数据库获取
      return await DatabaseService.getLibraryById(id);
    } catch (e) {
      print('获取漫画库失败: $id, 错误: $e');
      return null;
    }
  }
  
  @override
  Future<void> addLibrary(MangaLibrary library) async {
    try {
      // 从数据库检查是否已存在相同名称或路径的库
      final allLibraries = await DatabaseService.getAllLibraries();
      final existingByName = allLibraries.any((lib) => lib.name == library.name);
      final existingByPath = allLibraries.any((lib) => lib.path == library.path);
      
      if (existingByName) {
        throw Exception('已存在同名的漫画库');
      }
      
      if (existingByPath) {
        throw Exception('该路径已被其他漫画库使用');
      }
      
      // 保存到数据库
      await DatabaseService.insertLibrary(library);
      
      // 清除缓存，强制下次重新从数据库加载
      _cachedLibraries = null;
      _lastCacheTime = null;
    } catch (e) {
      print('添加漫画库失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteLibrary(String id) async {
    try {
      // 从数据库删除漫画库
      await DatabaseService.deleteLibrary(id);
      
      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;
    } catch (e) {
      print('删除漫画库失败: $id, 错误: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateLibrary(MangaLibrary library) async {
    try {
      // 检查漫画库是否存在
      final existingLibrary = await DatabaseService.getLibraryById(library.id);
      if (existingLibrary == null) {
        throw Exception('漫画库不存在');
      }
      
      // 检查名称和路径是否与其他库冲突
      final allLibraries = await DatabaseService.getAllLibraries();
      final otherLibraries = allLibraries.where((lib) => lib.id != library.id);
      final existingByName = otherLibraries.any((lib) => lib.name == library.name);
      final existingByPath = otherLibraries.any((lib) => lib.path == library.path);
      
      if (existingByName) {
        throw Exception('已存在同名的漫画库');
      }
      
      if (existingByPath) {
        throw Exception('该路径已被其他漫画库使用');
      }
      
      // 更新数据库
      await DatabaseService.updateLibrary(library);
      
      // 清除缓存
      _cachedLibraries = null;
      _lastCacheTime = null;
    } catch (e) {
      print('更新漫画库失败: $e');
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
      final existingMangas = await DatabaseService.getMangaByLibraryId(libraryId);
      final existingMangaPaths = existingMangas.map((m) => m.path).toSet();
      
      // 使用文件扫描服务进行实际扫描
      final scannedMangas = await FileScannerService.scanLibrary(library);
      final scannedMangaPaths = scannedMangas.item1.map((m) => m.path).toSet();
      
      // 找出需要删除的漫画（在数据库中但不在扫描结果中）
      final pathsToDelete = existingMangaPaths.difference(scannedMangaPaths);
      
      // 删除不存在的漫画
      for (final pathToDelete in pathsToDelete) {
        final mangaToDelete = existingMangas.firstWhere(
          (m) => m.path == pathToDelete,
          orElse: () => throw StateError('找不到要删除的漫画'),
        );
        
        try {
          // 删除漫画
          await _mangaRepository.deleteManga(mangaToDelete.id);
          
          // 删除封面缓存
          await CoverCacheService.deleteCacheForFile(mangaToDelete.path);
          
          print('已删除不存在的漫画: ${mangaToDelete.title} (${mangaToDelete.path})');
        } catch (e) {
          print('删除漫画失败: ${mangaToDelete.title}, 错误: $e');
        }
      }
      // 将扫描到的漫画保存到数据库
      try {
          await _mangaRepository.saveMangaList(scannedMangas.item1);
          await _mangaRepository.savePageList(scannedMangas.item2);
      } catch (e) {
        print('保存漫画失败:  错误: $e');
      }
     
      // 更新库的漫画数量和最后扫描时间
      final updatedLibrary = library.copyWith(
        mangaCount: scannedMangas.item1.length,
        lastScanAt: DateTime.now(),
      );
      await updateLibrary(updatedLibrary);
      
      return scannedMangas.item1;
    } catch (e) {
      throw Exception('扫描漫画库失败: $e');
    }
  }

  Future<void> getCovers(List<Manga> mangas) async{
      for (final m in mangas) {
        if(m.type!=MangaType.folder){
          if(m.coverPath == null&&m.coverUrl==null){
            if(m.type==MangaType.archive){
              File zipFile = File(m.path);
              final result = await CoverCacheService.extractAndCacheCoverFromZip(zipFile);
              if (result != null) {
                 final updateManga = m.copyWith(
                    coverPath: result['cover'],
                    coverUrl: result['cover'],
                    totalPages: result['pages'] ?? 0,
                );
                _mangaRepository.updateManga(updateManga);
            }else if(m.type==MangaType.pdf){
              File pdfFile = File(m.path);
              final result = await CoverCacheService.extractAndCacheCoverFromPdf(pdfFile);
              if (result != null) {
                 final updateManga = m.copyWith(
                    coverPath: result['cover'],
                    coverUrl: result['cover'],
                    totalPages: result['pages'] ?? 0,
                );
                _mangaRepository.updateManga(updateManga);
              }
            }
          }
        }
        }
      }
  }
  
  @override
  Future<void> syncLibrary(String libraryId) async {
    try {
      // 获取漫画库
      final library = await DatabaseService.getLibraryById(libraryId);
      if (library != null) {
        // 更新最后扫描时间
        final updatedLibrary = library.copyWith(
          lastScanAt: DateTime.now(),
        );
        await DatabaseService.updateLibrary(updatedLibrary);
        
        // 清除缓存
        _cachedLibraries = null;
        _lastCacheTime = null;
      }
    } catch (e) {
      print('同步漫画库失败: $libraryId, 错误: $e');
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
  Future<void> saveLibrarySettings(String libraryId, LibrarySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 简化实现
  }
  
  @override
  Future<Map<String, int>> getLibraryStats(String libraryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      // 从数据库获取该库的实际漫画数量
      final libraryManga = await DatabaseService.getMangaByLibraryId(libraryId);
      final totalManga = libraryManga.length;
      
      // 计算已读和收藏数量（简化实现）
      final readManga = libraryManga.where((manga) => 
        manga.readingProgress?.isCompleted == true).length;
      final favoriteManga = libraryManga.where((manga) => 
        manga.isFavorite == true).length;
      
      return {
        'totalManga': totalManga,
        'readManga': readManga,
        'unreadManga': totalManga - readManga,
        'favoriteManga': favoriteManga,
      };
    } catch (e) {
      print('获取库统计信息失败: $e');
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
      final allManga = await DatabaseService.getAllManga();
      return allManga.length;
    } catch (e) {
      print('获取漫画总数失败: $e');
      // 如果数据库查询失败，返回内存中的示例数据数量
      return 3;
    }
  }
  
  @override
  Future<int> getTotalLibraryCount() async {
    try {
      final libraries = await DatabaseService.getAllLibraries();
      return libraries.length;
    } catch (e) {
      print('获取漫画库总数失败: $e');
      return 0;
    }
  }
}
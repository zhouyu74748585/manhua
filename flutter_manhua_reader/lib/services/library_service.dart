import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/library.dart';
import '../data/repositories/library_repository.dart';

part 'library_service.g.dart';

@riverpod
LibraryService libraryService(Ref ref) {
  return LibraryService(ref.read(libraryRepositoryProvider));
}

class LibraryService {
  final LibraryRepository _repository;
  
  LibraryService(this._repository);
  
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
    } catch (e) {
      throw Exception('扫描库失败: $e');
    }
  }
  
  Future<void> scanAllLibraries() async {
    final libraries = await _repository.getAllLibraries();
    final enabledLibraries = libraries.where((lib) => lib.isEnabled);
    
    for (final library in enabledLibraries) {
      try {
        await scanLibrary(library.id);
      } catch (e) {
        // 记录错误但继续扫描其他库
        print('扫描库 ${library.name} 失败: $e');
      }
    }
  }
  
  Future<bool> validateLibraryPath(String path, LibraryType type) async {
    try {
      await _validateLibraryPath(path, type);
      return true;
    } catch (e) {
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
    // TODO: 实现本地路径验证
    // 检查路径是否存在，是否有读取权限等
    if (path.isEmpty) {
      throw Exception('路径不能为空');
    }
  }
  
  Future<void> _validateNetworkPath(String path) async {
    // TODO: 实现网络路径验证
    // 检查网络路径是否可访问
    if (path.isEmpty) {
      throw Exception('网络路径不能为空');
    }
  }
  
  Future<void> _validateCloudPath(String path) async {
    // TODO: 实现云端路径验证
    // 检查云端配置是否正确
    if (path.isEmpty) {
      throw Exception('云端路径不能为空');
    }
  }
  
  Future<int> _scanLocalLibrary(MangaLibrary library) async {
    // TODO: 实现本地库扫描逻辑
    // 扫描指定目录下的漫画文件
    // 支持的格式: .cbz, .cbr, .zip, .rar, .pdf
    await Future.delayed(const Duration(seconds: 2)); // 模拟扫描时间
    return 0; // 返回发现的漫画数量
  }
  
  Future<int> _scanNetworkLibrary(MangaLibrary library) async {
    // TODO: 实现网络库扫描逻辑
    await Future.delayed(const Duration(seconds: 3)); // 模拟扫描时间
    return 0;
  }
  
  Future<int> _scanCloudLibrary(MangaLibrary library) async {
    // TODO: 实现云端库扫描逻辑
    await Future.delayed(const Duration(seconds: 4)); // 模拟扫描时间
    return 0;
  }
}
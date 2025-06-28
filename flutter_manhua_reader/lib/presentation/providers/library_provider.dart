import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/library.dart';
import '../../data/models/manga.dart';
import '../../data/repositories/library_repository.dart';
import 'manga_provider.dart';

part 'library_provider.g.dart';

// 使用 riverpod 生成的 provider
// final libraryRepositoryProvider 已在 library_repository.dart 中定义

// 所有漫画库列表提供者
@riverpod
Future<List<MangaLibrary>> allLibraries(AllLibrariesRef ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getAllLibraries();
}

// 单个漫画库详情提供者
@riverpod
Future<MangaLibrary?> libraryDetail(LibraryDetailRef ref, String libraryId) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getLibraryById(libraryId);
}

// 漫画库设置提供者
@riverpod
Future<LibrarySettings> librarySettings(LibrarySettingsRef ref, String libraryId) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getLibrarySettings(libraryId);
}

// 漫画库统计信息提供者
@riverpod
Future<Map<String, int>> libraryStats(LibraryStatsRef ref, String libraryId) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getLibraryStats(libraryId);
}

// 总统计信息提供者
@riverpod
Future<Map<String, int>> totalStats(TotalStatsRef ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  final totalManga = await repository.getTotalMangaCount();
  final totalLibraries = await repository.getTotalLibraryCount();
  
  return {
    'totalManga': totalManga,
    'totalLibraries': totalLibraries,
  };
}

// 漫画库操作提供者
@riverpod
class LibraryActions extends _$LibraryActions {
  @override
  void build() {}
  
  Future<void> addLibrary(MangaLibrary library) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.addLibrary(library);
    
    // 刷新库列表
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(totalStatsProvider);
  }
  
  Future<void> updateLibrary(MangaLibrary library) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.updateLibrary(library);
    
    // 刷新相关提供者
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(libraryDetailProvider(library.id));
  }
  
  Future<void> deleteLibrary(String libraryId) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.deleteLibrary(libraryId);
    
    // 刷新相关提供者
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(totalStatsProvider);
  }
  
  Future<List<Manga>> scanLibrary(String libraryId) async {
    final repository = ref.read(libraryRepositoryProvider);
    final newManga = await repository.scanLibrary(libraryId);
    
    // 刷新库统计信息
    ref.invalidate(libraryStatsProvider(libraryId));
    ref.invalidate(libraryDetailProvider(libraryId));
    ref.invalidate(totalStatsProvider);
    
    // 刷新漫画相关数据，确保书架显示最新内容
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(recentlyUpdatedMangaProvider);
    
    return newManga;
  }
  
  Future<void> syncLibrary(String libraryId) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.syncLibrary(libraryId);
    
    // 刷新相关提供者
    ref.invalidate(libraryStatsProvider(libraryId));
    ref.invalidate(libraryDetailProvider(libraryId));
  }
  
  Future<void> refreshLibrary(String libraryId) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.refreshLibrary(libraryId);
    
    // 刷新相关提供者
    ref.invalidate(libraryStatsProvider(libraryId));
    ref.invalidate(libraryDetailProvider(libraryId));
  }
  
  Future<void> updateLibrarySettings(String libraryId, LibrarySettings settings) async {
    final repository = ref.read(libraryRepositoryProvider);
    await repository.saveLibrarySettings(libraryId, settings);
    
    // 刷新设置提供者
    ref.invalidate(librarySettingsProvider(libraryId));
  }
  
  Future<void> refreshAllLibraries() async {
    // 刷新所有库相关数据
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(totalStatsProvider);
  }
}

// 库扫描状态提供者
@riverpod
class LibraryScanState extends _$LibraryScanState {
  @override
  Map<String, bool> build() {
    return {};
  }
  
  void setScanningState(String libraryId, bool isScanning) {
    state = {
      ...state,
      libraryId: isScanning,
    };
  }
  
  bool isScanning(String libraryId) {
    return state[libraryId] ?? false;
  }
  
  bool get hasAnyScanning {
    return state.values.any((isScanning) => isScanning);
  }
}
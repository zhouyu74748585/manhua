import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/library.dart';
import '../../data/models/manga.dart';
import '../../data/services/library_service.dart';
import 'manga_provider.dart';

part 'library_provider.g.dart';

// 使用 library service 而不是 repository

// 所有漫画库列表提供者
@riverpod
Future<List<MangaLibrary>> allLibraries(AllLibrariesRef ref) async {
  final service = ref.watch(libraryServiceProvider);
  return service.getAllLibraries();
}

// 单个漫画库详情提供者
@riverpod
Future<MangaLibrary?> libraryDetail(
    LibraryDetailRef ref, String libraryId) async {
  final service = ref.watch(libraryServiceProvider);
  return service.getLibraryById(libraryId);
}

// 漫画库设置提供者
@riverpod
Future<LibrarySettings> librarySettings(
    LibrarySettingsRef ref, String libraryId) async {
  // TODO: Implement settings management
  return const LibrarySettings();
}

// 漫画库统计信息提供者
@riverpod
Future<Map<String, int>> libraryStats(
    LibraryStatsRef ref, String libraryId) async {
  final service = ref.watch(libraryServiceProvider);
  final library = await service.getLibraryById(libraryId);
  return {
    'mangaCount': library?.mangaCount ?? 0,
    'lastScanDays': library?.lastScanAt != null
        ? DateTime.now().difference(library!.lastScanAt!).inDays
        : -1,
  };
}

// 总统计信息提供者
@riverpod
Future<Map<String, int>> totalStats(TotalStatsRef ref) async {
  final service = ref.watch(libraryServiceProvider);
  final libraries = await service.getAllLibraries();
  final totalLibraries = libraries.length;
  final totalManga = libraries.fold(0, (sum, lib) => sum + lib.mangaCount);

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
    final service = ref.read(libraryServiceProvider);
    await service.addLibrary(library);

    // 刷新库列表
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(totalStatsProvider);
  }

  Future<void> updateLibrary(MangaLibrary library) async {
    final service = ref.read(libraryServiceProvider);
    await service.updateLibrary(library);

    // 刷新相关提供者
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(libraryDetailProvider(library.id));
    ref.invalidate(totalStatsProvider);
    ref.invalidate(libraryStatsProvider(library.id));

    // 刷新漫画相关数据，确保书架显示最新内容
    ref.invalidate(allMangaProvider);
    ref.invalidate(favoriteMangaProvider);
    ref.invalidate(recentlyReadMangaProvider);
    ref.invalidate(recentlyUpdatedMangaProvider);
  }

  Future<void> deleteLibrary(String libraryId) async {
    final service = ref.read(libraryServiceProvider);
    await service.deleteLibrary(libraryId);

    // 刷新相关提供者
    ref.invalidate(allLibrariesProvider);
    ref.invalidate(totalStatsProvider);
  }

  Future<List<Manga>> scanLibrary(String libraryId) async {
    final service = ref.read(libraryServiceProvider);
    final scanStateNotifier = ref.read(libraryScanStateProvider.notifier);
    
    // 检查是否有任何库正在扫描
    if (scanStateNotifier.hasAnyScanning) {
      throw Exception('已有漫画库正在扫描中，请等待扫描完成后再试');
    }
    
    try {
      // 设置扫描状态
      scanStateNotifier.setScanningState(libraryId, true);
      
      // 更新数据库中的扫描状态
      final library = await service.getLibraryById(libraryId);
      if (library != null) {
        await service.updateLibrary(library.copyWith(isScanning: true));
      }
      
      // 执行扫描
      await service.scanLibrary(libraryId);
      
      // 扫描完成后更新状态
      scanStateNotifier.setScanningState(libraryId, false);
      
      // 更新数据库中的扫描状态
      final updatedLibrary = await service.getLibraryById(libraryId);
      if (updatedLibrary != null) {
        await service.updateLibrary(updatedLibrary.copyWith(isScanning: false));
      }
      
    } catch (e) {
      // 扫描失败时也要清除扫描状态
      scanStateNotifier.setScanningState(libraryId, false);
      
      final library = await service.getLibraryById(libraryId);
      if (library != null) {
        await service.updateLibrary(library.copyWith(isScanning: false));
      }
      
      rethrow;
    }

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

    return [];
  }

  Future<void> syncLibrary(String libraryId) async {
    final service = ref.read(libraryServiceProvider);
    // LibraryService doesn't have syncLibrary method, use scanLibrary instead
    await service.scanLibrary(libraryId);

    // 刷新相关提供者
    ref.invalidate(libraryStatsProvider(libraryId));
    ref.invalidate(libraryDetailProvider(libraryId));
  }

  Future<void> refreshLibrary(String libraryId) async {
    final service = ref.read(libraryServiceProvider);
    // LibraryService doesn't have refreshLibrary method, use scanLibrary instead
    await service.scanLibrary(libraryId);

    // 刷新相关提供者
    ref.invalidate(libraryStatsProvider(libraryId));
    ref.invalidate(libraryDetailProvider(libraryId));
  }

  Future<void> updateLibrarySettings(
      String libraryId, LibrarySettings settings) async {
    // LibraryService doesn't have settings methods, skip for now
    // TODO: Implement settings management

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
  Future<Map<String, bool>> build() async {
    // 从数据库加载扫描状态
    final service = ref.watch(libraryServiceProvider);
    final libraries = await service.getAllLibraries();
    
    final scanStates = <String, bool>{};
    for (final library in libraries) {
      scanStates[library.id] = library.isScanning;
    }
    
    return scanStates;
  }

  void setScanningState(String libraryId, bool isScanning) {
    final currentState = state.valueOrNull ?? {};
    state = AsyncValue.data({
      ...currentState,
      libraryId: isScanning,
    });
  }

  bool isScanning(String libraryId) {
    final currentState = state.valueOrNull ?? {};
    return currentState[libraryId] ?? false;
  }

  bool get hasAnyScanning {
    final currentState = state.valueOrNull ?? {};
    return currentState.values.any((isScanning) => isScanning);
  }
  
  // 刷新扫描状态
  Future<void> refreshScanStates() async {
    ref.invalidateSelf();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/library.dart';
import '../services/library_service.dart';

part 'library_provider.g.dart';

@riverpod
class LibraryNotifier extends _$LibraryNotifier {
  @override
  Future<List<MangaLibrary>> build() async {
    return await ref.read(libraryServiceProvider).getAllLibraries();
  }
  
  Future<void> addLibrary(MangaLibrary library) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(libraryServiceProvider).addLibrary(library);
      state = AsyncValue.data(await ref.read(libraryServiceProvider).getAllLibraries());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateLibrary(MangaLibrary library) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(libraryServiceProvider).updateLibrary(library);
      state = AsyncValue.data(await ref.read(libraryServiceProvider).getAllLibraries());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> deleteLibrary(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(libraryServiceProvider).deleteLibrary(id);
      state = AsyncValue.data(await ref.read(libraryServiceProvider).getAllLibraries());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> toggleLibraryEnabled(String id) async {
    final currentState = state.value;
    if (currentState == null) return;
    
    final library = currentState.firstWhere((lib) => lib.id == id);
    final updatedLibrary = library.copyWith(isEnabled: !library.isEnabled);
    
    await updateLibrary(updatedLibrary);
  }
  
  Future<void> scanLibrary(String id) async {
    try {
      await ref.read(libraryServiceProvider).scanLibrary(id);
      // 扫描完成后刷新库列表
      state = AsyncValue.data(await ref.read(libraryServiceProvider).getAllLibraries());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> scanAllLibraries() async {
    try {
      await ref.read(libraryServiceProvider).scanAllLibraries();
      // 扫描完成后刷新库列表
      state = AsyncValue.data(await ref.read(libraryServiceProvider).getAllLibraries());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 获取启用的库列表
@riverpod
Future<List<MangaLibrary>> enabledLibraries(EnabledLibrariesRef ref) async {
  final libraries = await ref.watch(libraryNotifierProvider.future);
  return libraries.where((lib) => lib.isEnabled).toList();
}

// 获取特定库的详情
@riverpod
Future<MangaLibrary?> libraryById(LibraryByIdRef ref, String id) async {
  final libraries = await ref.watch(libraryNotifierProvider.future);
  try {
    return libraries.firstWhere((lib) => lib.id == id);
  } catch (e) {
    return null;
  }
}

// 扫描状态provider
@riverpod
class ScanStatus extends _$ScanStatus {
  @override
  Map<String, bool> build() {
    return {};
  }
  
  void setScanningStatus(String libraryId, bool isScanning) {
    state = {...state, libraryId: isScanning};
  }
  
  bool isScanning(String libraryId) {
    return state[libraryId] ?? false;
  }
  
  bool get isAnyScanning {
    return state.values.any((isScanning) => isScanning);
  }
}
import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/app_lifecycle_manager.dart';
import '../../core/services/privacy_service.dart';
import '../../data/models/library.dart';
import '../../data/repositories/library_repository.dart';

part 'privacy_provider.g.dart';

/// 隐私模式状态
class PrivacyState {
  final bool isPasswordSet;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final List<String> activatedLibraries;
  final bool needsAuthentication;
  final bool isBlurred;

  const PrivacyState({
    this.isPasswordSet = false,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.activatedLibraries = const [],
    this.needsAuthentication = false,
    this.isBlurred = false,
  });

  PrivacyState copyWith({
    bool? isPasswordSet,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    List<String>? activatedLibraries,
    bool? needsAuthentication,
    bool? isBlurred,
  }) {
    return PrivacyState(
      isPasswordSet: isPasswordSet ?? this.isPasswordSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      activatedLibraries: activatedLibraries ?? this.activatedLibraries,
      needsAuthentication: needsAuthentication ?? this.needsAuthentication,
      isBlurred: isBlurred ?? this.isBlurred,
    );
  }
}

/// 隐私模式状态管理器
@riverpod
class PrivacyNotifier extends _$PrivacyNotifier {
  StreamSubscription? _lifecycleSubscription;
  StreamSubscription? _authSubscription;

  @override
  PrivacyState build() {
    // 初始化时加载状态
    _loadInitialState();

    // 监听应用生命周期
    _setupLifecycleListener();

    // 监听隐私验证需求
    _setupAuthListener();

    return const PrivacyState();
  }

  /// 加载初始状态
  Future<void> _loadInitialState() async {
    try {
      final isPasswordSet = await PrivacyService.hasPassword();
      final isBiometricEnabled = await PrivacyService.isBiometricEnabled();
      final isBiometricAvailable = await PrivacyService.isBiometricAvailable();
      final activatedLibraries = PrivacyService.activatedLibraries;

      state = state.copyWith(
        isPasswordSet: isPasswordSet,
        isBiometricEnabled: isBiometricEnabled,
        isBiometricAvailable: isBiometricAvailable,
        activatedLibraries: activatedLibraries.toList(),
      );
    } catch (e, stackTrace) {
      log('加载隐私模式初始状态失败: $e,堆栈:$stackTrace');
    }
  }

  /// 设置应用生命周期监听
  void _setupLifecycleListener() {
    _lifecycleSubscription = AppLifecycleManager.instance.stateStream.listen(
      (lifecycleState) {
        log('应用状态变化: $lifecycleState');
        _updateBlurState();
      },
    );
  }

  /// 设置隐私验证监听
  void _setupAuthListener() {
    _authSubscription = AppLifecycleManager.instance.privacyAuthStream.listen(
      (needsAuth) {
        state = state.copyWith(needsAuthentication: needsAuth);
        if (needsAuth) {
          _updateBlurState();
        }
      },
    );
  }

  /// 更新模糊化状态
  void _updateBlurState() {
    final needsBlur =
        AppLifecycleManager.instance.needsBlur || state.needsAuthentication;
    state = state.copyWith(isBlurred: needsBlur);
  }

  /// 设置密码
  Future<bool> setPassword(String password) async {
    try {
      await PrivacyService.setPassword(password);
      state = state.copyWith(isPasswordSet: true);
      log('密码设置成功');
      return true;
    } catch (e, stackTrace) {
      log('设置密码失败: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    try {
      final isValid = await PrivacyService.verifyPassword(password);
      if (isValid) {
        state = state.copyWith(
          needsAuthentication: false,
          isBlurred: false,
        );
        AppLifecycleManager.instance.setBlurState(false);
      }
      return isValid;
    } catch (e, stackTrace) {
      log('验证密码失败: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 启用生物识别
  Future<bool> enableBiometric() async {
    try {
      await PrivacyService.setBiometricEnabled(true);
      state = state.copyWith(isBiometricEnabled: true);
      log('生物识别启用成功');
      return true;
    } catch (e, stackTrace) {
      log('启用生物识别失败: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 禁用生物识别
  Future<bool> disableBiometric() async {
    try {
      await PrivacyService.setBiometricEnabled(false);
      state = state.copyWith(isBiometricEnabled: false);
      log('生物识别禁用成功');
      return true;
    } catch (e, stackTrace) {
      log('禁用生物识别失败: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 生物识别验证
  Future<bool> authenticateWithBiometric() async {
    try {
      final isValid = await PrivacyService.authenticateWithBiometric();
      if (isValid) {
        state = state.copyWith(
          needsAuthentication: false,
          isBlurred: false,
        );
        AppLifecycleManager.instance.setBlurState(false);
      }
      return isValid;
    } catch (e, stackTrace) {
      log('生物识别验证失败: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 激活隐私库
  Future<bool> activatePrivateLibrary(String libraryId) async {
    try {
      await PrivacyService.activatePrivateLibrary(libraryId);

      // 更新库仓库中的激活状态
      final libraryRepo = ref.read(libraryRepositoryProvider);
      await libraryRepo.updateLibraryPrivateActivation(libraryId, true);

      // 更新状态
      final updatedList = List<String>.from(state.activatedLibraries)
        ..add(libraryId);
      state = state.copyWith(activatedLibraries: updatedList);

      log('隐私库激活成功: $libraryId');
      return true;
    } catch (e, stackTrace) {
      log('激活隐私库失败: $libraryId, 错误: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 取消激活隐私库
  Future<bool> deactivatePrivateLibrary(String libraryId) async {
    try {
      await PrivacyService.deactivatePrivateLibrary(libraryId);

      // 更新库仓库中的激活状态
      final libraryRepo = ref.read(libraryRepositoryProvider);
      await libraryRepo.updateLibraryPrivateActivation(libraryId, false);

      // 更新状态
      final updatedList = List<String>.from(state.activatedLibraries)
        ..remove(libraryId);
      state = state.copyWith(activatedLibraries: updatedList);

      log('隐私库取消激活成功: $libraryId');
      return true;
    } catch (e, stackTrace) {
      log('取消激活隐私库失败: $libraryId, 错误: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 设置库为隐私模式
  Future<bool> setLibraryPrivate(String libraryId, bool isPrivate) async {
    try {
      final libraryRepo = ref.read(libraryRepositoryProvider);
      await libraryRepo.setLibraryPrivate(libraryId, isPrivate);

      // 如果禁用隐私模式，同时取消激活
      if (!isPrivate && state.activatedLibraries.contains(libraryId)) {
        await deactivatePrivateLibrary(libraryId);
      }

      log('库隐私模式设置成功: $libraryId, isPrivate: $isPrivate');
      return true;
    } catch (e, stackTrace) {
      log('设置库隐私模式失败: $libraryId, 错误: $e,堆栈:$stackTrace');
      return false;
    }
  }

  /// 检查库是否已激活
  bool isLibraryActivated(String libraryId) {
    return state.activatedLibraries.contains(libraryId);
  }

  /// 清除认证需求
  void clearAuthenticationRequest() {
    state = state.copyWith(
      needsAuthentication: false,
      isBlurred: false,
    );
    AppLifecycleManager.instance.clearPrivacyAuth();
  }

  /// 手动触发认证需求
  void requestAuthentication() {
    state = state.copyWith(
      needsAuthentication: true,
      isBlurred: true,
    );
    AppLifecycleManager.instance.requestPrivacyAuth();
  }

  /// 刷新状态
  Future<void> refresh() async {
    await _loadInitialState();
  }

  void dispose() {
    _lifecycleSubscription?.cancel();
    _authSubscription?.cancel();
  }
}

/// 获取隐私库列表
@riverpod
Future<List<MangaLibrary>> privateLibraries(PrivateLibrariesRef ref) async {
  final libraryRepo = ref.read(libraryRepositoryProvider);
  return await libraryRepo.getPrivateLibraries();
}

/// 获取已激活的隐私库列表
@riverpod
Future<List<MangaLibrary>> activatedPrivateLibraries(
    ActivatedPrivateLibrariesRef ref) async {
  final libraryRepo = ref.read(libraryRepositoryProvider);
  return await libraryRepo.getActivatedPrivateLibraries();
}

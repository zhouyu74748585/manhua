import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/library_repository.dart';

/// 应用生命周期管理器
class AppLifecycleManager extends WidgetsBindingObserver {
  static AppLifecycleManager? _instance;
  static AppLifecycleManager get instance {
    _instance ??= AppLifecycleManager._();
    return _instance!;
  }

  AppLifecycleManager._();
  
  /// Provider container for accessing repositories
  ProviderContainer? _container;

  /// 应用状态变化回调
  final StreamController<AppLifecycleState> _stateController =
      StreamController<AppLifecycleState>.broadcast();

  /// 隐私验证需求回调
  final StreamController<bool> _privacyAuthController =
      StreamController<bool>.broadcast();

  /// 应用是否需要模糊化
  bool _needsBlur = false;


  /// 监听应用状态变化
  Stream<AppLifecycleState> get stateStream => _stateController.stream;

  /// 监听隐私验证需求
  Stream<bool> get privacyAuthStream => _privacyAuthController.stream;

  /// 应用是否需要模糊化
  bool get needsBlur => _needsBlur;

  /// 初始化生命周期管理器
  Future<void> initialize(ProviderContainer container) async {
    _container = container;
    WidgetsBinding.instance.addObserver(this);
    log('应用生命周期管理器已初始化');
    
    // 应用启动时，根据PRD要求停用所有隐私库
    try {
      final repository = _container!.read(libraryRepositoryProvider);
      await repository.initializePrivateLibrariesOnStartup();
      log('应用启动时已停用所有隐私库');
    } catch (e) {
      log('应用启动时停用隐私库失败: $e');
    }
  }

  /// 清理资源
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateController.close();
    _privacyAuthController.close();
    log('应用生命周期管理器已清理');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('应用状态变化: $state');

    _stateController.add(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  /// 应用恢复到前台
  Future<void> _onAppResumed() async {
    log('应用恢复到前台');

    try {
      // 检查是否有激活的隐私库（isEnabled=true 且 isPrivate=true）
      final repository = _container!.read(libraryRepositoryProvider);
      final activePrivateLibraries = await repository.getActivatedPrivateLibraries();
      final hasActivePrivateLibraries = activePrivateLibraries.isNotEmpty;
      
      if (hasActivePrivateLibraries) {
        // 如果有激活的隐私库，需要全屏模糊化并要求重新验证
        _needsBlur = true;
        log('检测到激活的隐私库，启用全屏模糊化和重新验证');
        _privacyAuthController.add(true);
      } else {
        _needsBlur = false;
        _privacyAuthController.add(false);
      }
    } catch (e) {
      log('应用恢复处理错误: $e');
      _needsBlur = false;
      _privacyAuthController.add(false);
    }
  }

  /// 应用进入后台
  Future<void> _onAppPaused() async {
    log('应用进入后台');

    try {
      // 检查是否有激活的隐私库
      final repository = _container!.read(libraryRepositoryProvider);
      final activePrivateLibraries = await repository.getActivatedPrivateLibraries();
      
      if (activePrivateLibraries.isNotEmpty) {
        _needsBlur = true;
        log('启用模糊化保护');
        _privacyAuthController.add(true);
      }
    } catch (e) {
      log('应用暂停处理错误: $e');
    }
  }

  /// 应用变为非活跃状态（如接听电话、下拉通知栏等）
  Future<void> _onAppInactive() async {
    log('应用变为非活跃状态');

    try {
      // 检查是否有激活的隐私库
      final repository = _container!.read(libraryRepositoryProvider);
      final activePrivateLibraries = await repository.getActivatedPrivateLibraries();
      
      if (activePrivateLibraries.isNotEmpty) {
        _needsBlur = true;
        log('启用模糊化保护（非活跃状态）');
      }
    } catch (e) {
      log('检查隐私库状态错误: $e');
    }
  }

  /// 应用被隐藏
  Future<void> _onAppHidden() async {
    log('应用被隐藏');

    try {
      // 检查是否有激活的隐私库
      final repository = _container!.read(libraryRepositoryProvider);
      final activePrivateLibraries = await repository.getActivatedPrivateLibraries();
      
      if (activePrivateLibraries.isNotEmpty) {
        _needsBlur = true;
        log('启用模糊化保护（隐藏状态）');
      }
    } catch (e) {
      log('检查隐私库状态错误: $e');
    }
  }

  /// 应用分离
  void _onAppDetached() {
    log('应用分离');
  }

  /// 手动触发隐私验证
  void requestPrivacyAuth() {
    _privacyAuthController.add(true);
  }

  /// 清除隐私验证需求
  void clearPrivacyAuth() {
    _privacyAuthController.add(false);
  }

  /// 设置模糊化状态
  void setBlurState(bool needsBlur) {
    _needsBlur = needsBlur;
  }
}

/// 模糊化遮罩组件
class PrivacyBlurOverlay extends StatelessWidget {
  final Widget child;
  final bool isBlurred;
  final VoidCallback? onTap;

  const PrivacyBlurOverlay({
    super.key,
    required this.child,
    required this.isBlurred,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isBlurred)
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '隐私保护已启用',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '点击屏幕进行身份验证',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

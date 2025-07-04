import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'privacy_service.dart';

/// 应用生命周期管理器
class AppLifecycleManager extends WidgetsBindingObserver {
  static AppLifecycleManager? _instance;
  static AppLifecycleManager get instance {
    _instance ??= AppLifecycleManager._();
    return _instance!;
  }

  AppLifecycleManager._();

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
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    log('应用生命周期管理器已初始化');
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

    // 取消模糊化
    _needsBlur = false;

    // 检查是否需要隐私验证
    final needsAuth = !await PrivacyService.onAppResumed();
    if (needsAuth) {
      log('需要隐私验证');
      _privacyAuthController.add(true);
    }
  }

  /// 应用进入后台
  Future<void> _onAppPaused() async {
    log('应用进入后台');

    // 如果有激活的隐私库，启用模糊化
    if (PrivacyService.activatedLibraries.isNotEmpty) {
      _needsBlur = true;
      log('启用模糊化保护');
    }

    await PrivacyService.onAppPaused();
  }

  /// 应用变为非活跃状态（如接听电话、下拉通知栏等）
  void _onAppInactive() {
    log('应用变为非活跃状态');

    // 如果有激活的隐私库，启用模糊化
    if (PrivacyService.activatedLibraries.isNotEmpty) {
      _needsBlur = true;
      log('启用模糊化保护（非活跃状态）');
    }
  }

  /// 应用被隐藏
  void _onAppHidden() {
    log('应用被隐藏');

    // 如果有激活的隐私库，启用模糊化
    if (PrivacyService.activatedLibraries.isNotEmpty) {
      _needsBlur = true;
      log('启用模糊化保护（隐藏状态）');
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

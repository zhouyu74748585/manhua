import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_lifecycle_manager.dart';
import '../../providers/privacy_provider.dart';
import 'general_auth_dialog.dart';

/// 隐私保护应用包装器
class PrivacyAppWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const PrivacyAppWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<PrivacyAppWrapper> createState() => _PrivacyAppWrapperState();
}

class _PrivacyAppWrapperState extends ConsumerState<PrivacyAppWrapper> {
  @override
  void initState() {
    super.initState();
    
    // 初始化应用生命周期管理器
    _initializeLifecycleManager();
  }
  
  Future<void> _initializeLifecycleManager() async {
    try {
      await AppLifecycleManager.instance.initialize();
    } catch (e) {
      // 忽略初始化错误，但记录日志
      debugPrint('应用生命周期管理器初始化失败: $e');
    }
  }

  @override
  void dispose() {
    AppLifecycleManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyNotifierProvider);

    return Stack(
      children: [
        // 主应用内容
        widget.child,

        // 隐私保护遮罩
        if (privacyState.isBlurred || privacyState.needsAuthentication)
          const PrivacyOverlay(),
      ],
    );
  }
}

/// 隐私保护遮罩
class PrivacyOverlay extends ConsumerWidget {
  const PrivacyOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyState = ref.watch(privacyNotifierProvider);

    return Positioned.fill(
      child: Material(
        color: Colors.black87,
        child: GestureDetector(
          onTap: () => _showAuthDialog(context, ref),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.9),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 锁定图标
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 标题
                  const Text(
                    '隐私保护已启用',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 描述
                  Text(
                    _getDescription(privacyState),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 解锁按钮
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAuthDialog(context, ref),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text(
                        '点击解锁',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 提示文本
                  const Text(
                    '使用密码或生物识别进行身份验证',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取描述文本
  String _getDescription(PrivacyState state) {
    if (state.activatedLibraries.isNotEmpty) {
      final count = state.activatedLibraries.length;
      return '检测到 $count 个隐私库处于激活状态\n需要验证身份以继续访问';
    } else {
      return '应用已进入隐私保护模式\n请验证身份以继续使用';
    }
  }

  /// 显示认证对话框
  Future<void> _showAuthDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GeneralAuthDialog(
        title: '身份验证',
        message: '请验证身份以解除隐私保护',
        canCancel: false,
      ),
    );

    if (result == true) {
      // 认证成功，清除保护状态
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
      privacyNotifier.clearAuthenticationRequest();
    }
  }
}

/// 简化版隐私保护遮罩（用于特定场景）
class SimplePrivacyBlur extends StatelessWidget {
  final Widget child;
  final bool isBlurred;
  final VoidCallback? onTap;
  final String? message;

  const SimplePrivacyBlur({
    super.key,
    required this.child,
    required this.isBlurred,
    this.onTap,
    this.message,
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message ?? '内容已被隐私保护',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '点击进行身份验证',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

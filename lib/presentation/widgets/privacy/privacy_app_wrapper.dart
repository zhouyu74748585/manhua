import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/global_navigator.dart';
import '../../../core/services/app_lifecycle_manager.dart';
import '../../../core/services/privacy_service.dart';
import '../../providers/privacy_provider.dart';
import 'enhanced_privacy_auth_dialog.dart';

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
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 确保只初始化一次
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeLifecycleManager();
    }
  }

  Future<void> _initializeLifecycleManager() async {
    try {
      final container = ProviderScope.containerOf(context);
      await AppLifecycleManager.instance.initialize(container);
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
          PrivacyOverlay(
            onAuthRequest: () => _showAuthDialog(context, ref),
          ),
      ],
    );
  }

  /// 显示认证对话框
  void _showAuthDialog(BuildContext context, WidgetRef ref) {
    final privacyState = ref.read(privacyNotifierProvider);

    // 使用延迟执行，等待Navigator准备就绪
    Future.delayed(const Duration(milliseconds: 100), () async {
      // 尝试使用全局NavigatorKey
      final navigatorContext = globalNavigatorKey.currentContext;
      if (navigatorContext != null) {
        await _performAuthentication(navigatorContext, ref, privacyState);
      } else {
        // 如果全局key不可用，尝试使用当前context
        await _performAuthentication(context, ref, privacyState);
      }
    });
  }

  /// 执行认证逻辑
  Future<void> _performAuthentication(
    BuildContext context,
    WidgetRef ref,
    PrivacyState privacyState,
  ) async {
    try {
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);

      // 使用增强的认证对话框，支持密码和生物识别
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EnhancedPrivacyAuthDialog(
          title: '隐私验证',
          message: '请验证身份以访问应用',
          canCancel: false,
        ),
      );

      if (result == true) {
        // 验证成功，清除保护状态
        privacyNotifier.clearAuthenticationRequest();
      }
    } catch (e) {
      // 如果仍然失败，记录错误但不崩溃
      print('认证对话框显示失败: $e');
    }
  }
}

/// 隐私保护遮罩
class PrivacyOverlay extends ConsumerStatefulWidget {
  final VoidCallback onAuthRequest;

  const PrivacyOverlay({
    super.key,
    required this.onAuthRequest,
  });

  @override
  ConsumerState<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends ConsumerState<PrivacyOverlay> {
  bool _showingAuthDialog = false;

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyNotifierProvider);

    return Positioned.fill(
      child: Material(
        color: Colors.black87,
        child: Stack(
          children: [
            // 背景遮罩 - 锁屏状态
            if (!_showingAuthDialog)
              GestureDetector(
                onTap: _handleAuthRequest,
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
                            onPressed: _handleAuthRequest,
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

            // 认证状态的增强背景遮罩
            if (_showingAuthDialog)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.95),
                        Colors.black.withValues(alpha: 0.98),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),

            // 认证对话框层
            if (_showingAuthDialog)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  child: _AuthDialogWrapper(
                    onResult: _handleAuthResult,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 处理认证请求
  void _handleAuthRequest() {
    if (_showingAuthDialog) return;

    setState(() {
      _showingAuthDialog = true;
    });
  }

  /// 处理认证结果
  void _handleAuthResult(bool success) {
    setState(() {
      _showingAuthDialog = false;
    });

    if (success) {
      // 验证成功，清除保护状态
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
      privacyNotifier.clearAuthenticationRequest();
    }
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

/// 认证对话框包装器
class _AuthDialogWrapper extends ConsumerStatefulWidget {
  final Function(bool) onResult;

  const _AuthDialogWrapper({
    required this.onResult,
  });

  @override
  ConsumerState<_AuthDialogWrapper> createState() => _AuthDialogWrapperState();
}

class _AuthDialogWrapperState extends ConsumerState<_AuthDialogWrapper> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _AuthDialogContent(
        onResult: widget.onResult,
      ),
    );
  }
}

/// 认证对话框内容
class _AuthDialogContent extends ConsumerStatefulWidget {
  final Function(bool) onResult;

  const _AuthDialogContent({
    required this.onResult,
  });

  @override
  ConsumerState<_AuthDialogContent> createState() => _AuthDialogContentState();
}

class _AuthDialogContentState extends ConsumerState<_AuthDialogContent> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 初始化认证选项
  Future<void> _initializeAuth() async {
    try {
      final isBiometricAvailable = await PrivacyService.isBiometricAvailable();
      final isBiometricEnabled = await PrivacyService.isBiometricEnabled();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isBiometricAvailable;
          _isBiometricEnabled = isBiometricEnabled;
        });
      }
    } catch (e) {
      // 忽略错误，继续使用密码验证
    }
  }

  /// 密码验证
  Future<void> _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final isValid =
          await PrivacyService.verifyPassword(_passwordController.text);

      if (isValid) {
        widget.onResult(true);
      } else {
        _showError('密码错误');
      }
    } catch (e) {
      _showError('验证失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 生物识别验证
  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final isAuthenticated = await PrivacyService.authenticateWithBiometric();

      if (isAuthenticated) {
        widget.onResult(true);
      } else {
        _showError('生物识别验证失败');
      }
    } catch (e) {
      _showError('生物识别验证失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 显示错误信息
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              const Text(
                '隐私验证',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 描述
              const Text(
                '请验证身份以访问应用',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 密码输入框
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_isPasswordVisible,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _verifyPassword(),
              ),

              const SizedBox(height: 16),

              // 错误信息
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

              // 按钮区域
              Row(
                children: [
                  // 密码验证按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _verifyPassword,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.key),
                      label: const Text('密码验证'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // 生物识别按钮（如果可用）
                  if (_isBiometricAvailable && _isBiometricEnabled) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _isLoading ? null : _authenticateWithBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('生物识别'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 取消按钮
              TextButton(
                onPressed: _isLoading ? null : () => widget.onResult(false),
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

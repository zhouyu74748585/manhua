import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/privacy_service.dart';
import '../../providers/privacy_provider.dart';

/// 增强的隐私验证对话框
/// 支持密码和生物识别验证，符合PRD要求
class EnhancedPrivacyAuthDialog extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final bool canCancel;
  final List<String>? specificLibraryIds; // 特定库ID，用于库级验证

  const EnhancedPrivacyAuthDialog({
    super.key,
    this.title = '身份验证',
    this.message = '请验证身份以继续访问',
    this.canCancel = true,
    this.specificLibraryIds,
  });

  @override
  ConsumerState<EnhancedPrivacyAuthDialog> createState() =>
      _EnhancedPrivacyAuthDialogState();
}

class _EnhancedPrivacyAuthDialogState
    extends ConsumerState<EnhancedPrivacyAuthDialog>
    with TickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  String _errorMessage = '';
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _setupAnimations();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  
  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }
  
  Future<void> _initializeAuth() async {
    try {
      _isBiometricAvailable = await PrivacyService.isBiometricAvailable();
      _isBiometricEnabled = await PrivacyService.isBiometricEnabled();
      _availableBiometrics = await PrivacyService.getAvailableBiometrics();
      
      if (mounted) {
        setState(() {});
        
        // 如果启用了生物识别，自动尝试
        if (_isBiometricAvailable && _isBiometricEnabled) {
          await _authenticateWithBiometric();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '初始化验证失败: $e';
        });
      }
    }
  }
  
  Future<void> _authenticateWithPassword() async {
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
      final isValid = await privacyNotifier.verifyPassword(_passwordController.text);
      
      if (isValid) {
        // 如果是特定库验证，激活这些库
        if (widget.specificLibraryIds != null) {
          for (final libraryId in widget.specificLibraryIds!) {
            await privacyNotifier.activatePrivateLibrary(libraryId);
          }
        }
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showError('密码错误');
        _shakeController.forward().then((_) => _shakeController.reset());
        HapticFeedback.vibrate();
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
  
  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
      final isValid = await privacyNotifier.authenticateWithBiometric();
      
      if (isValid) {
        // 如果是特定库验证，激活这些库
        if (widget.specificLibraryIds != null) {
          for (final libraryId in widget.specificLibraryIds!) {
            await privacyNotifier.activatePrivateLibrary(libraryId);
          }
        }
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showError('生物识别验证失败');
        HapticFeedback.vibrate();
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
  
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    // 3秒后清除错误信息
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }
  
  String _getBiometricDisplayName() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return '面部识别';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return '指纹识别';
    } else {
      return '生物识别';
    }
  }
  
  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canCancel,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 消息
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 24),
              
              // 密码输入
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_isPasswordVisible,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: '密码',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                      ),
                      onSubmitted: (_) => _authenticateWithPassword(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // 验证按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _authenticateWithPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('验证密码'),
                ),
              ),
              
              // 生物识别选项
              if (_isBiometricAvailable && _isBiometricEnabled) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _authenticateWithBiometric,
                    icon: Icon(_getBiometricIcon()),
                    label: Text('使用${_getBiometricDisplayName()}'),
                  ),
                ),
              ],
              
              // 提示信息
              if (widget.specificLibraryIds != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '验证成功后将激活 ${widget.specificLibraryIds!.length} 个隐私库',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (widget.canCancel)
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
        ],
      ),
    );
  }
}
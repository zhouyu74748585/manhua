import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/privacy_service.dart';

/// 隐私模式认证对话框
class PrivacyAuthDialog extends StatefulWidget {
  final String libraryId;
  final String libraryName;
  final String? title;
  final String? message;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PrivacyAuthDialog({
    super.key,
    required this.libraryId,
    required this.libraryName,
    this.title,
    this.message,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<PrivacyAuthDialog> createState() => _PrivacyAuthDialogState();
}

class _PrivacyAuthDialogState extends State<PrivacyAuthDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await PrivacyService.isBiometricAvailable();
    final isEnabled = await PrivacyService.isBiometricEnabled();
    final biometrics = await PrivacyService.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _availableBiometrics = biometrics;
      });

      // 如果启用了生物识别，自动尝试
      if (_isBiometricAvailable && _isBiometricEnabled) {
        _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入密码';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await PrivacyService.verifyPassword(
        _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          widget.onSuccess?.call();
        }
      } else {
        setState(() {
          _errorMessage = '密码错误';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '验证失败: $e';
      });
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
      _errorMessage = null;
    });

    try {
      final success = await PrivacyService.authenticateWithBiometric();

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          widget.onSuccess?.call();
        }
      } else {
        setState(() {
          _errorMessage = '生物识别验证失败';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '验证失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return '👤';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return '👆';
    } else {
      return '🔐';
    }
  }

  String _getBiometricText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return '面部识别';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return '指纹识别';
    } else {
      return '生物识别';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title ?? '访问隐私库',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message ?? '"${widget.libraryName}" 是隐私库，需要验证身份才能访问。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // 生物识别按钮
            if (_isBiometricAvailable && _isBiometricEnabled)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _authenticateWithBiometric,
                  icon: Text(
                    _getBiometricIcon(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  label: Text(_getBiometricText()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // 分隔线
            if (_isBiometricAvailable && _isBiometricEnabled)
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '或',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

            if (_isBiometricAvailable && _isBiometricEnabled)
              const SizedBox(height: 16),

            // 密码输入
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: const Icon(Icons.key),
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
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _authenticateWithPassword(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _authenticateWithPassword,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确认'),
        ),
      ],
    );
  }
}

/// 显示隐私认证对话框
Future<bool?> showPrivacyAuthDialog(
  BuildContext context, {
  required String libraryId,
  required String libraryName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PrivacyAuthDialog(
      libraryId: libraryId,
      libraryName: libraryName,
      onSuccess: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}

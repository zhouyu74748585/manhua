import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/privacy_service.dart';

/// 统一的密码管理对话框
/// 支持密码设置、修改和验证
class UnifiedPasswordDialog extends StatefulWidget {
  final PasswordDialogType type;
  final String? title;
  final String? message;
  final String? libraryId;
  final String? libraryName;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool canCancel;

  const UnifiedPasswordDialog({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.libraryId,
    this.libraryName,
    this.onSuccess,
    this.onCancel,
    this.canCancel = true,
  });

  @override
  State<UnifiedPasswordDialog> createState() => _UnifiedPasswordDialogState();
}

class _UnifiedPasswordDialogState extends State<UnifiedPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isOldPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.type == PasswordDialogType.verify) {
      _checkBiometricAvailability();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _oldPasswordController.dispose();
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

  Future<void> _handleConfirm() async {
    switch (widget.type) {
      case PasswordDialogType.setup:
        await _setupPassword();
        break;
      case PasswordDialogType.change:
        await _changePassword();
        break;
      case PasswordDialogType.verify:
        await _verifyPassword();
        break;
    }
  }

  Future<void> _setupPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = '请输入密码';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = '密码长度至少6位';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PrivacyService.setPassword(password);
      if (mounted) {
        Navigator.of(context).pop(password);
        widget.onSuccess?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '设置密码失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _passwordController.text;
    final confirm = _confirmController.text;

    if (oldPassword.isEmpty) {
      setState(() {
        _errorMessage = '请输入当前密码';
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = '请输入新密码';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = '新密码长度至少6位';
      });
      return;
    }

    if (newPassword != confirm) {
      setState(() {
        _errorMessage = '两次输入的新密码不一致';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await PrivacyService.verifyPassword(oldPassword);
      if (!isValid) {
        setState(() {
          _errorMessage = '当前密码错误';
        });
        return;
      }

      await PrivacyService.setPassword(newPassword);
      if (mounted) {
        Navigator.of(context).pop(newPassword);
        widget.onSuccess?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '修改密码失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPassword() async {
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

  String get _dialogTitle {
    if (widget.title != null) return widget.title!;
    
    switch (widget.type) {
      case PasswordDialogType.setup:
        return '设置密码';
      case PasswordDialogType.change:
        return '修改密码';
      case PasswordDialogType.verify:
        return widget.libraryName != null ? '访问隐私库' : '验证密码';
    }
  }

  String get _dialogMessage {
    if (widget.message != null) return widget.message!;
    
    switch (widget.type) {
      case PasswordDialogType.setup:
        return '请设置一个至少6位的密码来保护您的隐私库。';
      case PasswordDialogType.change:
        return '请输入当前密码和新密码。';
      case PasswordDialogType.verify:
        return widget.libraryName != null 
            ? '"${widget.libraryName}" 是隐私库，需要验证身份才能访问。'
            : '请输入密码进行验证。';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.type == PasswordDialogType.verify 
                ? Icons.lock 
                : Icons.security,
            color: widget.type == PasswordDialogType.verify 
                ? Colors.orange 
                : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _dialogTitle,
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
              _dialogMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // 生物识别按钮（仅验证时显示）
            if (widget.type == PasswordDialogType.verify &&
                _isBiometricAvailable &&
                _isBiometricEnabled)
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

            // 分隔线（仅验证时显示）
            if (widget.type == PasswordDialogType.verify &&
                _isBiometricAvailable &&
                _isBiometricEnabled)
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

            if (widget.type == PasswordDialogType.verify &&
                _isBiometricAvailable &&
                _isBiometricEnabled)
              const SizedBox(height: 16),

            // 当前密码输入（仅修改密码时显示）
            if (widget.type == PasswordDialogType.change) ...[
              TextField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: '当前密码',
                  hintText: '请输入当前密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 密码输入
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: widget.type == PasswordDialogType.change 
                    ? '新密码' 
                    : '密码',
                hintText: widget.type == PasswordDialogType.verify
                    ? '请输入密码'
                    : '请输入密码（至少6位）',
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
              onSubmitted: widget.type == PasswordDialogType.verify 
                  ? (_) => _handleConfirm()
                  : null,
            ),

            // 确认密码输入（设置和修改密码时显示）
            if (widget.type == PasswordDialogType.setup ||
                widget.type == PasswordDialogType.change) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: !_isConfirmVisible,
                decoration: InputDecoration(
                  labelText: widget.type == PasswordDialogType.change 
                      ? '确认新密码' 
                      : '确认密码',
                  hintText: widget.type == PasswordDialogType.change
                      ? '请再次输入新密码'
                      : '请再次输入密码',
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmVisible = !_isConfirmVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.canCancel)
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
          onPressed: _isLoading ? null : _handleConfirm,
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

/// 密码对话框类型
enum PasswordDialogType {
  setup,   // 设置密码
  change,  // 修改密码
  verify,  // 验证密码
}

/// 显示密码设置对话框
Future<String?> showPasswordSetupDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const UnifiedPasswordDialog(
      type: PasswordDialogType.setup,
    ),
  );
}

/// 显示密码修改对话框
Future<String?> showPasswordChangeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const UnifiedPasswordDialog(
      type: PasswordDialogType.change,
    ),
  );
}

/// 显示密码验证对话框
Future<bool?> showPasswordVerifyDialog(
  BuildContext context, {
  String? libraryId,
  String? libraryName,
  String? title,
  String? message,
  bool canCancel = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: canCancel,
    builder: (context) => UnifiedPasswordDialog(
      type: PasswordDialogType.verify,
      libraryId: libraryId,
      libraryName: libraryName,
      title: title,
      message: message,
      canCancel: canCancel,
    ),
  );
}

/// 显示隐私认证对话框（兼容旧接口）
Future<bool?> showPrivacyAuthDialog(
  BuildContext context, {
  required String libraryId,
  required String libraryName,
}) {
  return showPasswordVerifyDialog(
    context,
    libraryId: libraryId,
    libraryName: libraryName,
  );
}
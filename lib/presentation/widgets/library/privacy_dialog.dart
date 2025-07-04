import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../../data/services/privacy_service.dart';

class PrivacyDialog extends StatefulWidget {
  final String libraryId;
  final String libraryName;
  final bool isPrivate;
  final VoidCallback? onPasswordSet;
  final VoidCallback? onBiometricSet;
  final VoidCallback? onPrivacyDisabled;

  const PrivacyDialog({
    super.key,
    required this.libraryId,
    required this.libraryName,
    required this.isPrivate,
    this.onPasswordSet,
    this.onBiometricSet,
    this.onPrivacyDisabled,
  });

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
        _isCheckingBiometric = false;
      });
    } catch (e,stackTrace) {
      setState(() {
        _isBiometricAvailable = false;
        _isCheckingBiometric = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.libraryName} - 隐私设置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isPrivate) ...
            _buildDisablePrivacySection()
          else ...
            _buildEnablePrivacySection(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  List<Widget> _buildEnablePrivacySection() {
    return [
      const Text(
        '为此漫画库启用隐私保护，访问时需要验证身份。',
        style: TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 16),
      ListTile(
        leading: const Icon(Icons.lock),
        title: const Text('密码保护'),
        subtitle: const Text('设置密码来保护此漫画库'),
        onTap: () {
          Navigator.of(context).pop();
          _showPasswordSetupDialog();
        },
      ),
      if (_isCheckingBiometric)
        const ListTile(
          leading: CircularProgressIndicator(),
          title: Text('检查生物识别支持...'),
        )
      else if (_isBiometricAvailable)
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('生物识别'),
          subtitle: const Text('使用指纹或面部识别保护此漫画库'),
          onTap: () {
            Navigator.of(context).pop();
            _setupBiometric();
          },
        ),
    ];
  }

  List<Widget> _buildDisablePrivacySection() {
    return [
      const Text(
        '此漫画库已启用隐私保护。',
        style: TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 16),
      ListTile(
        leading: const Icon(Icons.lock_open, color: Colors.red),
        title: const Text('关闭隐私保护'),
        subtitle: const Text('移除此漫画库的隐私保护'),
        onTap: () async {
          Navigator.of(context).pop();
          // 清除所有隐私设置
          await PrivacyService.clearLibraryPrivacySettings(widget.libraryId);
          widget.onPrivacyDisabled?.call();
        },
      ),
    ];
  }

  void _showPasswordSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => PasswordSetupDialog(
        libraryId: widget.libraryId,
        libraryName: widget.libraryName,
        onPasswordSet: widget.onPasswordSet,
      ),
    );
  }

  Future<void> _setupBiometric() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: '验证身份以启用生物识别保护',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // 启用生物识别保护
        await PrivacyService.setLibraryBiometric(widget.libraryId, true);
        widget.onBiometricSet?.call();
      }
    } on PlatformException catch (e,stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生物识别设置失败: ${e.message}')),
        );
      }
    }
  }
}

class PasswordSetupDialog extends StatefulWidget {
  final String libraryId;
  final String libraryName;
  final VoidCallback? onPasswordSet;

  const PasswordSetupDialog({
    super.key,
    required this.libraryId,
    required this.libraryName,
    this.onPasswordSet,
  });

  @override
  State<PasswordSetupDialog> createState() => _PasswordSetupDialogState();
}

class _PasswordSetupDialogState extends State<PasswordSetupDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.libraryName} - 设置密码'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                if (value.length < 4) {
                  return '密码至少需要4位';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: '确认密码',
                hintText: '请再次输入密码',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请确认密码';
                }
                if (value != _passwordController.text) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _setPassword,
          child: const Text('确定'),
        ),
      ],
    );
  }

  void _setPassword() async {
    if (_formKey.currentState!.validate()) {
      // 保存密码
      await PrivacyService.setLibraryPassword(widget.libraryId, _passwordController.text);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPasswordSet?.call();
      }
    }
  }
}

class PrivacyVerificationDialog extends StatefulWidget {
  final String libraryId;
  final String libraryName;
  final PrivacyAuthMethod authMethod;
  final VoidCallback? onVerified;

  const PrivacyVerificationDialog({
    super.key,
    required this.libraryId,
    required this.libraryName,
    required this.authMethod,
    this.onVerified,
  });

  @override
  State<PrivacyVerificationDialog> createState() =>
      _PrivacyVerificationDialogState();
}

class _PrivacyVerificationDialogState extends State<PrivacyVerificationDialog> {
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _obscurePassword = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.authMethod == PrivacyAuthMethod.biometric) {
      _tryBiometricAuth();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricAuth() async {
    try {
      setState(() {
        _isVerifying = true;
      });

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: '验证身份以访问 ${widget.libraryName}',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // 设置激活状态
        await PrivacyService.setLibraryActivationStatus(widget.libraryId, true);

        if (mounted) {
          Navigator.of(context).pop();
          widget.onVerified?.call();
        }
      }
    } on PlatformException catch (e,stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生物识别验证失败: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('访问 ${widget.libraryName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('此漫画库已启用隐私保护，请验证身份后访问。'),
          const SizedBox(height: 16),
          if (widget.authMethod == PrivacyAuthMethod.password) ...
            _buildPasswordInput()
          else if (widget.authMethod == PrivacyAuthMethod.biometric) ...
            _buildBiometricSection(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (widget.authMethod == PrivacyAuthMethod.password)
          ElevatedButton(
            onPressed: _verifyPassword,
            child: const Text('验证'),
          ),
      ],
    );
  }

  List<Widget> _buildPasswordInput() {
    return [
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: '密码',
          hintText: '请输入密码',
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        onSubmitted: (_) => _verifyPassword(),
      ),
    ];
  }

  List<Widget> _buildBiometricSection() {
    return [
      if (_isVerifying)
        const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在进行生物识别验证...'),
          ],
        )
      else
        Column(
          children: [
            const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _tryBiometricAuth,
              icon: const Icon(Icons.fingerprint),
              label: const Text('重新验证'),
            ),
          ],
        ),
    ];
  }

  void _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入密码')),
      );
      return;
    }

    final isValid = await PrivacyService.verifyLibraryPassword(
      widget.libraryId,
      _passwordController.text,
    );

    if (isValid) {
      // 设置激活状态
      await PrivacyService.setLibraryActivationStatus(widget.libraryId, true);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onVerified?.call();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码错误')),
        );
      }
    }
  }
}

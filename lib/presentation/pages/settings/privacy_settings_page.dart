import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/privacy_service.dart';
import '../../providers/library_provider.dart';

/// 隐私设置页面
class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool _hasPassword = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasPassword = await PrivacyService.hasPassword();
      final isBiometricAvailable = await PrivacyService.isBiometricAvailable();
      final isBiometricEnabled = await PrivacyService.isBiometricEnabled();
      final availableBiometrics = await PrivacyService.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _hasPassword = hasPassword;
          _isBiometricAvailable = isBiometricAvailable;
          _isBiometricEnabled = isBiometricEnabled;
          _availableBiometrics = availableBiometrics;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setPassword() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordSetupDialog(),
    );

    if (result != null) {
      await PrivacyService.setPassword(result);
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码设置成功')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _PasswordChangeDialog(),
    );

    if (result != null) {
      await PrivacyService.setPassword(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码修改成功')),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled && !_hasPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先设置密码')),
      );
      return;
    }

    await PrivacyService.setBiometricEnabled(enabled);
    await _loadSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled ? '生物识别已启用' : '生物识别已禁用'),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final librariesAsync = ref.watch(allLibrariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 认证设置
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '认证设置',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        // 密码设置
                        ListTile(
                          leading: const Icon(Icons.key),
                          title: const Text('密码'),
                          subtitle: Text(_hasPassword ? '已设置' : '未设置'),
                          trailing: TextButton(
                            onPressed: _hasPassword ? _changePassword : _setPassword,
                            child: Text(_hasPassword ? '修改' : '设置'),
                          ),
                        ),
                        
                        // 生物识别设置
                        if (_isBiometricAvailable)
                          SwitchListTile(
                            secondary: const Icon(Icons.fingerprint),
                            title: Text(_getBiometricDisplayName()),
                            subtitle: Text(
                              _isBiometricEnabled ? '已启用' : '已禁用',
                            ),
                            value: _isBiometricEnabled,
                            onChanged: _toggleBiometric,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 隐私库管理
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '隐私库管理',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        librariesAsync.when(
                          data: (libraries) {
                            final privateLibraries = libraries.where((lib) => lib.isPrivate).toList();
                            
                            if (privateLibraries.isEmpty) {
                              return const ListTile(
                                leading: Icon(Icons.info_outline),
                                title: Text('暂无隐私库'),
                                subtitle: Text('在库设置中可以将库设置为隐私模式'),
                              );
                            }
                            
                            return Column(
                              children: privateLibraries.map((library) {
                                final isActivated = PrivacyService.isLibraryActivated(library.id);
                                
                                return ListTile(
                                  leading: Icon(
                                    Icons.folder_special,
                                    color: isActivated ? Colors.green : Colors.grey,
                                  ),
                                  title: Text(library.name),
                                  subtitle: Text(
                                    isActivated ? '已激活' : '未激活',
                                    style: TextStyle(
                                      color: isActivated ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  trailing: isActivated
                                      ? TextButton(
                                          onPressed: () async {
                                            await PrivacyService.deactivatePrivateLibrary(library.id);
                                            setState(() {});
                                          },
                                          child: const Text('取消激活'),
                                        )
                                      : null,
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => ListTile(
                            leading: const Icon(Icons.error),
                            title: const Text('加载失败'),
                            subtitle: Text(error.toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 安全说明
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '安全说明',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 隐私库在应用重启后需要重新验证\n'
                          '• 应用从后台恢复时，如有激活的隐私库需要重新验证\n'
                          '• 取消激活隐私库不需要验证\n'
                          '• 建议同时启用密码和生物识别以提高安全性',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 密码设置对话框
class _PasswordSetupDialog extends StatefulWidget {
  const _PasswordSetupDialog();

  @override
  State<_PasswordSetupDialog> createState() => _PasswordSetupDialogState();
}

class _PasswordSetupDialogState extends State<_PasswordSetupDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _confirm() {
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

    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置密码'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码（至少6位）',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: !_isConfirmVisible,
            decoration: InputDecoration(
              labelText: '确认密码',
              hintText: '请再次输入密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmVisible = !_isConfirmVisible;
                  });
                },
              ),
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _confirm,
          child: const Text('确认'),
        ),
      ],
    );
  }
}

/// 密码修改对话框
class _PasswordChangeDialog extends StatefulWidget {
  const _PasswordChangeDialog();

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmVisible = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
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

      Navigator.of(context).pop(newPassword);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改密码'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _oldPasswordController,
            obscureText: !_isOldPasswordVisible,
            decoration: InputDecoration(
              labelText: '当前密码',
              hintText: '请输入当前密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isOldPasswordVisible = !_isOldPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            decoration: InputDecoration(
              labelText: '新密码',
              hintText: '请输入新密码（至少6位）',
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: !_isConfirmVisible,
            decoration: InputDecoration(
              labelText: '确认新密码',
              hintText: '请再次输入新密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmVisible = !_isConfirmVisible;
                  });
                },
              ),
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirm,
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
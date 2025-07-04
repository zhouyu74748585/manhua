import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/privacy_service.dart';
import '../../widgets/privacy/unified_password_dialog.dart';
import '../../providers/library_provider.dart';

/// 隐私设置页面
class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
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
    final result = await showPasswordSetupDialog(context);

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await PrivacyService.setPassword(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('密码设置成功')),
          );
          await _loadSettings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('设置密码失败: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await showPasswordChangeDialog(context);

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await PrivacyService.setPassword(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('密码修改成功')),
          );
          await _loadSettings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('修改密码失败: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                            onPressed:
                                _hasPassword ? _changePassword : _setPassword,
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
                            final privateLibraries = libraries
                                .where((lib) => lib.isPrivate)
                                .toList();

                            if (privateLibraries.isEmpty) {
                              return const ListTile(
                                leading: Icon(Icons.info_outline),
                                title: Text('暂无隐私库'),
                                subtitle: Text('在库设置中可以将库设置为隐私模式'),
                              );
                            }

                            return Column(
                              children: privateLibraries.map((library) {
                                final isActivated =
                                    PrivacyService.isLibraryActivated(
                                        library.id);

                                return ListTile(
                                  leading: Icon(
                                    Icons.folder_special,
                                    color: isActivated
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  title: Text(library.name),
                                  subtitle: Text(
                                    isActivated ? '已激活' : '未激活',
                                    style: TextStyle(
                                      color: isActivated
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                  trailing: isActivated
                                      ? TextButton(
                                          onPressed: () async {
                                            await PrivacyService
                                                .deactivatePrivateLibrary(
                                                    library.id);
                                            setState(() {});
                                          },
                                          child: const Text('取消激活'),
                                        )
                                      : null,
                                );
                              }).toList(),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
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

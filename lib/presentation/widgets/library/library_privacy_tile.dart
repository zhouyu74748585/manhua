import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/library.dart';
import '../../providers/privacy_provider.dart';
import '../privacy/privacy_auth_dialog.dart';

/// 库隐私模式设置组件
class LibraryPrivacyTile extends ConsumerWidget {
  final MangaLibrary library;
  final VoidCallback? onChanged;
  
  const LibraryPrivacyTile({
    super.key,
    required this.library,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyNotifier = ref.read(privacyNotifierProvider.notifier);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          library.isPrivate ? Icons.lock : Icons.lock_open,
          color: library.isPrivate ? Colors.orange : Colors.grey,
        ),
        title: Text(
          library.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          library.isPrivate 
            ? (library.isPrivateActivated ? '隐私模式 - 已激活' : '隐私模式 - 未激活')
            : '普通模式',
          style: TextStyle(
            color: library.isPrivate 
              ? (library.isPrivateActivated ? Colors.green : Colors.orange)
              : Colors.grey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 隐私模式开关
                SwitchListTile(
                  title: const Text('启用隐私模式'),
                  subtitle: const Text('启用后需要密码或生物识别才能访问'),
                  value: library.isPrivate,
                  onChanged: (value) => _togglePrivateMode(
                    context, 
                    ref, 
                    privacyNotifier, 
                    value,
                  ),
                ),
                
                if (library.isPrivate) ...[
                  const Divider(),
                  
                  // 激活状态显示
                  ListTile(
                    leading: Icon(
                      library.isPrivateActivated 
                        ? Icons.check_circle 
                        : Icons.radio_button_unchecked,
                      color: library.isPrivateActivated 
                        ? Colors.green 
                        : Colors.grey,
                    ),
                    title: Text(
                      library.isPrivateActivated ? '已激活' : '未激活',
                      style: TextStyle(
                        color: library.isPrivateActivated 
                          ? Colors.green 
                          : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      library.isPrivateActivated 
                        ? '当前可以访问此隐私库的内容'
                        : '需要验证身份才能访问此隐私库',
                    ),
                  ),
                  
                  // 激活/取消激活按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (!library.isPrivateActivated) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _activateLibrary(
                                context, 
                                ref, 
                                privacyNotifier,
                              ),
                              icon: const Icon(Icons.lock_open),
                              label: const Text('激活访问'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _deactivateLibrary(
                                context, 
                                ref, 
                                privacyNotifier,
                              ),
                              icon: const Icon(Icons.lock),
                              label: const Text('取消激活'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 安全提示
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '隐私库在每次重新进入应用时会自动取消激活，需要重新验证身份。',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 切换隐私模式
  Future<void> _togglePrivateMode(
    BuildContext context,
    WidgetRef ref,
    PrivacyNotifier privacyNotifier,
    bool value,
  ) async {
    if (value) {
      // 启用隐私模式前检查是否已设置密码
      final privacyState = ref.read(privacyNotifierProvider);
      if (!privacyState.isPasswordSet) {
        _showPasswordRequiredDialog(context);
        return;
      }
    }
    
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final success = await privacyNotifier.setLibraryPrivate(
        library.id, 
        value,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        
        if (success) {
          onChanged?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value ? '已启用隐私模式' : '已禁用隐私模式',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('操作失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 激活隐私库
  Future<void> _activateLibrary(
    BuildContext context,
    WidgetRef ref,
    PrivacyNotifier privacyNotifier,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PrivacyAuthDialog(
        libraryId: library.id,
        libraryName: library.name,
      ),
    );
    
    if (result == true) {
      final success = await privacyNotifier.activatePrivateLibrary(library.id);
      
      if (context.mounted) {
        if (success) {
          onChanged?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('隐私库已激活'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('激活失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  /// 取消激活隐私库
  Future<void> _deactivateLibrary(
    BuildContext context,
    WidgetRef ref,
    PrivacyNotifier privacyNotifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消激活'),
        content: Text('确定要取消激活隐私库 "${library.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await privacyNotifier.deactivatePrivateLibrary(library.id);
      
      if (context.mounted) {
        if (success) {
          onChanged?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('隐私库已取消激活'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('取消激活失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  /// 显示需要设置密码的对话框
  void _showPasswordRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要设置密码'),
        content: const Text(
          '启用隐私模式前，请先在设置中设置隐私密码。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 导航到隐私设置页面
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
}
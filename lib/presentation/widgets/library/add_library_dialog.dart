import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/services/enhanced_file_picker_service.dart';
import '../../../core/services/platform_file_picker_service.dart';
import '../../../data/models/library.dart';
import '../../../data/models/network_config.dart';
import 'network_config_dialog.dart';

class AddLibraryDialog extends StatefulWidget {
  final MangaLibrary? library; // 如果不为null，则为编辑模式
  final Function(MangaLibrary) onAdd;

  const AddLibraryDialog({
    super.key,
    this.library,
    required this.onAdd,
  });

  @override
  State<AddLibraryDialog> createState() => _AddLibraryDialogState();
}

class _AddLibraryDialogState extends State<AddLibraryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();

  LibraryType _selectedType = LibraryType.local;
  bool _isEnabled = true;
  NetworkConfig? _networkConfig;

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，填充现有数据
    if (widget.library != null) {
      _nameController.text = widget.library!.name;
      _pathController.text = widget.library!.path;
      _selectedType = widget.library!.type;
      _isEnabled = widget.library!.isEnabled;
      // 如果是网络类型，优先从settings中读取网络配置
      if (_selectedType == LibraryType.network) {
        if (widget.library!.settings.networkConfig != null) {
          // 从settings中读取完整的网络配置（包含用户名密码）
          _networkConfig = widget.library!.settings.networkConfig;
        } else if (widget.library!.path.isNotEmpty) {
          // 兼容旧版本：从path中解析网络配置
          _networkConfig = NetworkConfig.fromConnectionString(widget.library!.path);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.library != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑漫画库' : '添加漫画库'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名称输入
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '漫画库名称',
                  hintText: '请输入漫画库名称',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入漫画库名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 类型选择
              const Text(
                '漫画库类型',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<LibraryType>(
                segments: const [
                  ButtonSegment(
                    value: LibraryType.local,
                    label: Text('本地'),
                    icon: Icon(Icons.folder),
                  ),
                  ButtonSegment(
                    value: LibraryType.network,
                    label: Text('网络'),
                    icon: Icon(Icons.cloud),
                  ),
                  ButtonSegment(
                    value: LibraryType.cloud,
                    label: Text('云端'),
                    icon: Icon(Icons.cloud_queue),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<LibraryType> selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 路径输入
              if (_selectedType == LibraryType.network)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _networkConfig != null
                                      ? '${_networkConfig!.protocol.displayName}: ${_networkConfig!.connectionUrl}'
                                      : '未配置网络连接',
                                  style: TextStyle(
                                    color: _networkConfig != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _configureNetwork,
                                icon: const Icon(Icons.settings),
                                label: Text(
                                    _networkConfig != null ? '修改配置' : '配置网络'),
                              ),
                            ],
                          ),
                          if (_networkConfig != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '协议: ${_networkConfig!.protocol.displayName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '主机: ${_networkConfig!.host}:${_networkConfig!.port ?? _networkConfig!.protocol.defaultPort}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_networkConfig == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '请配置网络连接参数',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                )
              else
                TextFormField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: _getPathLabel(),
                    hintText: _getPathHint(),
                    prefixIcon: Icon(_getPathIcon()),
                    suffixIcon: _selectedType == LibraryType.local
                        ? IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: _selectFolder,
                            tooltip: '选择文件夹',
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入${_getPathLabel()}';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // 启用开关
              SwitchListTile(
                title: const Text('启用漫画库'),
                subtitle: const Text('禁用后将不会显示此库中的漫画'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveLibrary,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  String _getPathLabel() {
    switch (_selectedType) {
      case LibraryType.local:
        return '本地路径';
      case LibraryType.network:
        return '网络地址';
      case LibraryType.cloud:
        return '云端地址';
    }
  }

  String _getPathHint() {
    switch (_selectedType) {
      case LibraryType.local:
        return '例如: C:\\漫画\\我的收藏';
      case LibraryType.network:
        return '例如: smb://192.168.1.100/manga';
      case LibraryType.cloud:
        return '例如: https://cloud.example.com/manga';
    }
  }

  IconData _getPathIcon() {
    switch (_selectedType) {
      case LibraryType.local:
        return Icons.folder;
      case LibraryType.network:
        return Icons.wifi;
      case LibraryType.cloud:
        return Icons.cloud;
    }
  }

  Future<void> _selectFolder() async {
    try {
      // 创建平台特定的文件选择器服务
      final platformService = PlatformFilePickerService.create();
      
      // 检查现有路径的权限状态
      final currentPath = _pathController.text.trim();
      if (currentPath.isNotEmpty) {
        final hasPermission = await platformService.checkPathPermission(currentPath);
        if (hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('当前路径权限有效'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      }
      
      // 使用平台特定的文件夹选择
      final result = await platformService.pickDirectoryWithPermission(
        context: context,
        dialogTitle: '选择漫画库文件夹',
        initialDirectory: currentPath.isNotEmpty ? currentPath : null,
      );

      if (result != null) {
        setState(() {
          _pathController.text = result;
        });

        if (mounted) {
          // 显示平台特定的成功消息
          final platform = Theme.of(context).platform;
          String message = '文件夹选择成功，权限已保存';
          
          switch (platform) {
            case TargetPlatform.android:
              message = '文件夹选择成功，Android权限已持久化保存';
              break;
            case TargetPlatform.iOS:
              message = '文件夹选择成功，iOS安全书签已保存';
              break;
            case TargetPlatform.macOS:
              message = '文件夹选择成功，macOS权限已保存';
              break;
            case TargetPlatform.windows:
              message = '文件夹选择成功，Windows权限已保存';
              break;
            case TargetPlatform.linux:
              message = '文件夹选择成功，Linux权限已保存';
              break;
            default:
              break;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: '查看权限',
                onPressed: () => _showPermissionInfo(platformService),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      log('选择文件夹失败: $e, $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件夹失败: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              onPressed: _selectFolder,
            ),
          ),
        );
      }
    }
  }
  
  /// 显示权限信息对话框
  Future<void> _showPermissionInfo(PlatformFilePickerService service) async {
    try {
      final grantedPaths = await service.getGrantedPaths();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('已授权的文件夹'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: grantedPaths.isEmpty
                ? const Center(
                    child: Text('暂无已授权的文件夹'),
                  )
                : ListView.builder(
                    itemCount: grantedPaths.length,
                    itemBuilder: (context, index) {
                      final path = grantedPaths[index];
                      return ListTile(
                        leading: const Icon(Icons.folder_special),
                        title: Text(path.split('/').last),
                        subtitle: Text(path),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showPathDetails(path, service),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            if (grantedPaths.isNotEmpty)
              TextButton(
                onPressed: () => _clearAllPermissions(service),
                child: const Text('清除所有权限'),
              ),
          ],
        ),
      );
    } catch (e) {
      log('显示权限信息失败: $e');
    }
  }
  
  /// 显示路径详细信息
  Future<void> _showPathDetails(String path, PlatformFilePickerService service) async {
    try {
      final hasPermission = await service.checkPathPermission(path);
      final canAccess = await service.verifyDirectoryAccess(path);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('路径详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('路径: $path'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('权限状态: '),
                  Icon(
                    hasPermission ? Icons.check_circle : Icons.cancel,
                    color: hasPermission ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  Text(
                    hasPermission ? '已授权' : '未授权',
                    style: TextStyle(
                      color: hasPermission ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('访问状态: '),
                  Icon(
                    canAccess ? Icons.check_circle : Icons.cancel,
                    color: canAccess ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  Text(
                    canAccess ? '可访问' : '无法访问',
                    style: TextStyle(
                      color: canAccess ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      log('显示路径详情失败: $e');
    }
  }
  
  /// 清除所有权限
  Future<void> _clearAllPermissions(PlatformFilePickerService service) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认清除'),
          content: const Text('确定要清除所有已保存的文件夹权限吗？\n\n此操作不可撤销，清除后需要重新授权。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('清除'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await service.clearAllPermissions();
        
        if (mounted) {
          Navigator.of(context).pop(); // 关闭权限信息对话框
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('所有权限已清除'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      log('清除权限失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清除权限失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveLibrary() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String finalPath = _pathController.text.trim();

    // 验证网络配置
    if (_selectedType == LibraryType.network) {
      if (_networkConfig == null || !_networkConfig!.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先配置网络连接参数')),
        );
        return;
      }
      finalPath = _networkConfig!.connectionUrl;
    }

    // 准备设置信息，包含网络配置
    final settings =
        _selectedType == LibraryType.network && _networkConfig != null
            ? (widget.library?.settings ?? const LibrarySettings()).copyWith(
                networkConfig: _networkConfig,
              )
            : widget.library?.settings ?? const LibrarySettings();

    final library = MangaLibrary(
      id: widget.library?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      path: finalPath,
      type: _selectedType,
      isEnabled: _isEnabled,
      createdAt: widget.library?.createdAt ?? DateTime.now(),
      lastScanAt: widget.library?.lastScanAt,
      mangaCount: widget.library?.mangaCount ?? 0,
      settings: settings,
    );

    widget.onAdd(library);
    Navigator.of(context).pop();

    // 显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.library != null ? '漫画库已更新' : '漫画库已添加'),
      ),
    );
  }

  void _configureNetwork() {
    showDialog(
      context: context,
      builder: (context) => NetworkConfigDialog(
        initialConfig: _networkConfig,
        onSave: (config) {
          setState(() {
            _networkConfig = config;
          });
        },
      ),
    );
  }
}

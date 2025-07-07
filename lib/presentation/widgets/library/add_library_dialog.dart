import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/services/enhanced_file_picker_service.dart';
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
      final result =
          await EnhancedFilePickerService.pickDirectoryWithPermission(
        context: context,
        dialogTitle: '选择漫画库文件夹',
        initialDirectory:
            _pathController.text.isNotEmpty ? _pathController.text : null,
      );

      if (result != null) {
        setState(() {
          _pathController.text = result;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件夹选择成功，权限已保存'),
              backgroundColor: Colors.green,
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

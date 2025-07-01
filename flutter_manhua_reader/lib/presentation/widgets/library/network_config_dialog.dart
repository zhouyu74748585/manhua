import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/network_config.dart';

class NetworkConfigDialog extends StatefulWidget {
  final NetworkConfig? initialConfig;
  final Function(NetworkConfig) onSave;

  const NetworkConfigDialog({
    super.key,
    this.initialConfig,
    required this.onSave,
  });

  @override
  State<NetworkConfigDialog> createState() => _NetworkConfigDialogState();
}

class _NetworkConfigDialogState extends State<NetworkConfigDialog> {
  final _formKey = GlobalKey<FormState>();

  late NetworkProtocol _selectedProtocol;
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shareNameController = TextEditingController();
  final _exportPathController = TextEditingController();
  final _remotePathController = TextEditingController();

  bool _useSSL = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialConfig != null) {
      final config = widget.initialConfig!;
      _selectedProtocol = config.protocol;
      _hostController.text = config.host;
      _portController.text =
          config.port?.toString() ?? config.protocol.defaultPort;
      _usernameController.text = config.username ?? '';
      _passwordController.text = config.password ?? '';
      _shareNameController.text = config.shareName ?? '';
      _exportPathController.text = config.exportPath ?? '';
      _remotePathController.text = config.remotePath ?? '';
      _useSSL = config.useSSL;
    } else {
      _selectedProtocol = NetworkProtocol.smb;
      _portController.text = _selectedProtocol.defaultPort;
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _shareNameController.dispose();
    _exportPathController.dispose();
    _remotePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('网络配置'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 协议选择
                const Text(
                  '网络协议',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<NetworkProtocol>(
                  value: _selectedProtocol,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: NetworkProtocol.values.map((protocol) {
                    return DropdownMenuItem(
                      value: protocol,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(protocol.displayName),
                          Text(
                            protocol.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (protocol) {
                    if (protocol != null) {
                      setState(() {
                        _selectedProtocol = protocol;
                        _portController.text = protocol.defaultPort;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 主机地址
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: '主机地址',
                    hintText: '例如: 192.168.1.100 或 server.example.com',
                    prefixIcon: Icon(Icons.dns),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入主机地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 端口号
                if (_selectedProtocol.requiredFields.contains('port'))
                  Column(
                    children: [
                      TextFormField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: '端口号',
                          hintText: '默认: ${_selectedProtocol.defaultPort}',
                          prefixIcon: const Icon(Icons.settings_ethernet),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入端口号';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port < 1 || port > 65535) {
                            return '请输入有效的端口号 (1-65535)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // 用户名
                if (_selectedProtocol.requiredFields.contains('username'))
                  Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // 密码
                if (_selectedProtocol.requiredFields.contains('password'))
                  Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showPassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入密码';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // SMB 共享名
                if (_selectedProtocol == NetworkProtocol.smb)
                  Column(
                    children: [
                      TextFormField(
                        controller: _shareNameController,
                        decoration: const InputDecoration(
                          labelText: '共享名',
                          hintText: '例如: manga',
                          prefixIcon: Icon(Icons.folder_shared),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入共享名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // NFS 导出路径
                if (_selectedProtocol == NetworkProtocol.nfs)
                  Column(
                    children: [
                      TextFormField(
                        controller: _exportPathController,
                        decoration: const InputDecoration(
                          labelText: '导出路径',
                          hintText: '例如: /export/manga',
                          prefixIcon: Icon(Icons.folder_open),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入导出路径';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // 远程路径
                TextFormField(
                  controller: _remotePathController,
                  decoration: const InputDecoration(
                    labelText: '远程路径 (可选)',
                    hintText: '例如: /manga 或 manga/collection',
                    prefixIcon: Icon(Icons.folder),
                  ),
                ),
                const SizedBox(height: 16),

                // WebDAV SSL 选项
                if (_selectedProtocol == NetworkProtocol.webdav)
                  Column(
                    children: [
                      SwitchListTile(
                        title: const Text('使用 HTTPS'),
                        subtitle: const Text('启用 SSL/TLS 加密连接'),
                        value: _useSSL,
                        onChanged: (value) {
                          setState(() {
                            _useSSL = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                // 连接预览
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '连接预览:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildConnectionPreview(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveConfig,
          child: const Text('保存'),
        ),
      ],
    );
  }

  String _buildConnectionPreview() {
    final host = _hostController.text.trim().isEmpty
        ? '<主机地址>'
        : _hostController.text.trim();
    final port = _portController.text.trim().isEmpty
        ? _selectedProtocol.defaultPort
        : _portController.text.trim();
    final username = _usernameController.text.trim().isEmpty
        ? '<用户名>'
        : _usernameController.text.trim();
    final shareName = _shareNameController.text.trim().isEmpty
        ? '<共享名>'
        : _shareNameController.text.trim();
    final exportPath = _exportPathController.text.trim().isEmpty
        ? '<导出路径>'
        : _exportPathController.text.trim();
    final remotePath = _remotePathController.text.trim();

    switch (_selectedProtocol) {
      case NetworkProtocol.smb:
        return 'smb://$username@$host:$port/$shareName${remotePath.isNotEmpty ? '/$remotePath' : ''}';
      case NetworkProtocol.ftp:
        return 'ftp://$username@$host:$port${remotePath.isNotEmpty ? '/$remotePath' : ''}';
      case NetworkProtocol.sftp:
        return 'sftp://$username@$host:$port${remotePath.isNotEmpty ? '/$remotePath' : ''}';
      case NetworkProtocol.webdav:
        final scheme = _useSSL ? 'https' : 'http';
        return '$scheme://$username@$host:$port${remotePath.isNotEmpty ? '/$remotePath' : ''}';
      case NetworkProtocol.nfs:
        return 'nfs://$host:$port$exportPath${remotePath.isNotEmpty ? '/$remotePath' : ''}';
    }
  }

  void _saveConfig() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = NetworkConfig(
      protocol: _selectedProtocol,
      host: _hostController.text.trim(),
      port: _portController.text.trim().isNotEmpty
          ? int.tryParse(_portController.text.trim())
          : null,
      username: _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : null,
      password: _passwordController.text.trim().isNotEmpty
          ? _passwordController.text.trim()
          : null,
      shareName: _shareNameController.text.trim().isNotEmpty
          ? _shareNameController.text.trim()
          : null,
      exportPath: _exportPathController.text.trim().isNotEmpty
          ? _exportPathController.text.trim()
          : null,
      remotePath: _remotePathController.text.trim().isNotEmpty
          ? _remotePathController.text.trim()
          : null,
      useSSL: _useSSL,
    );

    if (!config.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置信息不完整，请检查必填项')),
      );
      return;
    }

    widget.onSave(config);
    Navigator.of(context).pop();
  }
}

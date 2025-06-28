import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/library.dart';
import '../../providers/library_provider.dart';

class AddLibraryDialog extends ConsumerStatefulWidget {
  final MangaLibrary? library; // 如果不为null，则为编辑模式
  
  const AddLibraryDialog({super.key, this.library});
  
  @override
  ConsumerState<AddLibraryDialog> createState() => _AddLibraryDialogState();
}

class _AddLibraryDialogState extends ConsumerState<AddLibraryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  
  LibraryType _selectedType = LibraryType.local;
  bool _isEnabled = true;
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，填充现有数据
    if (widget.library != null) {
      _nameController.text = widget.library!.name;
      _pathController.text = widget.library!.path;
      _selectedType = widget.library!.type;
      _isEnabled = widget.library!.isEnabled;
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
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '库名称',
                  hintText: '请输入漫画库名称',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入库名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: '路径',
                        hintText: '请选择或输入路径',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入路径';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedType == LibraryType.local)
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _selectFolder,
                      tooltip: '选择文件夹',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LibraryType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: '库类型',
                ),
                items: LibraryType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.displayName),
                        Text(
                          type.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('启用此库'),
                ],
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _saveLibrary();
            }
          },
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
  
  Future<void> _selectFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        setState(() {
          _pathController.text = result;
        });
      }
    } catch (e) {
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
  
  Future<void> _saveLibrary() async {
    try {
      final now = DateTime.now();
      final library = MangaLibrary(
        id: widget.library?.id ?? now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        path: _pathController.text.trim(),
        type: _selectedType,
        isEnabled: _isEnabled,
        createdAt: widget.library?.createdAt ?? now,
        lastScanAt: widget.library?.lastScanAt,
        mangaCount: widget.library?.mangaCount ?? 0,
        settings: widget.library?.settings ?? {},
      );
      
      if (widget.library != null) {
        // 编辑模式
        await ref.read(libraryNotifierProvider.notifier).updateLibrary(library);
      } else {
        // 添加模式
        await ref.read(libraryNotifierProvider.notifier).addLibrary(library);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
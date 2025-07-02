import 'package:flutter/material.dart';
import '../../../data/models/library.dart';

class LibrarySettingsDialog extends StatefulWidget {
  final MangaLibrary library;
  final Function(LibrarySettings) onSave;

  const LibrarySettingsDialog({
    super.key,
    required this.library,
    required this.onSave,
  });

  @override
  State<LibrarySettingsDialog> createState() => _LibrarySettingsDialogState();
}

class _LibrarySettingsDialogState extends State<LibrarySettingsDialog> {
  late LibrarySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.library.settings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.library.name} - 设置'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面展示模式设置
              const Text(
                '封面展示模式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '选择漫画封面的展示方式：',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              
              // 封面展示模式选项
              ...CoverDisplayMode.values.map((mode) => RadioListTile<CoverDisplayMode>(
                title: Text(mode.displayName),
                subtitle: Text(mode.description),
                value: mode,
                groupValue: _settings.coverDisplayMode,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings = _settings.copyWith(coverDisplayMode: value);
                    });
                  }
                },
              )),
              
              // 左半/右半模式的额外设置
              if (_settings.coverDisplayMode == CoverDisplayMode.leftHalf || 
                  _settings.coverDisplayMode == CoverDisplayMode.rightHalf) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_settings.coverDisplayMode.displayName}模式设置',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 缩放比例设置
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('缩放比例'),
                        subtitle: Text('当前值: ${_settings.coverScale.toStringAsFixed(1)}'),
                        trailing: SizedBox(
                          width: 120,
                          child: Slider(
                            value: _settings.coverScale,
                            min: 1.0,
                            max: 5.0,
                            divisions: 40,
                            label: _settings.coverScale.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(coverScale: value);
                              });
                            },
                          ),
                        ),
                      ),
                      
                      // 偏移量设置
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('偏移量'),
                        subtitle: Text('当前值: ${_settings.coverOffsetX.toStringAsFixed(2)}'),
                        trailing: SizedBox(
                          width: 120,
                          child: Slider(
                            value: _settings.coverOffsetX,
                            min: -1.0,
                            max: 1.0,
                            divisions: 40,
                            label: _settings.coverOffsetX.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(coverOffsetX: value);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // 其他设置
              SwitchListTile(
                title: const Text('自动扫描'),
                subtitle: const Text('定期自动扫描新漫画'),
                value: _settings.autoScan,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(autoScan: value);
                  });
                },
              ),
              
              SwitchListTile(
                title: const Text('包含子文件夹'),
                subtitle: const Text('扫描时包含子文件夹中的漫画'),
                value: _settings.includeSubfolders,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(includeSubfolders: value);
                  });
                },
              ),
              
              SwitchListTile(
                title: const Text('生成缩略图'),
                subtitle: const Text('为漫画页面生成缩略图以提高浏览速度'),
                value: _settings.generateThumbnails,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(generateThumbnails: value);
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 扫描间隔设置
              ListTile(
                title: const Text('扫描间隔'),
                subtitle: Text('${_settings.scanInterval.inHours} 小时'),
                trailing: SizedBox(
                  width: 100,
                  child: Slider(
                    value: _settings.scanInterval.inHours.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '${_settings.scanInterval.inHours} 小时',
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(scanInterval: Duration(hours: value.round()));
                      });
                    },
                  ),
                ),
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
            widget.onSave(_settings);
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
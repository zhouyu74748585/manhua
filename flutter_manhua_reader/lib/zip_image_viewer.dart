import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ZipImageViewer extends StatefulWidget {
  const ZipImageViewer({super.key});

  @override
  State<ZipImageViewer> createState() => _ZipImageViewerState();
}

class _ZipImageViewerState extends State<ZipImageViewer> {
  Uint8List? _currentImage;
  String? _currentImageName;
  bool _isLoading = false;
  int _totalImageCount = 0;
  int _currentIndex = 0;

  List<ArchiveFile> _imageFiles = [];
  final Map<int, Uint8List> _imageCache = {};
  static const int _preloadDistance = 10;

  // 支持的图片格式
  final Set<String> _supportedImageExtensions = {
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'
  };

  @override
  void dispose() {
    _imageCache.clear();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _currentImage = null;
      _currentImageName = null;
      _totalImageCount = 0;
      _currentIndex = 0;
      _imageFiles = [];
      _imageCache.clear();
    });
  }

  Future<void> _pickAndLoadZipFile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    _resetState();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: '选择ZIP压缩包',
      );

      if (result != null && result.files.single.path != null) {
        await _loadImagesFromZip(result.files.single.path!);
      }
    } catch (e) {
      _showErrorDialog('加载文件时出错: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadImagesFromZip(String zipPath) async {
    try {
      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeStream(inputStream);

      final imageFiles = archive.files.where((file) {
        if (!file.isFile || file.name.startsWith('__MACOSX')) return false;
        final extension = path.extension(file.name).toLowerCase();
        return _supportedImageExtensions.contains(extension);
      }).toList();

      if (imageFiles.isEmpty) {
        _showErrorDialog('ZIP文件中未找到有效图片');
        return;
      }

      setState(() {
        _imageFiles = imageFiles;
        _totalImageCount = imageFiles.length;
      });

      await _showImageAtIndex(0);
    } catch (e) {
      print('解析ZIP文件时出错: $e');
      _showErrorDialog('解析ZIP文件时出错: $e');
    }
  }

  Future<void> _showImageAtIndex(int index) async {
    if (index < 0 || index >= _totalImageCount) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? imageBytes;
      if (_imageCache.containsKey(index)) {
        imageBytes = _imageCache[index];
      } else {
        final file = _imageFiles[index];
        final bytes = file.content as List<int>;
        imageBytes = Uint8List.fromList(bytes);
        _imageCache[index] = imageBytes;
      }

      if (mounted) {
        setState(() {
          _currentImage = imageBytes;
          _currentImageName = _imageFiles[index].name;
          _currentIndex = index;
        });
      }

      // 预加载
      _preloadImages(index);
    } catch (e) {
      _showErrorDialog('加载图片时出错: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _preloadImages(int currentIndex) async {
    // 在后台预加载接下来的图片
    for (int i = 1; i <= _preloadDistance; i++) {
      final preloadIndex = currentIndex + i;
      if (preloadIndex >= _totalImageCount) break; // 超出范围
      if (!_imageCache.containsKey(preloadIndex)) {
        final file = _imageFiles[preloadIndex];
        final bytes = file.content as List<int>;
        _imageCache[preloadIndex] = Uint8List.fromList(bytes);
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZIP图片查看器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_totalImageCount > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/$_totalImageCount',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickAndLoadZipFile,
        tooltip: '选择ZIP文件',
        child: _isLoading && _currentImage == null
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.folder_zip),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currentImage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载ZIP文件...'),
          ],
        ),
      );
    }

    if (_currentImage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_zip,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '点击右下角按钮选择ZIP文件',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '支持格式: JPG, PNG, GIF, BMP, WebP',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_currentImageName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              _currentImageName!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: _isLoading && _currentImage != null
                    ? const CircularProgressIndicator()
                    : Image.memory(
                        _currentImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 64, color: Colors.red),
                                SizedBox(height: 16),
                                Text('图片加载失败'),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
        // 控制按钮
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _currentIndex > 0 ? () => _showImageAtIndex(_currentIndex - 1) : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('上一张'),
              ),
              ElevatedButton.icon(
                onPressed: _currentIndex < _totalImageCount - 1 ? () => _showImageAtIndex(_currentIndex + 1) : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一张'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
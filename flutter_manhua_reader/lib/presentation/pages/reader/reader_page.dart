import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

import '../../../data/models/reading_progress.dart';
import '../../providers/manga_provider.dart';

enum ReadingMode {
  singlePage,
  doublePage,
  continuousScroll,
}

enum ReadingDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
}

class ReaderPage extends ConsumerStatefulWidget {
  final String mangaId;
  final int initialPage;
  
  const ReaderPage({
    super.key,
    required this.mangaId,
    this.initialPage = 1,
  });
  
  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _showControls = true;
  late PageController _pageController;
  int _currentPageIndex = 0;
  ReadingMode _readingMode = ReadingMode.singlePage;
  ReadingDirection _readingDirection = ReadingDirection.leftToRight;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage - 1; // 转换为0基索引
    _pageController = PageController(initialPage: _currentPageIndex);
    _enterFullscreen();
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _exitFullscreen();
    _pageController.dispose();
    super.dispose();
  }
  

  
  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() {
    });
  }
  
  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
    });
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _saveReadingProgress();
  }
  
  void _saveReadingProgress() async {
    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
    mangaAsync.when(
      data: (manga) async {
        if (manga != null) {
          final progress = ReadingProgress(
            id: '${widget.mangaId}_progress',
            mangaId: widget.mangaId,
            currentPage: _currentPageIndex + 1, // 转换为1基索引
            totalPages: manga.totalPages,
            progressPercentage: (_currentPageIndex + 1) / manga.totalPages,
            lastReadAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await ref.read(mangaActionsProvider.notifier)
              .updateReadingProgress(widget.mangaId, progress);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }
  
  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _goToNextPage() {
    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
    mangaAsync.whenData((manga) {
      if (manga != null && _currentPageIndex < manga.totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  Widget _buildPageWidget(dynamic manga, int pageNumber) {
    // 根据漫画信息和页码构建页面路径
    final imagePath = '${manga.path}/page_$pageNumber.jpg';
    
    return _buildImageWidget(imagePath);
  }
  
  Widget _buildImageWidget(String imagePath) {
    return PhotoView(
      imageProvider: imagePath.startsWith('http')
          ? CachedNetworkImageProvider(imagePath) as ImageProvider
          : FileImage(File(imagePath)),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      initialScale: PhotoViewComputedScale.contained,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.error, color: Colors.white, size: 48),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    final mangaAsync = ref.watch(mangaDetailProvider(widget.mangaId));
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls ? AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        title: mangaAsync.when(
          data: (manga) => Text(manga?.title ?? '漫画阅读'),
          loading: () => const Text('漫画阅读'),
          error: (_, __) => const Text('漫画阅读'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showReaderSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: 添加书签
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('书签功能待实现')),
              );
            },
          ),
        ],
      ) : null,
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null || manga.totalPages == 0) {
            return const Center(
              child: Text(
                '该漫画暂无页面',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          
          return GestureDetector(
            onTap: _toggleControls,
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: manga.totalPages,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: _buildPageWidget(manga, index + 1),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  initialScale: PhotoViewComputedScale.contained,
                );
              },
              onPageChanged: _onPageChanged,
              scrollDirection: _readingDirection == ReadingDirection.topToBottom 
                  ? Axis.vertical 
                  : Axis.horizontal,
              reverse: _readingDirection == ReadingDirection.rightToLeft,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                '加载失败: $error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(mangaDetailProvider(widget.mangaId));
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _showControls ? mangaAsync.when(
        data: (manga) => manga != null && manga.totalPages > 0 ? Container(
          color: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_currentPageIndex + 1} / ${manga.totalPages}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Slider(
                      value: manga.totalPages > 1 ? _currentPageIndex / (manga.totalPages - 1) : 0,
                      onChanged: (value) {
                        final pageIndex = (value * (manga.totalPages - 1)).round();
                        _goToPage(pageIndex);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: _currentPageIndex < manga.totalPages - 1 ? _goToNextPage : null,
              ),
            ],
          ),
        ) : null,
        loading: () => null,
        error: (_, __) => null,
      ) : null,
    );
  }
  
  void _showReaderSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '阅读设置',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 阅读模式
            const Text('阅读模式', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReadingMode.values.map((mode) {
                return ChoiceChip(
                  label: Text(_getReadingModeLabel(mode)),
                  selected: _readingMode == mode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _readingMode = mode;
                      });
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 阅读方向
            const Text('阅读方向', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReadingDirection.values.map((direction) {
                return ChoiceChip(
                  label: Text(_getReadingDirectionLabel(direction)),
                  selected: _readingDirection == direction,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _readingDirection = direction;
                      });
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  String _getReadingModeLabel(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.singlePage:
        return '单页';
      case ReadingMode.doublePage:
        return '双页';
      case ReadingMode.continuousScroll:
        return '连续滚动';
    }
  }
  
  String _getReadingDirectionLabel(ReadingDirection direction) {
    switch (direction) {
      case ReadingDirection.leftToRight:
        return '从左到右';
      case ReadingDirection.rightToLeft:
        return '从右到左';
      case ReadingDirection.topToBottom:
        return '从上到下';
    }
  }
}
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../data/models/reading_progress.dart';
import '../../providers/manga_provider.dart';
import '../../widgets/double_page_thumbnail_list.dart';
import 'reader_page.dart';

class DoublePageReader extends ConsumerStatefulWidget {
  final String mangaId;
  final int initialPage;

  const DoublePageReader({
    super.key,
    required this.mangaId,
    this.initialPage = 1,
  });

  @override
  ConsumerState<DoublePageReader> createState() => _DoublePageReaderState();
}

class _DoublePageReaderState extends ConsumerState<DoublePageReader> {
  bool _showControls = false;
  late PageController _pageController;
  int _currentPageIndex = 0;
  ReadingDirection _readingDirection = ReadingDirection.leftToRight;
  bool _isLoading = true;
  
  // 双页模式专用状态
  int _currentGroupIndex = 0; // 当前双页组索引
  List<List<int>> _doublePageGroups = []; // 双页分组

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
    
    // 双页模式：计算初始组索引
    _currentGroupIndex = (_currentPageIndex / 2).floor();
    _pageController = PageController(initialPage: _currentGroupIndex);
    
    // 设置全屏模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _isLoading = false;
  }
  
  // 初始化双页分组
  void _initializeDoublePageGroups(int totalPages) {
    _doublePageGroups.clear();
    
    for (int i = 0; i < totalPages; i += 2) {
      if (i + 1 < totalPages) {
        _doublePageGroups.add([i, i + 1]);
      } else {
        _doublePageGroups.add([i]); // 最后一页单独成组
      }
    }
  }

  void _onGroupTap(int groupIndex) {
    if (groupIndex >= 0 && groupIndex < _doublePageGroups.length) {
      _currentGroupIndex = groupIndex;
      _currentPageIndex = _getPageIndexFromGroupIndex(groupIndex);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          groupIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  // 从双页组索引获取第一页索引
  int _getPageIndexFromGroupIndex(int groupIndex) {
    if (groupIndex < _doublePageGroups.length) {
      return _doublePageGroups[groupIndex][0];
    }
    return 0;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (mounted) {
      setState(() {});
    }
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleControls() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
      });
    }
  }

  void _toggleFullscreen() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
      });
      
      if (_showControls) {
        _exitFullscreen();
      } else {
        _enterFullscreen();
      }
    }
  }

  void _onPageChanged(int groupIndex) {
    if (mounted) {
      setState(() {
        _currentGroupIndex = groupIndex;
        _currentPageIndex = _getPageIndexFromGroupIndex(groupIndex);
      });
      _saveReadingProgress();
    }
  }

  void _saveReadingProgress() async {
    if (!mounted) return;
    
    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
    mangaAsync.when(
      data: (manga) async {
        if (!mounted || manga == null) return;
        
        final progress = ReadingProgress(
          id: '${widget.mangaId}_progress',
          mangaId: widget.mangaId,
          libraryId: manga.libraryId,
          currentPage: _currentPageIndex + 1,
          totalPages: manga.totalPages,
          progressPercentage: ((_currentPageIndex + 1) / manga.totalPages).clamp(0.0, 1.0),
          lastReadAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (mounted) {
          await ref
              .read(mangaActionsProvider.notifier)
              .updateReadingProgress(widget.mangaId, progress);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _goToPreviousPage() {
    if (!_pageController.hasClients) return;
    
    if (_currentGroupIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (!_pageController.hasClients) return;
    
    if (_currentGroupIndex < _doublePageGroups.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTapNavigation(TapDownDetails details, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tapPosition = details.globalPosition;
    
    if (_readingDirection == ReadingDirection.topToBottom) {
      if (tapPosition.dy < screenSize.height / 2) {
        _goToPreviousPage();
      } else {
        _goToNextPage();
      }
    } else {
      if (_readingDirection == ReadingDirection.leftToRight) {
        if (tapPosition.dx < screenSize.width / 2) {
          _goToPreviousPage();
        } else {
          _goToNextPage();
        }
      } else {
        if (tapPosition.dx < screenSize.width / 2) {
          _goToNextPage();
        } else {
          _goToPreviousPage();
        }
      }
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    if (_readingDirection == ReadingDirection.topToBottom) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            height: 80,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                onPressed: _currentGroupIndex > 0 ? _goToPreviousPage : null,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 80,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: _currentGroupIndex < _doublePageGroups.length - 1 ? _goToNextPage : null,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            height: double.infinity,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  _readingDirection == ReadingDirection.leftToRight
                      ? Icons.keyboard_arrow_left
                      : Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
                onPressed: _currentGroupIndex > 0 ? _goToPreviousPage : null,
              ),
            ),
          ),
          Container(
            width: 80,
            height: double.infinity,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  _readingDirection == ReadingDirection.leftToRight
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                  color: Colors.white,
                ),
                onPressed: _currentGroupIndex < _doublePageGroups.length - 1 ? _goToNextPage : null,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDoublePageView(List<MangaPage> pages) {
    final doublePageCount = (pages.length / 2).ceil();
    
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: doublePageCount,
      builder: (context, index) {
        final leftPageIndex = index * 2;
        final rightPageIndex = leftPageIndex + 1;
        
        if (rightPageIndex < pages.length) {
          return PhotoViewGalleryPageOptions.customChild(
            child: _buildDoublePageWidget(pages[leftPageIndex], pages[rightPageIndex]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            initialScale: PhotoViewComputedScale.contained,
          );
        } else {
          return PhotoViewGalleryPageOptions(
            imageProvider: pages[leftPageIndex].localPath.startsWith('http')
                ? CachedNetworkImageProvider(pages[leftPageIndex].localPath) as ImageProvider
                : FileImage(File(pages[leftPageIndex].localPath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            initialScale: PhotoViewComputedScale.contained,
          );
        }
      },
      onPageChanged: _onPageChanged,
      scrollDirection: Axis.horizontal,
      reverse: _readingDirection == ReadingDirection.rightToLeft,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildDoublePageWidget(MangaPage leftPage, MangaPage rightPage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxPageWidth = constraints.maxWidth / 2;
        
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxPageWidth,
                ),
                child: _buildContinuousImageWidget(
                  _readingDirection == ReadingDirection.rightToLeft
                      ? rightPage.localPath
                      : leftPage.localPath,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxPageWidth,
                ),
                child: _buildContinuousImageWidget(
                  _readingDirection == ReadingDirection.rightToLeft
                      ? leftPage.localPath
                      : rightPage.localPath,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContinuousImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error, color: Colors.white, size: 48),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: Colors.white, size: 48),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final mangaAsync = ref.watch(mangaDetailProvider(widget.mangaId));
    final pageAsync = ref.watch(mangaPagesProvider(widget.mangaId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              title: mangaAsync.when(
                data: (manga) => Text(manga?.title ?? '双页阅读'),
                loading: () => const Text('双页阅读'),
                error: (_, __) => const Text('双页阅读'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.library_books),
                  onPressed: () {
                    context.go('/bookshelf');
                  },
                  tooltip: '书架',
                ),
                IconButton(
                  icon: const Icon(Icons.view_agenda),
                  onPressed: () {
                    // 切换到单页模式
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ReaderPage(
                          mangaId: widget.mangaId,
                          initialPage: _currentPageIndex,
                        ),
                      ),
                    );
                  },
                  tooltip: '切换到单页模式',
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showReaderSettings,
                  tooltip: '阅读设置',
                ),
              ],
            )
          : null,
      body: pageAsync.when(
        data: (pages) {
          _initializeDoublePageGroups(pages.length);
          
          return Stack(
            children: [
              GestureDetector(
                onTapDown: (details) => _handleTapNavigation(details, context),
                onTap: _toggleControls,
                child: _buildDoublePageView(pages),
              ),
              if (!_showControls) _buildNavigationButtons(context),
              if (_showControls)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black.withOpacity(0.7),
                    onPressed: _toggleFullscreen,
                    child: const Icon(Icons.fullscreen, color: Colors.white),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                '正在加载漫画页面...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '首次访问压缩包漫画需要解压，请稍候',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
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
      bottomNavigationBar: _showControls
          ? mangaAsync.when(
              data: (manga) => manga != null && manga.totalPages > 0
                  ? Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 双页专用缩略图列表
                          pageAsync.when(
                            data: (pages) {
                              return DoublePageThumbnailList(
                                pages: pages,
                                doublePageGroups: _doublePageGroups,
                                currentGroupIndex: _currentGroupIndex,
                                onGroupTap: _onGroupTap,
                                height: 60,
                                preloadCount: 10,
                                itemWidth: 80,
                                itemSpacing: 4,
                              );
                            },
                            loading: () => const SizedBox(
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, __) => const SizedBox(height: 60),
                          ),
                          // 进度条和按钮
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed: _currentGroupIndex > 0
                                      ? _goToPreviousPage
                                      : null,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'G${_currentGroupIndex + 1} / ${_doublePageGroups.length} (P${_currentPageIndex + 1} / ${manga.totalPages})',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Slider(
                                        value: _doublePageGroups.isNotEmpty 
                                            ? (_currentGroupIndex / (_doublePageGroups.length - 1)).clamp(0.0, 1.0) 
                                            : 0,
                                        onChanged: (value) {
                                          if (_doublePageGroups.isNotEmpty) {
                                            final targetGroupIndex = (value * (_doublePageGroups.length - 1)).round();
                                            _onGroupTap(targetGroupIndex);
                                          }
                                        },
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white.withOpacity(0.3),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  onPressed: _currentGroupIndex < _doublePageGroups.length - 1
                                      ? _goToNextPage
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              loading: () => null,
              error: (_, __) => null,
            )
          : null,
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
              '双页阅读设置',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
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
}
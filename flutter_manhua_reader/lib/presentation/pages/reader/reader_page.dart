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
import '../../widgets/lazy_thumbnail_list.dart';
import '../../widgets/double_page_thumbnail_list.dart';

enum ReadingMode {
  singlePage,
  doublePage,
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
  bool _showControls = false;
  late PageController _pageController;
  int _currentPageIndex = 0;
  ReadingMode _readingMode = ReadingMode.singlePage;
  ReadingDirection _readingDirection = ReadingDirection.leftToRight;
  bool _isLoading = true;
  
  // 双页模式相关状态
  int _currentGroupIndex = 0; // 当前双页组索引
  List<List<int>> _doublePageGroups = []; // 双页分组

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
    
    // 根据阅读模式计算初始页面索引
    int initialPageControllerIndex = _currentPageIndex;
    if (_readingMode == ReadingMode.doublePage) {
      initialPageControllerIndex = (_currentPageIndex / 2).floor();
      _currentGroupIndex = initialPageControllerIndex;
    }
    
    _pageController = PageController(initialPage: initialPageControllerIndex);
    // 直接设置全屏模式，不调用setState
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _isLoading = false; // 直接设置，避免不必要的setState
  }
  
  // 初始化双页分组
  void _initializeDoublePageGroups([int? totalPages]) {
    _doublePageGroups.clear();
    if (totalPages == null) return;
    
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
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          groupIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  // 从单页索引获取双页组索引
  int _getGroupIndexFromPageIndex(int pageIndex) {
    return (pageIndex / 2).floor();
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
    // 在dispose时不调用setState，直接设置系统UI模式
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
    // 检查组件是否已被销毁
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
      
      // 根据控制条状态切换全屏模式
      if (_showControls) {
        _exitFullscreen();
      } else {
        _enterFullscreen();
      }
    }
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        if (_readingMode == ReadingMode.doublePage) {
          // 双页模式：index是组索引，需要转换为页面索引
          _currentGroupIndex = index;
          _currentPageIndex = _getPageIndexFromGroupIndex(index);
        } else {
          // 单页模式：index就是页面索引
          _currentPageIndex = index;
        }
      });
      _saveReadingProgress();
    }
  }

  void _saveReadingProgress() async {
    // 检查组件是否仍然存在
    if (!mounted) return;
    
    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
    mangaAsync.when(
      data: (manga) async {
        // 在异步操作前再次检查
        if (!mounted || manga == null) return;
        
        final progress = ReadingProgress(
          id: '${widget.mangaId}_progress',
          mangaId: widget.mangaId,
          libraryId: manga.libraryId,
          currentPage: _currentPageIndex + 1, // 转换为1基索引
          totalPages: manga.totalPages,
          progressPercentage: ((_currentPageIndex + 1) / manga.totalPages).clamp(0.0, 1.0),
          lastReadAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 在执行更新前最后一次检查
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
    
    if (_readingMode == ReadingMode.doublePage) {
      // 双页模式：检查当前组索引
      if (_currentGroupIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // 单页模式：检查当前页面索引
      if (_currentPageIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _goToNextPage() {
    if (!_pageController.hasClients) return;
    
    if (_readingMode == ReadingMode.doublePage) {
      // 双页模式：检查当前组索引
      if (_currentGroupIndex < _doublePageGroups.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // 单页模式：检查当前页面索引
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
  }

  void _goToPage(int pageIndex) {
    // 检查PageController是否已经attached
    if (!_pageController.hasClients) {
      return;
    }
    
    int targetIndex = pageIndex;
    
    // 双页模式下需要转换页面索引为组索引
    if (_readingMode == ReadingMode.doublePage) {
      targetIndex = _getGroupIndexFromPageIndex(pageIndex);
      _currentGroupIndex = targetIndex;
    }
    
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleTapNavigation(TapDownDetails details, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tapPosition = details.globalPosition;
    
    if (_readingDirection == ReadingDirection.topToBottom) {
      // 垂直阅读：点击上半部分上一页，下半部分下一页
      if (tapPosition.dy < screenSize.height / 2) {
        _goToPreviousPage();
      } else {
        _goToNextPage();
      }
    } else {
      // 水平阅读：点击左右两边换页
      if (_readingDirection == ReadingDirection.leftToRight) {
        if (tapPosition.dx < screenSize.width / 2) {
          _goToPreviousPage();
        } else {
          _goToNextPage();
        }
      } else {
        // 从右到左
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
      // 垂直阅读：上下按钮
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
                onPressed: (_readingMode == ReadingMode.doublePage 
                    ? _currentGroupIndex > 0 
                    : _currentPageIndex > 0) ? _goToPreviousPage : null,
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
                onPressed: () {
                  if (_readingMode == ReadingMode.doublePage) {
                    if (_currentGroupIndex < _doublePageGroups.length - 1) {
                      _goToNextPage();
                    }
                  } else {
                    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
                    mangaAsync.whenData((manga) {
                      if (manga != null && _currentPageIndex < manga.totalPages - 1) {
                        _goToNextPage();
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      );
    } else {
      // 水平阅读：左右按钮
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
                onPressed: (_readingMode == ReadingMode.doublePage 
                    ? _currentGroupIndex > 0 
                    : _currentPageIndex > 0) ? _goToPreviousPage : null,
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
                onPressed: () {
                  if (_readingMode == ReadingMode.doublePage) {
                    if (_currentGroupIndex < _doublePageGroups.length - 1) {
                      _goToNextPage();
                    }
                  } else {
                    final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
                    mangaAsync.whenData((manga) {
                      if (manga != null && _currentPageIndex < manga.totalPages - 1) {
                        _goToNextPage();
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildReaderView(List<MangaPage> pages) {
    switch (_readingMode) {
      case ReadingMode.singlePage:
        return _buildSinglePageView(pages);
      case ReadingMode.doublePage:
        return _buildDoublePageView(pages);
    }
  }

  Widget _buildSinglePageView(List<MangaPage> pages) {
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: pages.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions.customChild(
          child: _buildPageWidget(pages, index),
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
    );
  }

  Widget _buildDoublePageView(List<MangaPage> pages) {
    // 计算双页数量
    final doublePageCount = (pages.length / 2).ceil();
    
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: doublePageCount,
      builder: (context, index) {
        final leftPageIndex = index * 2;
        final rightPageIndex = leftPageIndex + 1;
        
        if (rightPageIndex < pages.length) {
          // 双页
          return PhotoViewGalleryPageOptions.customChild(
            child: _buildDoublePageWidget(pages[leftPageIndex], pages[rightPageIndex]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            initialScale: PhotoViewComputedScale.contained,
          );
        } else {
          // 单页（最后一页）
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
      onPageChanged: (index) {
        // 双页模式下的页面变化处理
        final actualPageIndex = index * 2;
        if (actualPageIndex < pages.length) {
          _onPageChanged(actualPageIndex); // 使用统一的页面变化处理方法
        }
      },
      scrollDirection: Axis.horizontal,
      reverse: _readingDirection == ReadingDirection.rightToLeft,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }



  Widget _buildDoublePageWidget(MangaPage leftPage, MangaPage rightPage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算每页的最大宽度，确保在大屏幕上不会有过多间隙
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

  Widget _buildPageWidget(List<MangaPage> pages, int pageIndex) {
    // 根据漫画信息和页码构建页面路径
    MangaPage page = pages[pageIndex];
    return _buildImageWidget(page.localPath);
  }

  Widget _buildImageWidget(String imagePath) {
    return PhotoView(
      imageProvider: imagePath.startsWith('http')
          ? CachedNetworkImageProvider(imagePath) as ImageProvider
          : FileImage(File(imagePath)),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      initialScale: PhotoViewComputedScale.contained,
      basePosition: Alignment.center,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.error, color: Colors.white, size: 48),
      ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        appBar: null,
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
                data: (manga) => Text(manga?.title ?? '漫画阅读'),
                loading: () => const Text('漫画阅读'),
                error: (_, __) => const Text('漫画阅读'),
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
            )
          : null,
      body: pageAsync.when(
        data: (pages) {
          if (pages.isEmpty) {
            return const Center(
              child: Text(
                '该漫画暂无页面',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                // 根据阅读方向处理鼠标滚动
                if (_readingDirection == ReadingDirection.topToBottom) {
                  // 垂直滚动
                  if (pointerSignal.scrollDelta.dy > 0) {
                    _goToNextPage();
                  } else if (pointerSignal.scrollDelta.dy < 0) {
                    _goToPreviousPage();
                  }
                } else {
                  // 水平滚动
                  if (pointerSignal.scrollDelta.dy > 0) {
                    if (_readingDirection == ReadingDirection.leftToRight) {
                      _goToNextPage();
                    } else {
                      _goToPreviousPage();
                    }
                  } else if (pointerSignal.scrollDelta.dy < 0) {
                    if (_readingDirection == ReadingDirection.leftToRight) {
                      _goToPreviousPage();
                    } else {
                      _goToNextPage();
                    }
                  }
                }
              }
            },
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _toggleControls,
                  onTapDown: (details) => _handleTapNavigation(details, context),
                  onSecondaryTap: () {
              context.go('/bookshelf');
            }, // 右键返回
                  child: _buildReaderView(pages),
                ),
                // 放大的导航按钮
                if (!_showControls) _buildNavigationButtons(context),
                // 全屏模式下的返回按钮
                if (!_showControls)
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                        context.go('/bookshelf');
                      },
                        tooltip: '返回',
                      ),
                    ),
                  ),
                // 统一的全屏/取消全屏按钮（右下方缩略图上方）
                Positioned(
                  bottom: _showControls ? 140 : 20, // 根据控制条显示状态调整位置
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showControls ? Icons.fullscreen : Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullscreen,
                      tooltip: _showControls ? '全屏' : '退出全屏',
                    ),
                  ),
                ),
              ],
            ),
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
                          // 根据阅读模式显示不同的缩略图列表
                          pageAsync.when(
                            data: (pages) {
                              _initializeDoublePageGroups(pages.length);
                              
                              if (_readingMode == ReadingMode.doublePage) {
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
                              } else {
                                return LazyThumbnailList(
                                  pages: pages,
                                  totalPages: manga.totalPages,
                                  currentPage: _currentPageIndex,
                                  onPageTap: (index) => _goToPage(index),
                                  height: 60,
                                  preloadCount: 10,
                                  itemWidth: 40,
                                  itemSpacing: 4,
                                );
                              }
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
                          // 原有的进度条和按钮
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed: (_readingMode == ReadingMode.doublePage 
                                      ? _currentGroupIndex > 0 
                                      : _currentPageIndex > 0)
                                      ? _goToPreviousPage
                                      : null,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _readingMode == ReadingMode.doublePage
                                            ? 'G${_currentGroupIndex + 1} / ${_doublePageGroups.length} (P${_currentPageIndex + 1} / ${manga.totalPages})'
                                            : '${_currentPageIndex + 1} / ${manga.totalPages}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Slider(
                                        value: _readingMode == ReadingMode.doublePage
                                            ? (_doublePageGroups.isNotEmpty ? (_currentGroupIndex / (_doublePageGroups.length - 1)).clamp(0.0, 1.0) : 0)
                                            : (manga.totalPages > 1 ? (_currentPageIndex / (manga.totalPages - 1)).clamp(0.0, 1.0) : 0),
                                        onChanged: (value) {
                                          if (_readingMode == ReadingMode.doublePage) {
                                            if (_doublePageGroups.isNotEmpty) {
                                              final targetGroupIndex = (value * (_doublePageGroups.length - 1)).round();
                                              _onGroupTap(targetGroupIndex);
                                            }
                                          } else {
                                            final pageIndex = (value * (manga.totalPages - 1)).round();
                                            _goToPage(pageIndex);
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
                                  onPressed: (_readingMode == ReadingMode.doublePage 
                                      ? _currentGroupIndex < _doublePageGroups.length - 1
                                      : _currentPageIndex < manga.totalPages - 1)
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
              '阅读设置',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
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
                        final oldMode = _readingMode;
                        _readingMode = mode;
                        
                        // 如果阅读模式发生变化，需要重新初始化页面控制器
                        if (oldMode != mode) {
                          _pageController.dispose();
                          
                          int newInitialPage;
                          if (_readingMode == ReadingMode.doublePage) {
                            // 切换到双页模式：根据当前页码所在组显示对应的组
                            _currentGroupIndex = _getGroupIndexFromPageIndex(_currentPageIndex);
                            newInitialPage = _currentGroupIndex;
                          } else {
                            // 切换到单页模式：以双页分组中的第一张为当前页码
                            _currentPageIndex = _getPageIndexFromGroupIndex(_currentGroupIndex);
                            newInitialPage = _currentPageIndex;
                          }
                          
                          _pageController = PageController(initialPage: newInitialPage);
                        }
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

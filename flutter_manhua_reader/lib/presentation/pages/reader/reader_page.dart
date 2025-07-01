import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
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
    _currentPageIndex = widget.initialPage;
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
    setState(() {});
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {});
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
            libraryId: manga.libraryId,
            currentPage: _currentPageIndex + 1, // 转换为1基索引
            totalPages: manga.totalPages,
            progressPercentage: (_currentPageIndex + 1) / manga.totalPages,
            lastReadAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

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
                onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
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
                  final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
                  mangaAsync.whenData((manga) {
                    if (manga != null && _currentPageIndex < manga.totalPages - 1) {
                      _goToNextPage();
                    }
                  });
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
                onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
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
                  final mangaAsync = ref.read(mangaDetailProvider(widget.mangaId));
                  mangaAsync.whenData((manga) {
                    if (manga != null && _currentPageIndex < manga.totalPages - 1) {
                      _goToNextPage();
                    }
                  });
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
      case ReadingMode.continuousScroll:
        return _buildContinuousScrollView(pages);
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
          setState(() {
            _currentPageIndex = actualPageIndex;
          });
          _saveReadingProgress();
        }
      },
      scrollDirection: Axis.horizontal,
      reverse: _readingDirection == ReadingDirection.rightToLeft,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildContinuousScrollView(List<MangaPage> pages) {
    return SingleChildScrollView(
      scrollDirection: _readingDirection == ReadingDirection.topToBottom
          ? Axis.vertical
          : Axis.horizontal,
      child: _readingDirection == ReadingDirection.topToBottom
          ? Column(
              children: pages.asMap().entries.map((entry) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: _buildContinuousImageWidget(entry.value.localPath),
                );
              }).toList(),
            )
          : Row(
              children: pages.asMap().entries.map((entry) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: _buildContinuousImageWidget(entry.value.localPath),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDoublePageWidget(MangaPage leftPage, MangaPage rightPage) {
    return Row(
      children: [
        Expanded(
          child: _buildContinuousImageWidget(
            _readingDirection == ReadingDirection.rightToLeft
                ? rightPage.localPath
                : leftPage.localPath,
          ),
        ),
        Expanded(
          child: _buildContinuousImageWidget(
            _readingDirection == ReadingDirection.rightToLeft
                ? leftPage.localPath
                : rightPage.localPath,
          ),
        ),
      ],
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

  Widget _buildThumbnailImage(MangaPage page) {
    return page.localPath.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: page.localPath,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildThumbnailPlaceholder(page.pageIndex),
            errorWidget: (context, url, error) => _buildThumbnailPlaceholder(page.pageIndex),
          )
        : Image.file(
            File(page.localPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildThumbnailPlaceholder(page.pageIndex);
            },
          );
  }

  Widget _buildThumbnailPlaceholder(int pageNumber) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          pageNumber.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/bookshelf',
                      (route) => false,
                    );
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
                  onSecondaryTap: () => Navigator.of(context).pop(), // 右键返回
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
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: '返回',
                      ),
                    ),
                  ),
              ],
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
      bottomNavigationBar: _showControls
          ? mangaAsync.when(
              data: (manga) => manga != null && manga.totalPages > 0
                  ? Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 缩略图列表
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: pageAsync.when(
                              data: (pages) => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: pages.length,
                                itemBuilder: (context, index) {
                                  final page = pages[index];
                                  final isCurrentPage = index == _currentPageIndex;
                                  return GestureDetector(
                                    onTap: () => _goToPage(index),
                                    child: Container(
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isCurrentPage
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: _buildThumbnailImage(page),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ),
                          // 原有的进度条和按钮
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed: _currentPageIndex > 0
                                      ? _goToPreviousPage
                                      : null,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_currentPageIndex + 1} / ${manga.totalPages}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Slider(
                                        value: manga.totalPages > 1
                                            ? _currentPageIndex /
                                                (manga.totalPages - 1)
                                            : 0,
                                        onChanged: (value) {
                                          final pageIndex =
                                              (value * (manga.totalPages - 1))
                                                  .round();
                                          _goToPage(pageIndex);
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
                                  onPressed: _currentPageIndex < manga.totalPages - 1
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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../data/models/reading_progress.dart';
import '../../providers/manga_provider.dart';
import '../../widgets/manga/lazy_thumbnail_list.dart';
import 'double_page_reader.dart';

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
  ReadingDirection _readingDirection = ReadingDirection.leftToRight;
  bool _isLoading = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;

    _pageController = PageController(initialPage: _currentPageIndex);
    // 直接设置全屏模式，不调用setState
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _isLoading = false; // 直接设置，避免不必要的setState
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
    if (Platform.isAndroid || Platform.isIOS) {
      if (mounted) {
        setState(() {
          _showControls = !_showControls;
        });
      }
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
        _currentPageIndex = index;
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
          progressPercentage:
              ((_currentPageIndex + 1) / manga.totalPages).clamp(0.0, 1.0),
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

    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (!_pageController.hasClients) return;

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
    if (!_pageController.hasClients) {
      return;
    }

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
                color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: IconButton(
                iconSize: 40,
                icon:
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () {
                  final mangaAsync =
                      ref.read(mangaDetailProvider(widget.mangaId));
                  mangaAsync.whenData((manga) {
                    if (manga != null &&
                        _currentPageIndex < manga.totalPages - 1) {
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
                color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.black.withValues(alpha: 0.3),
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
                  final mangaAsync =
                      ref.read(mangaDetailProvider(widget.mangaId));
                  mangaAsync.whenData((manga) {
                    if (manga != null &&
                        _currentPageIndex < manga.totalPages - 1) {
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
    return _buildSinglePageView(pages);
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
              backgroundColor: Colors.black.withValues(alpha: 0.7),
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
                  icon: const Icon(Icons.view_agenda),
                  onPressed: () {
                    // 切换到双页模式
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DoublePageReader(
                          mangaId: widget.mangaId,
                          initialPage: _currentPageIndex,
                        ),
                      ),
                    );
                  },
                  tooltip: '切换到双页模式',
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
          return KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _goToPreviousPage();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _goToNextPage();
                }
              }
            },
            child: Listener(
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
                    onTapDown: (details) =>
                        _handleTapNavigation(details, context),
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
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
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
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _showControls
                              ? Icons.fullscreen
                              : Icons.fullscreen_exit,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFullscreen,
                        tooltip: _showControls ? '全屏' : '退出全屏',
                      ),
                    ),
                  ),
                ],
              ),
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
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 单页模式缩略图列表
                          pageAsync.when(
                            data: (pages) {
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
                                            ? (_currentPageIndex /
                                                    (manga.totalPages - 1))
                                                .clamp(0.0, 1.0)
                                            : 0,
                                        onChanged: (value) {
                                          final pageIndex =
                                              (value * (manga.totalPages - 1))
                                                  .round();
                                          _goToPage(pageIndex);
                                        },
                                        activeColor: Colors.white,
                                        inactiveColor:
                                            Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  onPressed:
                                      _currentPageIndex < manga.totalPages - 1
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

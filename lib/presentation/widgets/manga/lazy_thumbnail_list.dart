import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:async';

import '../../../data/models/manga_page.dart';

class LazyThumbnailList extends StatefulWidget {
  final List<MangaPage> pages;
  final int totalPages;
  final int currentPage;
  final Function(int) onPageTap;
  final double height;
  final int preloadCount;
  final double itemWidth;
  final double itemSpacing;

  const LazyThumbnailList({
    super.key,
    required this.pages,
    required this.totalPages,
    required this.currentPage,
    required this.onPageTap,
    this.height = 60,
    this.preloadCount = 10,
    this.itemWidth = 40,
    this.itemSpacing = 4,
  });

  @override
  State<LazyThumbnailList> createState() => _LazyThumbnailListState();
}

class _LazyThumbnailListState extends State<LazyThumbnailList> {
  final Set<int> _loadedIndices = {};
  final Set<int> _preloadedIndices = {};
  late ScrollController _scrollController;
  bool _isInitialized = false;

  // 预览图独立状态
  int _previewIndex = 0;
  bool _isScrolling = false;
  Timer? _scrollEndTimer;
  double _previewScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _previewIndex = widget.currentPage;
  }

  @override
  void didUpdateWidget(LazyThumbnailList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当当前页面改变时，滚动到对应位置并同步预览索引
    if (oldWidget.currentPage != widget.currentPage && _isInitialized) {
      _previewIndex = widget.currentPage;
      _scrollToCurrentPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleItems();
  }

  void _updateVisibleItems() {
    if (!mounted || !_scrollController.hasClients) return;

    final viewportWidth = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;
    final itemTotalWidth = widget.itemWidth + widget.itemSpacing;

    // 计算可见范围
    final startIndex =
        (scrollOffset / itemTotalWidth).floor().clamp(0, widget.totalPages - 1);
    final endIndex = ((scrollOffset + viewportWidth) / itemTotalWidth)
        .ceil()
        .clamp(0, widget.totalPages);

    // 加载可见范围内的图片
    for (int i = startIndex; i < endIndex; i++) {
      if (!_loadedIndices.contains(i)) {
        _loadedIndices.add(i);
      }
    }

    // 预加载前后的图片
    final preloadStart =
        (startIndex - widget.preloadCount).clamp(0, widget.totalPages);
    final preloadEnd =
        (endIndex + widget.preloadCount).clamp(0, widget.totalPages);

    for (int i = preloadStart; i < preloadEnd; i++) {
      if (!_preloadedIndices.contains(i)) {
        _preloadedIndices.add(i);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToCurrentPage() {
    if (!_scrollController.hasClients) return;

    final itemTotalWidth = widget.itemWidth + widget.itemSpacing;
    // 计算目标偏移量，确保当前页面在视口中心
    final viewportCenter = _scrollController.position.viewportDimension / 2;
    final targetOffset = (widget.currentPage * itemTotalWidth) -
        viewportCenter +
        (widget.itemWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToPreviewPage() {
    if (!_scrollController.hasClients) return;

    final itemTotalWidth = widget.itemWidth + widget.itemSpacing;
    // 计算目标偏移量，确保预览页面在视口中心
    final viewportCenter = _scrollController.position.viewportDimension / 2;
    final targetOffset = (_previewIndex * itemTotalWidth) -
        viewportCenter +
        (widget.itemWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _handleMouseScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // 计算滚动方向和距离
      final scrollDelta = event.scrollDelta.dx != 0
          ? event.scrollDelta.dx
          : event.scrollDelta.dy;

      // 开始滚动状态
      _isScrolling = true;
      _previewScale = 2.0;

      if (scrollDelta > 0) {
        // 向右滚动，预览下一页
        if (_previewIndex < widget.totalPages - 1) {
          _previewIndex++;
          _scrollToPreviewPage(); // 滚动到预览页面中心
        }
      } else if (scrollDelta < 0) {
        // 向左滚动，预览上一页
        if (_previewIndex > 0) {
          _previewIndex--;
          _scrollToPreviewPage(); // 滚动到预览页面中心
        }
      }

      setState(() {});

      // 取消之前的定时器
      _scrollEndTimer?.cancel();

      // 设置延迟切换定时器
      _scrollEndTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isScrolling = false;
          _previewScale = 1.0;
          // 切换到预览的页面
          widget.onPageTap(_previewIndex);
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始化时滚动到当前页面
    if (!_isInitialized && widget.totalPages > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isInitialized = true;
        _updateVisibleItems();
        _scrollToCurrentPage();
      });
    }

    return Listener(
      onPointerSignal: _handleMouseScroll,
      child: GestureDetector(
        onPanStart: (details) {
          // 开始拖动
          _isScrolling = true;
          _previewScale = 2.0;
          setState(() {});
        },
        onPanUpdate: (details) {
          // 处理鼠标拖动
          final delta = details.delta.dx;
          if (delta.abs() > 5) {
            // 设置最小拖动距离阈值
            if (delta > 0) {
              // 向右拖动，预览上一页
              if (_previewIndex > 0) {
                _previewIndex--;
                _scrollToPreviewPage(); // 滚动到预览页面中心
                setState(() {});
              }
            } else {
              // 向左拖动，预览下一页
              if (_previewIndex < widget.totalPages - 1) {
                _previewIndex++;
                _scrollToPreviewPage(); // 滚动到预览页面中心
                setState(() {});
              }
            }
          }
        },
        onPanEnd: (details) {
          // 结束拖动，延迟切换
          _scrollEndTimer?.cancel();
          _scrollEndTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              _isScrolling = false;
              _previewScale = 1.0;
              widget.onPageTap(_previewIndex);
              setState(() {});
            }
          });
        },
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.totalPages,
            itemBuilder: (context, index) {
              final isCurrentPage = index == widget.currentPage;
              final isPreviewPage = _isScrolling && index == _previewIndex;
              final shouldLoad = _loadedIndices.contains(index) ||
                  _preloadedIndices.contains(index);

              // 计算缩放比例
              double scale = 1.0;
              if (isPreviewPage) {
                scale = _previewScale; // 预览时2倍放大
              } else if (isCurrentPage && !_isScrolling) {
                scale = 1.4; // 当前页1.4倍放大
              }

              final currentWidth = widget.itemWidth * scale;
              final currentHeight = widget.height * scale * 0.8; // 高度也要缩放

              return GestureDetector(
                onTap: () => widget.onPageTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // 增加动画时长
                  curve: Curves.easeOutBack, // 使用弹性动画曲线
                  width: currentWidth,
                  height: currentHeight, // 使用计算出的高度
                  margin:
                      EdgeInsets.symmetric(horizontal: widget.itemSpacing / 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isPreviewPage
                          ? Colors.blue
                          : (isCurrentPage ? Colors.amber : Colors.transparent),
                      width: (isPreviewPage || isCurrentPage) ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isPreviewPage
                        ? [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha:0.8), // 预览页蓝色阴影
                              blurRadius: 16,
                              spreadRadius: 4,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : isCurrentPage
                            ? [
                                BoxShadow(
                                  color:
                                      Colors.amber.withValues(alpha:0.6), // 当前页金色阴影
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: shouldLoad &&
                            widget.pages.isNotEmpty &&
                            widget.pages.length > index
                        ? _buildThumbnailImage(widget.pages[index])
                        : _buildThumbnailPlaceholder(index + 1),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(MangaPage page) {
    if (page.largeThumbnail != null &&
        File(page.largeThumbnail!).existsSync()) {
      return Image.file(
        File(page.largeThumbnail!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildThumbnailPlaceholder(page.pageIndex),
      );
    } else if (page.localPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: page.localPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            _buildThumbnailPlaceholder(page.pageIndex),
        errorWidget: (context, url, error) =>
            _buildThumbnailPlaceholder(page.pageIndex),
      );
    } else {
      return _buildThumbnailPlaceholder(page.pageIndex);
    }
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
}

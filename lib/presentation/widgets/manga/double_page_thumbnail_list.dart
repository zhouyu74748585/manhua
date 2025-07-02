import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:async';

import '../../../data/models/manga_page.dart';

class DoublePageThumbnailList extends StatefulWidget {
  final List<MangaPage> pages;
  final List<List<int>> doublePageGroups;
  final int currentGroupIndex;
  final Function(int) onGroupTap;
  final double height;
  final int preloadCount;
  final double itemWidth;
  final double itemSpacing;

  const DoublePageThumbnailList({
    super.key,
    required this.pages,
    required this.doublePageGroups,
    required this.currentGroupIndex,
    required this.onGroupTap,
    this.height = 60,
    this.preloadCount = 10,
    this.itemWidth = 80, // 双页缩略图更宽
    this.itemSpacing = 4,
  });

  @override
  State<DoublePageThumbnailList> createState() =>
      _DoublePageThumbnailListState();
}

class _DoublePageThumbnailListState extends State<DoublePageThumbnailList> {
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
    _previewIndex = widget.currentGroupIndex;
  }

  @override
  void didUpdateWidget(DoublePageThumbnailList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当当前组改变时，滚动到对应位置并同步预览索引
    if (oldWidget.currentGroupIndex != widget.currentGroupIndex &&
        _isInitialized) {
      _previewIndex = widget.currentGroupIndex;
      _scrollToCurrentGroup();
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
    final startIndex = (scrollOffset / itemTotalWidth)
        .floor()
        .clamp(0, widget.doublePageGroups.length - 1);
    final endIndex = ((scrollOffset + viewportWidth) / itemTotalWidth)
        .ceil()
        .clamp(0, widget.doublePageGroups.length);

    // 加载可见范围内的图片
    for (int i = startIndex; i < endIndex; i++) {
      if (!_loadedIndices.contains(i)) {
        _loadedIndices.add(i);
      }
    }

    // 预加载前后的图片
    final preloadStart = (startIndex - widget.preloadCount)
        .clamp(0, widget.doublePageGroups.length);
    final preloadEnd = (endIndex + widget.preloadCount)
        .clamp(0, widget.doublePageGroups.length);

    for (int i = preloadStart; i < preloadEnd; i++) {
      if (!_preloadedIndices.contains(i)) {
        _preloadedIndices.add(i);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToCurrentGroup() {
    if (!_scrollController.hasClients) return;

    final itemTotalWidth = widget.itemWidth + widget.itemSpacing;
    // 计算目标偏移量，确保当前组在视口中心
    final viewportCenter = _scrollController.position.viewportDimension / 2;
    final targetOffset = (widget.currentGroupIndex * itemTotalWidth) -
        viewportCenter +
        (widget.itemWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToPreviewGroup() {
    if (!_scrollController.hasClients) return;

    final itemTotalWidth = widget.itemWidth + widget.itemSpacing;
    // 计算目标偏移量，确保预览组在视口中心
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
        // 向右滚动，预览下一组
        if (_previewIndex < widget.doublePageGroups.length - 1) {
          _previewIndex++;
          _scrollToPreviewGroup();
        }
      } else if (scrollDelta < 0) {
        // 向左滚动，预览上一组
        if (_previewIndex > 0) {
          _previewIndex--;
          _scrollToPreviewGroup();
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
          // 切换到预览的组
          widget.onGroupTap(_previewIndex);
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始化时滚动到当前组
    if (!_isInitialized && widget.doublePageGroups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isInitialized = true;
        _updateVisibleItems();
        _scrollToCurrentGroup();
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
              // 向右拖动，预览上一组
              if (_previewIndex > 0) {
                _previewIndex--;
                _scrollToPreviewGroup();
                setState(() {});
              }
            } else {
              // 向左拖动，预览下一组
              if (_previewIndex < widget.doublePageGroups.length - 1) {
                _previewIndex++;
                _scrollToPreviewGroup();
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
              widget.onGroupTap(_previewIndex);
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
            itemCount: widget.doublePageGroups.length,
            itemBuilder: (context, index) {
              final isCurrentGroup = index == widget.currentGroupIndex;
              final isPreviewGroup = _isScrolling && index == _previewIndex;
              final shouldLoad = _loadedIndices.contains(index) ||
                  _preloadedIndices.contains(index);

              // 计算缩放比例
              double scale = 1.0;
              if (isPreviewGroup) {
                scale = _previewScale; // 预览时2倍放大
              } else if (isCurrentGroup && !_isScrolling) {
                scale = 1.4; // 当前组1.4倍放大
              }

              final currentWidth = widget.itemWidth * scale;
              final currentHeight = widget.height * scale * 0.8;

              return GestureDetector(
                onTap: () => widget.onGroupTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: currentWidth,
                  height: currentHeight,
                  margin:
                      EdgeInsets.symmetric(horizontal: widget.itemSpacing / 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isPreviewGroup
                          ? Colors.blue
                          : (isCurrentGroup
                              ? Colors.amber
                              : Colors.transparent),
                      width: (isPreviewGroup || isCurrentGroup) ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isPreviewGroup
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.8),
                              blurRadius: 16,
                              spreadRadius: 4,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : isCurrentGroup
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: shouldLoad && widget.pages.isNotEmpty
                        ? _buildGroupThumbnail(widget.doublePageGroups[index])
                        : _buildGroupPlaceholder(index + 1),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGroupThumbnail(List<int> group) {
    if (group.length == 2) {
      // 双页缩略图
      return Row(
        children: [
          Expanded(
            child: _buildSingleThumbnail(group[0]),
          ),
          Container(width: 1, color: Colors.white.withOpacity(0.3)), // 分隔线
          Expanded(
            child: _buildSingleThumbnail(group[1]),
          ),
        ],
      );
    } else {
      // 单页缩略图
      return _buildSingleThumbnail(group[0]);
    }
  }

  Widget _buildSingleThumbnail(int pageIndex) {
    if (widget.pages.isEmpty || pageIndex >= widget.pages.length) {
      return _buildThumbnailPlaceholder(pageIndex + 1);
    }

    final page = widget.pages[pageIndex];

    if (page.largeThumbnail != null &&
        File(page.largeThumbnail!).existsSync()) {
      return Image.file(
        File(page.largeThumbnail!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildThumbnailPlaceholder(pageIndex + 1),
      );
    } else if (page.localPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: page.localPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            _buildThumbnailPlaceholder(pageIndex + 1),
        errorWidget: (context, url, error) =>
            _buildThumbnailPlaceholder(pageIndex + 1),
      );
    } else {
      return _buildThumbnailPlaceholder(pageIndex + 1);
    }
  }

  Widget _buildGroupPlaceholder(int groupNumber) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          'G$groupNumber',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

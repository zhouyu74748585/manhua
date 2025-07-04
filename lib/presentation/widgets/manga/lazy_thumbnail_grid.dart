import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/manga_page.dart';

class LazyThumbnailGrid extends StatefulWidget {
  final List<MangaPage> pages;
  final int totalPages;
  final int? currentPage;
  final Function(int) onPageTap;
  final int crossAxisCount;
  final int preloadCount;
  final bool showPageNumbers;
  final double spacing;

  const LazyThumbnailGrid({
    super.key,
    required this.pages,
    required this.totalPages,
    this.currentPage,
    required this.onPageTap,
    this.crossAxisCount = 4,
    this.preloadCount = 10,
    this.showPageNumbers = true,
    this.spacing = 8.0,
  });

  @override
  State<LazyThumbnailGrid> createState() => _LazyThumbnailGridState();
}

class _LazyThumbnailGridState extends State<LazyThumbnailGrid> {
  final Set<int> _loadedIndices = {};
  final Set<int> _preloadedIndices = {};
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // 初始加载可见范围内的图片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleItems();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleItems();
  }

  void _updateVisibleItems() {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final viewportHeight = renderBox.size.height;
    final scrollOffset = _scrollController.offset;

    // 估算每行的高度（基于网格布局）
    final itemWidth =
        (renderBox.size.width - (widget.crossAxisCount - 1) * widget.spacing) /
            widget.crossAxisCount;
    final itemHeight = itemWidth * 1.4; // 假设图片比例为1:1.4
    final rowHeight = itemHeight + widget.spacing;

    // 计算可见范围
    final startRow = (scrollOffset / rowHeight)
        .floor()
        .clamp(0, (widget.totalPages / widget.crossAxisCount).ceil() - 1);
    final endRow = ((scrollOffset + viewportHeight) / rowHeight)
        .ceil()
        .clamp(0, (widget.totalPages / widget.crossAxisCount).ceil() - 1);

    final startIndex = startRow * widget.crossAxisCount;
    final endIndex =
        ((endRow + 1) * widget.crossAxisCount).clamp(0, widget.totalPages);

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

  Widget _buildThumbnail(int index) {
    final pageIndex = index + 1;
    final isCurrentPage = widget.currentPage == pageIndex;
    final shouldLoad =
        _loadedIndices.contains(index) || _preloadedIndices.contains(index);

    return GestureDetector(
      onTap: () => widget.onPageTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isCurrentPage
                ? Theme.of(context).primaryColor
                : Colors.grey.withValues(alpha:0.3),
            width: isCurrentPage ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // 缩略图内容
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: shouldLoad &&
                      widget.pages.isNotEmpty &&
                      index < widget.pages.length
                  ? _buildPageThumbnail(widget.pages[index])
                  : _buildPlaceholder(pageIndex),
            ),
            // 页码显示
            if (widget.showPageNumbers)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$pageIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // 当前页面标识
            if (isCurrentPage)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageThumbnail(MangaPage page) {
    // 安全检查页面索引
    final pageNumber = page.pageIndex;

    try {
      if (page.largeThumbnail != null && page.largeThumbnail!.isNotEmpty) {
        final thumbnailFile = File(page.largeThumbnail!);
        if (thumbnailFile.existsSync()) {
          return Image.file(
            thumbnailFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholder(pageNumber),
          );
        }
      }

      if (page.localPath.isNotEmpty && page.localPath.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: page.localPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => _buildPlaceholder(pageNumber),
          errorWidget: (context, url, error) => _buildPlaceholder(pageNumber),
        );
      }

      return _buildPlaceholder(pageNumber);
    } catch (e) {
      // 捕获任何异常并返回占位符
      return _buildPlaceholder(pageNumber);
    }
  }

  Widget _buildPlaceholder(int pageNumber) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            color: Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '$pageNumber',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.spacing,
        crossAxisSpacing: widget.spacing,
        childAspectRatio: 0.7, // 设置固定的宽高比
      ),
      itemCount: widget.totalPages,
      itemBuilder: (context, index) {
        return Container(
          constraints: const BoxConstraints(
            minHeight: 120,
            maxHeight: 200,
          ),
          child: _buildThumbnail(index),
        );
      },
    );
  }
}

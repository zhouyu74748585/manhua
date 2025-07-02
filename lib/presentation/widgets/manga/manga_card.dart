import 'dart:io';
import 'package:flutter/material.dart';

class MangaCard extends StatefulWidget {
  final String title;
  final String? coverPath;
  final String? subtitle;
  final double? progress;
  final int totalPages;
  final int? currentPage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MangaCard({
    super.key,
    required this.title,
    required this.totalPages,
    this.currentPage,
    this.coverPath,
    this.subtitle,
    this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: _isHovered ? 8 : 2,
                  child: Stack(
                    children: [
                      _buildCoverImage(),
                      // 悬停时显示的操作按钮和进度信息
                      if (_isHovered)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 顶部操作按钮
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, color: Colors.white),
                                      onPressed: widget.onLongPress,
                                      tooltip: '查看详情',
                                    ),
                                  ],
                                ),
                              ),
                              // 底部进度信息
                              if (widget.progress != null || widget.currentPage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (widget.currentPage != null)
                                        Text(
                                          '${widget.currentPage}/${widget.totalPages} 页',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (widget.progress != null) ...[
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: widget.progress!,
                                          backgroundColor: Colors.white.withOpacity(0.3),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      // 中央的大开始阅读按钮（悬停时显示）
                      if (_isHovered)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              iconSize: 48,
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              onPressed: widget.onTap,
                              tooltip: '开始阅读',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

             const SizedBox(height: 8),
             Text(
               widget.title,
               style: Theme.of(context).textTheme.titleSmall,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return widget.coverPath != null && widget.coverPath!.isNotEmpty
        ? Image.file(
            File(widget.coverPath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image));
            },
          )
        : Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
  }
}

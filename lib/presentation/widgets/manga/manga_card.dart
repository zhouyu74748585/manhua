import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manhua_reader_flutter/presentation/providers/manga_provider.dart';

import '../../../core/services/task_tracker_service.dart';
import '../../../data/models/library.dart';

class MangaCard extends ConsumerStatefulWidget {
  final String? mangaId; // 添加mangaId参数
  final String title;
  final String? coverPath;
  final String? subtitle;
  final double? progress;
  final int totalPages;
  final int? currentPage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final CoverDisplayMode coverDisplayMode;
  final double coverScale;
  final double coverOffsetX;

  const MangaCard({
    super.key,
    this.mangaId, // 添加mangaId参数
    required this.title,
    required this.totalPages,
    this.currentPage,
    this.coverPath,
    this.subtitle,
    this.progress,
    this.onTap,
    this.onLongPress,
    this.coverDisplayMode = CoverDisplayMode.defaultMode,
    this.coverScale = 3.0,
    this.coverOffsetX = 0.4,
  });

  @override
  ConsumerState<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends ConsumerState<MangaCard> {
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
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
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
                                    // 获取封面按钮
                                    if (widget.mangaId != null)
                                      IconButton(
                                        icon: const Icon(Icons.image,
                                            color: Colors.white, size: 20),
                                        onPressed: () =>
                                            _generateCover(context),
                                        tooltip: '获取封面',
                                      ),
                                    // 生成缩略图按钮
                                    if (widget.mangaId != null)
                                      IconButton(
                                        icon: const Icon(Icons.photo_library,
                                            color: Colors.white, size: 20),
                                        onPressed: () =>
                                            _generateThumbnails(context),
                                        tooltip: '生成缩略图',
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.sync,
                                          color: Colors.white, size: 20),
                                      onPressed: () =>
                                          _showSyncOptions(context),
                                      tooltip: '同步进度',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline,
                                          color: Colors.white),
                                      onPressed: widget.onLongPress,
                                      tooltip: '查看详情',
                                    ),
                                  ],
                                ),
                              ),
                              // 底部进度信息
                              if (widget.progress != null ||
                                  widget.currentPage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.3),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.white),
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
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              iconSize: 48,
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.white),
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
    if (widget.coverPath == null || widget.coverPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    // 根据显示模式处理图片
    switch (widget.coverDisplayMode) {
      case CoverDisplayMode.leftHalf:
        // 显示图片的左半部分 (0-50%)
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Transform.scale(
              scale: widget.coverScale,
              alignment: Alignment(-widget.coverOffsetX, 0),
              child: Image.file(
                File(widget.coverPath!),
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
          ),
        );
      case CoverDisplayMode.rightHalf:
        // 显示图片的右半部分 (50-100%)
        return ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: Transform.scale(
              scale: widget.coverScale,
              alignment: Alignment(widget.coverOffsetX, 0),
              child: Image.file(
                File(widget.coverPath!),
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
          ),
        );
      case CoverDisplayMode.defaultMode:
        return Image.file(
          File(widget.coverPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image));
          },
        );
    }
  }

  void _showSyncOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '同步选项',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('同步阅读进度'),
              subtitle: const Text('将此漫画的阅读进度同步到其他设备'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/sync/device-management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('同步整个漫画库'),
              subtitle: const Text('同步包含此漫画的整个漫画库'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/sync/device-management');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 生成封面
  void _generateCover(BuildContext context) async {
    if (widget.mangaId == null) return;

    // 检查是否已有任务在运行
    if (ref
        .read(mangaActionsProvider.notifier)
        .isCoverGenerationRunning(widget.mangaId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('《${widget.title}》的封面生成任务已在运行中'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('正在为《${widget.title}》生成封面...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // 调用封面生成方法
      await ref
          .read(mangaActionsProvider.notifier)
          .generateCoverForManga(widget.mangaId!);

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('《${widget.title}》封面生成完成'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on TaskAlreadyRunningException catch (e) {
      // 处理任务已运行异常
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('《${widget.title}》的封面生成任务已在运行中'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('封面生成失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 生成缩略图
  void _generateThumbnails(BuildContext context) async {
    if (widget.mangaId == null) return;

    // 检查是否已有任务在运行
    if (ref
        .read(mangaActionsProvider.notifier)
        .isThumbnailGenerationRunning(widget.mangaId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('《${widget.title}》的缩略图生成任务已在运行中'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('正在为《${widget.title}》生成缩略图...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // 调用缩略图生成方法
      await ref
          .read(mangaActionsProvider.notifier)
          .generateThumbnailsForManga(widget.mangaId!);

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('《${widget.title}》缩略图生成完成'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on TaskAlreadyRunningException catch (e) {
      // 处理任务已运行异常
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('《${widget.title}》的缩略图生成任务已在运行中'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 处理其他异常
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('缩略图生成失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

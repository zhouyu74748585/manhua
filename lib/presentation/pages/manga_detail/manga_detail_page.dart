import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manhua_reader_flutter/data/models/manga_page.dart';
import 'package:manhua_reader_flutter/data/models/reading_progress.dart';

import '../../../data/models/manga.dart';
import '../../providers/manga_provider.dart';
import '../../widgets/manga/lazy_thumbnail_grid.dart';
import '../reader/reader_page.dart';

class MangaDetailPage extends ConsumerWidget {
  final String mangaId;

  const MangaDetailPage({
    super.key,
    required this.mangaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(mangaDetailWithCallbackProvider(mangaId));
    final pages = ref.watch(mangaPagesProvider(mangaId)).value ?? [];
    final progress = ref.watch(mangaProgressProvider(mangaId)).value;
    return Scaffold(
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null) {
            return const Center(
              child: Text('漫画不存在'),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, manga),
              _buildMangaInfo(context, manga, progress),
              _buildPageGrid(context, manga, progress, pages),
            ],
          );
        },
        loading: () => const Scaffold(
          appBar: null,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(
            title: const Text('漫画详情'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载失败: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(mangaDetailWithCallbackProvider(mangaId));
                    ref.invalidate(mangaPagesProvider(mangaId));
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, Manga manga) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          manga.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildCoverImage(manga.coverPath),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.library_books, color: Colors.white),
          onPressed: () {
            context.go('/bookshelf');
          },
          tooltip: '书架',
        ),
        IconButton(
          icon: Icon(
            manga.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: manga.isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () {
            ref
                .read(mangaActionsProvider.notifier)
                .toggleFavorite(manga.id, !manga.isFavorite);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // TODO: 实现分享功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('分享功能待实现')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoverImage(String? coverPath) {
    if (coverPath == null || coverPath.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(
          Icons.book,
          size: 100,
          color: Colors.grey,
        ),
      );
    }

    if (coverPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: coverPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      final file = File(coverPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.grey,
            ),
          ),
        );
      } else {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.book,
            size: 100,
            color: Colors.grey,
          ),
        );
      }
    }
  }

  Widget _buildMangaInfo(
      BuildContext context, Manga manga, ReadingProgress? progress) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (manga.author != null && manga.author!.isNotEmpty)
                        Text(
                          '作者: ${manga.author}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '状态: ${_getStatusText(manga.status)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '总页数: ${manga.totalPages}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // 阅读进度
                if (progress != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${progress.currentPage}/${manga.totalPages}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 标签
            if (manga.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: manga.tags
                    .map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),

            const SizedBox(height: 16),

            // 简介
            if (manga.description != null && manga.description!.isNotEmpty) ...[
              Text(
                '简介',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                manga.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPageGrid(BuildContext context, Manga manga,
      ReadingProgress? progress, List<MangaPage> pages) {
    final totalPages = manga.totalPages;

    if (totalPages == 0) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('暂无页面'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 标题和开始阅读按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '页面预览 ($totalPages 页)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: () {
                  _startReading(context, manga, progress?.currentPage ?? 1);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始阅读'),
              ),
            ],
          ),
          const SizedBox(height: 20), // 增加间距
          // 懒加载页面网格
          LazyThumbnailGrid(
            pages: pages,
            totalPages: totalPages,
            currentPage: progress?.currentPage,
            onPageTap: (index) {
              _startReading(context, manga, index);
            },
            crossAxisCount: 4,
            preloadCount: 10,
            showPageNumbers: true, // 显示页码
            spacing: 12.0, // 增加间距
          ),
        ]),
      ),
    );
  }

  void _startReading(BuildContext context, Manga manga, int startPage) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          mangaId: manga.id,
          initialPage: startPage,
        ),
      ),
    );
  }

  String _getStatusText(MangaStatus status) {
    switch (status) {
      case MangaStatus.ongoing:
        return '连载中';
      case MangaStatus.completed:
        return '已完结';
      case MangaStatus.hiatus:
        return '暂停';
      case MangaStatus.cancelled:
        return '已取消';
      case MangaStatus.unknown:
        return '未知';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manhua_reader_flutter/data/models/library.dart';
import 'package:manhua_reader_flutter/presentation/providers/library_provider.dart';

import '../../../app/routes/app_router.dart';
import '../../../data/models/manga.dart';
import '../../../data/models/reading_progress.dart';
import '../../providers/manga_provider.dart';
import '../../widgets/common/responsive_grid.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/manga/manga_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画阅读器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 刷新数据
              ref.invalidate(recentlyReadMangaProvider);
              ref.invalidate(recentlyUpdatedMangaProvider);
              ref.invalidate(allMangaProgressProvider);
            },
          ),
        ],
      ),
      body: const _HomeContent(),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // 实现下拉刷新
        ref.invalidate(recentlyReadMangaProvider);
        ref.invalidate(recentlyUpdatedMangaProvider);
        ref.invalidate(allMangaProgressProvider);
        ref.invalidate(allLibrariesProvider);

        // 等待数据加载完成
        await Future.wait([
          ref.read(recentlyReadMangaProvider.future),
          ref.read(recentlyUpdatedMangaProvider.future),
          ref.read(allMangaProgressProvider.future),
          ref.read(allLibrariesProvider.future),
        ]);
      },
      child: CustomScrollView(
        slivers: [
          // 最近阅读
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: '最近阅读',
              showMore: true,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: _buildRecentlyRead(context, ref),
            ),
          ),

          // 最新更新
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: '最新更新',
              showMore: true,
            ),
          ),
          _buildLatestUpdates(context, ref),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyRead(BuildContext context, WidgetRef ref) {
    final recentlyReadAsync = ref.watch(recentlyReadMangaProvider);
    final allProgressAsync = ref.watch(allMangaProgressProvider);
    final libraries = ref.watch(allLibrariesProvider);
    Map<String, MangaLibrary> librariesMap = {
      if (libraries.value != null)
        for (var e in libraries.value!) e.id: e
    };
    return recentlyReadAsync.when(
      data: (recentlyRead) {
        if (recentlyRead.isEmpty) {
          return const Center(
            child: Text(
              '暂无最近阅读记录',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return allProgressAsync.when(
          data: (progressMap) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentlyRead.length,
              itemBuilder: (context, index) {
                final manga = recentlyRead[index];
                final progress = progressMap[manga.id];

                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: MangaCard(
                    title: manga.title,
                    coverPath: manga.coverPath,
                    coverDisplayMode: librariesMap[manga.libraryId]
                            ?.settings
                            .coverDisplayMode ??
                        CoverDisplayMode.defaultMode,
                    progress: progress?.progressPercentage ?? 0.0,
                    subtitle: _formatLastRead(progress),
                    totalPages: manga.totalPages,
                    onTap: () {
                      context.go('/manga/${manga.id}');
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              '加载进度失败: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          '加载最近阅读失败: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildLatestUpdates(BuildContext context, WidgetRef ref) {
    final latestUpdatesAsync = ref.watch(recentlyUpdatedMangaProvider);
    final libraries = ref.watch(allLibrariesProvider);
    Map<String, MangaLibrary> librariesMap = {
      if (libraries.value != null)
        for (var e in libraries.value!) e.id: e
    };
    return latestUpdatesAsync.when(
      data: (latestUpdates) {
        if (latestUpdates.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '暂无最新更新',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return ResponsiveGrid<Manga>(
          items: latestUpdates,
          itemBuilder: (context, manga) {
            return MangaCard(
              title: manga.title,
              coverPath: manga.coverPath,
              coverDisplayMode:
                  librariesMap[manga.libraryId]?.settings.coverDisplayMode ??
                      CoverDisplayMode.defaultMode,
              subtitle: _formatUpdateTime(manga.updatedAt),
              totalPages: manga.totalPages,
              onTap: () {
                context.go('/manga/${manga.id}');
              },
            );
          },
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              '加载最新更新失败: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  /// 格式化最后阅读信息
  String _formatLastRead(ReadingProgress? progress) {
    if (progress == null) return '未开始阅读';

    final currentPage = progress.currentPage;
    final totalPages = progress.totalPages;
    final percentage = (progress.progressPercentage * 100).toInt();

    return '第 $currentPage/$totalPages 页 ($percentage%)';
  }

  /// 格式化更新时间
  String _formatUpdateTime(DateTime? updatedAt) {
    if (updatedAt == null) return '未知时间';

    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_router.dart';
import '../../widgets/common/responsive_grid.dart';
import '../../widgets/manga/manga_card.dart';
import '../../widgets/common/section_header.dart';

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
              // TODO: 刷新数据
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
        // TODO: 实现下拉刷新
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
    // TODO: 从Provider获取最近阅读数据
    final recentlyRead = <Map<String, dynamic>>[
      {
        'id': '1',
        'title': '示例漫画 1',
        'coverPath': '',
        'progress': 0.6,
        'totalPages': 100,
        'lastReadChapter': '第 12 话',
      },
      {
        'id': '2',
        'title': '示例漫画 2',
        'coverPath': '',
        'progress': 0.3,
        'totalPages': 100,
        'lastReadChapter': '第 5 话',
      },
    ];

    if (recentlyRead.isEmpty) {
      return const Center(
        child: Text(
          '暂无最近阅读记录',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recentlyRead.length,
      itemBuilder: (context, index) {
        final manga = recentlyRead[index];
        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          child: MangaCard(
            title: manga['title'],
            coverPath: manga['coverPath'],
            progress: manga['progress'],
            subtitle: manga['title'],
            totalPages: manga['totalPages'],
            onTap: () {
              context.go('/manga/${manga['id']}');
            },
          ),
        );
      },
    );
  }

  Widget _buildLatestUpdates(BuildContext context, WidgetRef ref) {
    // TODO: 从Provider获取最新更新数据
    final latestUpdates = <Map<String, dynamic>>[
      {
        'id': '3',
        'title': '最新漫画 1',
        'coverPath': '',
        'totalPages': 100,
        'updateTime': '2小时前',
        'newChapter': '第 25 话',
      },
      {
        'id': '4',
        'title': '最新漫画 2',
        'coverPath': '',
        'totalPages': 100,
        'updateTime': '5小时前',
        'newChapter': '第 18 话',
      },
    ];

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

    return ResponsiveGrid(
      items: latestUpdates,
      itemBuilder: (context, manga) {
        return MangaCard(
          title: manga['title'],
          coverPath: manga['coverPath'],
          subtitle: '${manga['newChapter']} • ${manga['updateTime']}',
          totalPages: manga['totalPages'],
          onTap: () {
            context.go('/manga/${manga['id']}');
          },
        );
      },
    );
  }
}

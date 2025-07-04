import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manhua_reader_flutter/data/models/reading_progress.dart';
import 'package:manhua_reader_flutter/presentation/widgets/manga/manga_list_tile.dart';

import '../../../data/models/library.dart';
import '../../../data/models/manga.dart';
import '../../providers/library_provider.dart';
import '../../providers/manga_provider.dart';
import '../../widgets/manga/manga_card.dart';
import '../manga_detail/manga_detail_page.dart';
import '../reader/reader_page.dart';

enum BookshelfViewMode { grid, list }

enum BookshelfSortMode { title, author, dateAdded, lastRead }

enum GridSize { small, medium, large, extraLarge }

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  BookshelfViewMode _viewMode = BookshelfViewMode.grid;
  BookshelfSortMode _sortMode = BookshelfSortMode.title;
  GridSize _gridSize = GridSize.medium;
  String _searchQuery = '';
  String? _selectedLibraryId; // 选中的漫画库ID，null表示显示所有

  @override
  Widget build(BuildContext context) {
    final mangaListAsync = ref.watch(allMangaProvider);
    final librariesAsync = ref.watch(allLibrariesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          // 漫画库筛选（只显示激活状态的漫画库）
          PopupMenuButton<String?>(
            icon: const Icon(Icons.library_books),
            tooltip: '筛选漫画库',
            onSelected: (libraryId) =>
                setState(() => _selectedLibraryId = libraryId),
            itemBuilder: (context) {
              return librariesAsync.when(
                data: (libraries) {
                  // 只显示激活状态的漫画库
                  final enabledLibraries =
                      libraries.where((lib) => lib.isEnabled).toList();
                  return [
                    const PopupMenuItem<String?>(
                      value: null,
                      child: Text('所有激活漫画库'),
                    ),
                    ...enabledLibraries.map((library) => PopupMenuItem<String?>(
                          value: library.id,
                          child: Text(library.name),
                        )),
                  ];
                },
                loading: () => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('加载中...'),
                  )
                ],
                error: (_, __) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('加载失败'),
                  )
                ],
              );
            },
          ),
          PopupMenuButton<BookshelfSortMode>(
            icon: const Icon(Icons.sort),
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BookshelfSortMode.title,
                child: Text('按标题排序'),
              ),
              const PopupMenuItem(
                value: BookshelfSortMode.author,
                child: Text('按作者排序'),
              ),
              const PopupMenuItem(
                value: BookshelfSortMode.dateAdded,
                child: Text('按添加时间排序'),
              ),
              const PopupMenuItem(
                value: BookshelfSortMode.lastRead,
                child: Text('按最后阅读排序'),
              ),
            ],
          ),
          // 网格尺寸选择（仅在网格模式下显示）
          if (_viewMode == BookshelfViewMode.grid)
            PopupMenuButton<GridSize>(
              icon: const Icon(Icons.grid_view),
              tooltip: '网格尺寸',
              onSelected: (size) => setState(() => _gridSize = size),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: GridSize.small,
                  child: Text('小尺寸 (4列)'),
                ),
                const PopupMenuItem(
                  value: GridSize.medium,
                  child: Text('中尺寸 (3列)'),
                ),
                const PopupMenuItem(
                  value: GridSize.large,
                  child: Text('大尺寸 (2列)'),
                ),
                const PopupMenuItem(
                  value: GridSize.extraLarge,
                  child: Text('超大尺寸 (1列)'),
                ),
              ],
            ),
          IconButton(
            icon: Icon(_viewMode == BookshelfViewMode.grid
                ? Icons.view_list
                : Icons.view_module),
            onPressed: () => setState(() {
              _viewMode = _viewMode == BookshelfViewMode.grid
                  ? BookshelfViewMode.list
                  : BookshelfViewMode.grid;
            }),
          ),
        ],
      ),
      body: mangaListAsync.when(
        data: (mangaList) => _buildMangaList(mangaList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allMangaProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaList(List<Manga> mangaList) {
    final librariesAsync = ref.watch(allLibrariesProvider);
    final readingProcessMapAsync = ref.watch(allMangaProgressProvider);
    // 首先过滤出只属于激活状态漫画库的漫画
    List<Manga> filteredList = librariesAsync.when(
      data: (libraries) {
        final enabledLibraryIds = libraries
            .where((lib) => lib.isEnabled)
            .map((lib) => lib.id)
            .toSet();

        return mangaList.where((manga) {
          return enabledLibraryIds.contains(manga.libraryId);
        }).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );

    // 再根据选中的漫画库进行过滤
    if (_selectedLibraryId != null) {
      filteredList = filteredList.where((manga) {
        return manga.libraryId == _selectedLibraryId;
      }).toList();
    }

    // 过滤搜索结果
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((manga) {
        return manga.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (manga.author?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // 排序
    filteredList =
        _sortMangaList(filteredList, readingProcessMapAsync.value ?? {});

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? '没有找到匹配的漫画' : '书架是空的',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty ? '尝试使用不同的关键词搜索' : '去漫画库扫描一些漫画吧',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_viewMode == BookshelfViewMode.grid) {
      return _buildGridView(filteredList, readingProcessMapAsync.value ?? {});
    } else {
      return _buildListView(filteredList, readingProcessMapAsync.value ?? {});
    }
  }

  Widget _buildGridView(List<Manga> mangaList,
      Map<String, ReadingProgress> readingProcessMapAsync) {
    final gridConfig = _getGridConfig(_gridSize);
    final librariesAsync = ref.watch(allLibrariesProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridConfig.crossAxisCount,
        childAspectRatio: gridConfig.childAspectRatio,
        crossAxisSpacing: gridConfig.crossAxisSpacing,
        mainAxisSpacing: gridConfig.mainAxisSpacing,
      ),
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        final manga = mangaList[index];
        final progress = readingProcessMapAsync[manga.id];

        // 获取漫画所属库的设置
        final librarySettings = librariesAsync.when(
          data: (libraries) {
            final library = libraries.firstWhere(
              (lib) => lib.id == manga.libraryId,
              orElse: () => libraries.first,
            );
            return library.settings;
          },
          loading: () => null,
          error: (_, __) => null,
        );

        return MangaCard(
          title: manga.title,
          coverPath: manga.coverPath,
          subtitle: manga.author,
          totalPages: manga.totalPages,
          currentPage: progress?.currentPage ?? 0,
          progress: progress?.progressPercentage,
          coverDisplayMode:
              librarySettings?.coverDisplayMode ?? CoverDisplayMode.defaultMode,
          coverScale: librarySettings?.coverScale ?? 3.0,
          coverOffsetX: librarySettings?.coverOffsetX ?? 0.4,
          onTap: () => _startReading(manga, progress),
          onLongPress: () => _openMangaDetail(manga),
        );
      },
    );
  }

  GridConfig _getGridConfig(GridSize size) {
    switch (size) {
      case GridSize.small:
        return const GridConfig(
          crossAxisCount: 4,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        );
      case GridSize.medium:
        return const GridConfig(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        );
      case GridSize.large:
        return const GridConfig(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        );
      case GridSize.extraLarge:
        return const GridConfig(
          crossAxisCount: 1,
          childAspectRatio: 0.65, // 调整为更大的比例以填充宽度
          crossAxisSpacing: 10, // 消除横向间距
          mainAxisSpacing: 10, // 消除纵向间距
        );
    }
  }

  Widget _buildListView(List<Manga> mangaList,
      Map<String, ReadingProgress> readingProcessMapAsync) {
    final librariesAsync = ref.watch(allLibrariesProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        final manga = mangaList[index];
        final progress = readingProcessMapAsync[manga.id];

        // 获取漫画所属库的设置
        final librarySettings = librariesAsync.when(
          data: (libraries) {
            final library = libraries.firstWhere(
              (lib) => lib.id == manga.libraryId,
              orElse: () => libraries.first,
            );
            return library.settings;
          },
          loading: () => null,
          error: (_, __) => null,
        );

        return MangaListTile(
          title: manga.title,
          coverPath: manga.coverPath,
          subtitle: manga.author,
          progress: progress?.progressPercentage,
          coverDisplayMode:
              librarySettings?.coverDisplayMode ?? CoverDisplayMode.defaultMode,
          coverScale: librarySettings?.coverScale ?? 3.0,
          coverOffsetX: librarySettings?.coverOffsetX ?? 0.4,
          onTap: () => _openMangaDetail(manga),
          onLongPress: () => _toggleFavorite(manga),
        );
      },
    );
  }

  List<Manga> _sortMangaList(List<Manga> mangaList,
      Map<String, ReadingProgress> readingProcessMapAsync) {
    final sortedList = List<Manga>.from(mangaList);

    switch (_sortMode) {
      case BookshelfSortMode.title:
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case BookshelfSortMode.author:
        sortedList.sort((a, b) {
          final authorA = a.author ?? '';
          final authorB = b.author ?? '';
          return authorA.compareTo(authorB);
        });
        break;
      case BookshelfSortMode.dateAdded:
        sortedList.sort((a, b) {
          final createdAtA = a.createdAt ?? DateTime(1970);
          final createdAtB = b.createdAt ?? DateTime(1970);
          return createdAtB.compareTo(createdAtA);
        });
        break;
      case BookshelfSortMode.lastRead:
        sortedList.sort((a, b) {
          final lastReadA =
              readingProcessMapAsync[a.id]?.lastReadAt ?? DateTime(1970);
          final lastReadB =
              readingProcessMapAsync[b.id]?.lastReadAt ?? DateTime(1970);
          return lastReadB.compareTo(lastReadA);
        });
        break;
    }

    return sortedList;
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索漫画'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入漫画标题或作者',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.of(context).pop();
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _openMangaDetail(Manga manga) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MangaDetailPage(mangaId: manga.id),
      ),
    );
  }

  void _startReading(Manga manga, ReadingProgress? progress) {
    final startPage = progress?.currentPage ?? 1;

    // 触发缩略图生成（如果需要的话）
    ref.read(mangaDetailWithCallbackProvider(manga.id));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          mangaId: manga.id,
          initialPage: startPage,
        ),
      ),
    );
  }

  void _toggleFavorite(Manga manga) {
    ref.read(mangaActionsProvider.notifier).toggleFavorite(
          manga.id,
          !manga.isFavorite,
        );
  }
}

// 网格配置类
class GridConfig {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const GridConfig({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}

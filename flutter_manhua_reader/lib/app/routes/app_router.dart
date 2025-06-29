import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/library/library_page.dart';
import '../../presentation/pages/bookshelf/bookshelf_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/reader/reader_page.dart';
import '../../presentation/pages/manga_detail/manga_detail_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/widgets/layout/main_layout.dart';

part 'app_router.g.dart';

// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String library = '/library';
  static const String bookshelf = '/bookshelf';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String mangaDetail = '/manga/:mangaId';
  static const String reader = '/reader/:mangaId';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // 主布局路由
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // 首页
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          
          // 漫画库
          GoRoute(
            path: AppRoutes.library,
            name: 'library',
            builder: (context, state) => const LibraryPage(),
          ),
          
          // 书架
          GoRoute(
            path: AppRoutes.bookshelf,
            name: 'bookshelf',
            builder: (context, state) => const BookshelfPage(),
          ),
          
          // 设置
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          
          // 搜索
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'] ?? '';
              return SearchPage(initialQuery: query);
            },
          ),
          
          // 漫画详情
          GoRoute(
            path: AppRoutes.mangaDetail,
            name: 'mangaDetail',
            builder: (context, state) {
              final mangaId = state.pathParameters['mangaId']!;
              return MangaDetailPage(mangaId: mangaId);
            },
          ),
        ],
      ),
      
      // 阅读器（全屏）
      GoRoute(
        path: AppRoutes.reader,
        name: 'reader',
        builder: (context, state) {
          final mangaId = state.pathParameters['mangaId']!;
          final pageIndex = int.tryParse(
            state.uri.queryParameters['page'] ?? '0',
          ) ?? 0;
          
          return ReaderPage(
            mangaId: mangaId,
            initialPage: pageIndex,
          );
        },
      ),
    ],
    
    // 错误页面
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '页面未找到',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '请求的页面不存在或已被移除',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// 路由扩展方法
extension AppRouterExtension on GoRouter {
  void goToMangaDetail(String mangaId) {
    go('/manga/$mangaId');
  }
  
  void goToReader(String mangaId, {int? page}) {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    
    final uri = Uri(path: '/reader/$mangaId', queryParameters: queryParams);
    go(uri.toString());
  }
  
  void goToSearch({String? query}) {
    final queryParams = query != null ? {'q': query} : <String, String>{};
    final uri = Uri(path: AppRoutes.search, queryParameters: queryParams);
    go(uri.toString());
  }
}

// 导航助手类
class NavigationHelper {
  static void goToMangaDetail(BuildContext context, String mangaId) {
    context.go('/manga/$mangaId');
  }
  
  static void goToReader(
    BuildContext context,
    String mangaId, {
    int? page,
  }) {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    
    final uri = Uri(path: '/reader/$mangaId', queryParameters: queryParams);
    context.go(uri.toString());
  }
  
  static void goToSearch(BuildContext context, {String? query}) {
    final queryParams = query != null ? {'q': query} : <String, String>{};
    final uri = Uri(path: AppRoutes.search, queryParameters: queryParams);
    context.go(uri.toString());
  }
  
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}
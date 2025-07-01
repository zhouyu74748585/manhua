import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_router.dart';
import '../common/adaptive_scaffold.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return AdaptiveScaffold(
      currentLocation: currentLocation,
      body: child,
      destinations: _getDestinations(),
      onDestinationSelected: (index) {
        final destination = _getDestinations()[index];
        context.go(destination.route);
      },
    );
  }

  List<AppNavigationDestination> _getDestinations() {
    return [
      const AppNavigationDestination(
        route: AppRoutes.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: '首页',
      ),
      const AppNavigationDestination(
        route: AppRoutes.bookshelf,
        icon: Icons.bookmarks_outlined,
        selectedIcon: Icons.bookmarks,
        label: '书架',
      ),
      const AppNavigationDestination(
        route: AppRoutes.library,
        icon: Icons.library_books_outlined,
        selectedIcon: Icons.library_books,
        label: '漫画库',
      ),
      const AppNavigationDestination(
        route: AppRoutes.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: '设置',
      ),
    ];
  }
}

class AppNavigationDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavigationDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

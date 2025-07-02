import 'package:flutter/material.dart';

import '../../../core/utils/platform_utils.dart';
import '../layout/main_layout.dart';

class AdaptiveScaffold extends StatelessWidget {
  final String currentLocation;
  final Widget body;
  final List<AppNavigationDestination> destinations;
  final Function(int) onDestinationSelected;

  const AdaptiveScaffold({
    super.key,
    required this.currentLocation,
    required this.body,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedIndex = _getSelectedIndex();

    // 桌面端使用侧边栏导航
    if (PlatformUtils.shouldShowSidebar(screenWidth)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations.map<NavigationRailDestination>((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: Text(dest.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // 移动端使用底部导航栏
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map<NavigationDestination>((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }

  int _getSelectedIndex() {
    for (int i = 0; i < destinations.length; i++) {
      if (currentLocation.startsWith(destinations[i].route)) {
        return i;
      }
    }
    return 0;
  }
}

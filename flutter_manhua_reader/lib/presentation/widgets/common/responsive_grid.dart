import 'package:flutter/material.dart';

import '../../../core/utils/platform_utils.dart';
import '../../../core/constants/app_constants.dart';

class ResponsiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double? aspectRatio;
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? maxItems;

  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.aspectRatio,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = PlatformUtils.getResponsiveColumns(screenWidth);
    final displayItems =
        maxItems != null ? items.take(maxItems!).toList() : items;

    if (displayItems.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverPadding(
      padding: padding ??
          EdgeInsets.all(
            PlatformUtils.getResponsivePadding(screenWidth),
          ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: aspectRatio ?? AppConstants.gridAspectRatio,
          mainAxisSpacing: mainAxisSpacing ?? 16.0,
          crossAxisSpacing: crossAxisSpacing ?? 16.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= displayItems.length) return null;
            return itemBuilder(context, displayItems[index]);
          },
          childCount: displayItems.length,
        ),
      ),
    );
  }
}

// 固定网格组件（非Sliver版本）
class ResponsiveGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double? aspectRatio;
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? maxItems;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.aspectRatio,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.maxItems,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = PlatformUtils.getResponsiveColumns(screenWidth);
    final displayItems =
        maxItems != null ? items.take(maxItems!).toList() : items;

    if (displayItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      padding: padding ??
          EdgeInsets.all(
            PlatformUtils.getResponsivePadding(screenWidth),
          ),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio ?? AppConstants.gridAspectRatio,
        mainAxisSpacing: mainAxisSpacing ?? 16.0,
        crossAxisSpacing: crossAxisSpacing ?? 16.0,
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, displayItems[index]);
      },
    );
  }
}

// 瀑布流网格组件
class ResponsiveStaggeredGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? maxItems;

  const ResponsiveStaggeredGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = PlatformUtils.getResponsiveColumns(screenWidth);
    final displayItems =
        maxItems != null ? items.take(maxItems!).toList() : items;

    if (displayItems.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    // 简化的瀑布流实现，使用普通网格
    return SliverPadding(
      padding: padding ??
          EdgeInsets.all(
            PlatformUtils.getResponsivePadding(screenWidth),
          ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.8, // 瀑布流使用不同的宽高比
          mainAxisSpacing: mainAxisSpacing ?? 16.0,
          crossAxisSpacing: crossAxisSpacing ?? 16.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= displayItems.length) return null;
            return itemBuilder(context, displayItems[index]);
          },
          childCount: displayItems.length,
        ),
      ),
    );
  }
}

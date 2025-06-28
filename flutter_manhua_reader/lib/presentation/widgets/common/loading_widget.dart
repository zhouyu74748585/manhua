import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// 列表加载组件
class ListLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  
  const ListLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildShimmer(60, 60, borderRadius: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildShimmer(double.infinity, 16),
                        const SizedBox(height: 8),
                        _buildShimmer(120, 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildShimmer(double width, double height, {double? borderRadius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
    );
  }
}

// 网格加载组件
class GridLoadingWidget extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;
  
  const GridLoadingWidget({
    super.key,
    this.itemCount = 8,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.7,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildShimmer(double.infinity, double.infinity, borderRadius: 8),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmer(double.infinity, 14),
                      const SizedBox(height: 4),
                      _buildShimmer(80, 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildShimmer(double width, double height, {double? borderRadius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
    );
  }
}

// 页面加载组件
class PageLoadingWidget extends StatelessWidget {
  final String? title;
  final String? message;
  
  const PageLoadingWidget({
    super.key,
    this.title,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: LoadingWidget(message: message ?? '加载中...'),
    );
  }
}
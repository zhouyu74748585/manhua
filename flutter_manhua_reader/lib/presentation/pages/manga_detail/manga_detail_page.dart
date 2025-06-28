import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaDetailPage extends ConsumerWidget {
  final String mangaId;
  
  const MangaDetailPage({
    super.key,
    required this.mangaId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 收藏/取消收藏
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 分享
            },
          ),
        ],
      ),
      body: Center(
        child: Text('漫画详情页面 - ID: $mangaId\n待实现'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 开始阅读
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('开始阅读'),
      ),
    );
  }
}
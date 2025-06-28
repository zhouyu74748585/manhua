import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String mangaId;
  final String chapterId;
  
  const ReaderPage({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });
  
  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _isFullscreen = false;
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    _enterFullscreen();
  }
  
  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }
  
  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() {
      _isFullscreen = true;
    });
  }
  
  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFullscreen = false;
    });
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls ? AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        title: Text('第${widget.chapterId}话'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 阅读设置
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: 添加书签
            },
          ),
        ],
      ) : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Center(
          child: Text(
            '阅读器页面\n漫画ID: ${widget.mangaId}\n章节ID: ${widget.chapterId}\n\n点击切换控制栏\n待实现',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      bottomNavigationBar: _showControls ? Container(
        color: Colors.black.withOpacity(0.7),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () {
                // TODO: 上一章
              },
            ),
            Expanded(
              child: Slider(
                value: 0.5,
                onChanged: (value) {
                  // TODO: 进度控制
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {
                // TODO: 下一章
              },
            ),
          ],
        ),
      ) : null,
    );
  }
}
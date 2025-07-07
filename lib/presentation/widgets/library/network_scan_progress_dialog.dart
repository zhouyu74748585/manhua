import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/network/network_scan_queue_manager.dart';
import '../../../data/models/library.dart';
import '../../../data/models/network_config.dart';

/// 网络扫描进度对话框
class NetworkScanProgressDialog extends ConsumerStatefulWidget {
  final MangaLibrary library;
  final String taskId;

  const NetworkScanProgressDialog({
    super.key,
    required this.library,
    required this.taskId,
  });

  @override
  ConsumerState<NetworkScanProgressDialog> createState() =>
      _NetworkScanProgressDialogState();
}

class _NetworkScanProgressDialogState
    extends ConsumerState<NetworkScanProgressDialog> {
  late StreamSubscription<NetworkScanProgress> _progressSubscription;
  NetworkScanProgress? _currentProgress;
  bool _isCompleted = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _listenToProgress();
    _startScan();
  }

  @override
  void dispose() {
    _progressSubscription.cancel();
    super.dispose();
  }

  void _listenToProgress() {
    _progressSubscription = NetworkScanQueueManager.instance.progressStream
        .where((progress) => progress.taskId == widget.taskId)
        .listen((progress) {
      if (mounted) {
        setState(() {
          _currentProgress = progress;
          if (progress.status == NetworkScanStatus.completed) {
            _isCompleted = true;
          } else if (progress.status == NetworkScanStatus.cancelled) {
            _isCancelled = true;
          }
        });

        // 如果扫描完成或失败，延迟关闭对话框
        if (progress.status == NetworkScanStatus.completed ||
            progress.status == NetworkScanStatus.failed) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop(progress);
            }
          });
        }
      }
    });
  }

  void _startScan() async {
    try {
      // 获取网络配置
      NetworkConfig config;
      if (widget.library.settings.networkConfig != null) {
        config = widget.library.settings.networkConfig!;
      } else {
        // 兼容旧版本：从path中解析网络配置
        config = NetworkConfig.fromConnectionString(widget.library.path);
      }

      // 验证配置是否有效
      if (!config.isValid) {
        setState(() {
          _currentProgress = NetworkScanProgress(
            taskId: widget.taskId,
            libraryId: widget.library.id,
            status: NetworkScanStatus.failed,
            message: '网络配置无效，请检查连接设置',
          );
        });
        return;
      }

      // 启动扫描，传递任务ID以确保一致性
      await NetworkScanQueueManager.instance.startScan(
        widget.library,
        config,
        taskId: widget.taskId,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentProgress = NetworkScanProgress(
            taskId: widget.taskId,
            libraryId: widget.library.id,
            status: NetworkScanStatus.failed,
            message: '启动扫描失败: $e',
          );
        });
      }
    }
  }

  void _cancelScan() {
    setState(() {
      _isCancelled = true;
    });
    NetworkScanQueueManager.instance.cancelScan(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentProgress;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.cloud_download, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '扫描网络漫画库',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 库信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.library.type == LibraryType.network
                        ? Icons.cloud
                        : Icons.folder,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.library.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          widget.library.path,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 进度指示器
            if (progress != null) ...[
              // 状态指示器
              Row(
                children: [
                  _buildStatusIcon(progress.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusText(progress.status),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(progress.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 进度条（仅在扫描中显示）
              if (progress.status == NetworkScanStatus.scanning) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
              ],

              // 扫描信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '扫描状态',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (progress.scannedCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 16,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '已发现 ${progress.scannedCount} 个漫画',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // 初始状态
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('正在初始化扫描...'),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isCompleted &&
            !_isCancelled &&
            progress?.status != NetworkScanStatus.failed)
          TextButton(
            onPressed: _cancelScan,
            child: const Text('取消'),
          ),
        if (_isCompleted ||
            _isCancelled ||
            progress?.status == NetworkScanStatus.failed)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(progress),
            child: const Text('确定'),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(NetworkScanStatus status) {
    switch (status) {
      case NetworkScanStatus.scanning:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case NetworkScanStatus.completed:
        return Icon(Icons.check_circle, color: Colors.green[600], size: 20);
      case NetworkScanStatus.failed:
        return Icon(Icons.error, color: Colors.red[600], size: 20);
      case NetworkScanStatus.cancelled:
        return Icon(Icons.cancel, color: Colors.orange[600], size: 20);
    }
  }

  String _getStatusText(NetworkScanStatus status) {
    switch (status) {
      case NetworkScanStatus.scanning:
        return '正在扫描...';
      case NetworkScanStatus.completed:
        return '扫描完成';
      case NetworkScanStatus.failed:
        return '扫描失败';
      case NetworkScanStatus.cancelled:
        return '扫描已取消';
    }
  }

  Color _getStatusColor(NetworkScanStatus status) {
    switch (status) {
      case NetworkScanStatus.scanning:
        return Colors.blue;
      case NetworkScanStatus.completed:
        return Colors.green;
      case NetworkScanStatus.failed:
        return Colors.red;
      case NetworkScanStatus.cancelled:
        return Colors.orange;
    }
  }
}

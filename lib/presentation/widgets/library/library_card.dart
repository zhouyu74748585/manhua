import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/network/network_scan_queue_manager.dart';
import '../../../data/models/library.dart';
import 'network_scan_progress_dialog.dart';
import 'privacy_access_handler.dart';

class LibraryCard extends ConsumerStatefulWidget {
  final MangaLibrary library;
  final bool isScanning;
  final Function(bool) onToggleEnabled;
  final VoidCallback onScan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSettings;
  final VoidCallback? onPrivacySettings;
  final VoidCallback? onAccessGranted;
  final VoidCallback? onSync;

  const LibraryCard({
    super.key,
    required this.library,
    required this.isScanning,
    required this.onToggleEnabled,
    required this.onScan,
    required this.onEdit,
    required this.onDelete,
    this.onSettings,
    this.onPrivacySettings,
    this.onAccessGranted,
    this.onSync,
  });

  @override
  ConsumerState<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends ConsumerState<LibraryCard> {
  String? _currentScanTaskId;

  @override
  void initState() {
    super.initState();
    _listenToScanProgress();
  }

  void _listenToScanProgress() {
    NetworkScanQueueManager.instance.progressStream.listen((progress) {
      if (mounted &&
          _currentScanTaskId != null &&
          progress.taskId == _currentScanTaskId) {
        // 进度更新会通过对话框显示，这里不需要额外处理
      }
    });
  }

  Future<void> _handleScan() async {
    // 如果是网络库，显示进度对话框
    if (widget.library.type == LibraryType.network) {
      // 生成任务ID
      final taskId =
          'scan_${widget.library.id}_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _currentScanTaskId = taskId;
      });

      // 显示进度对话框
      final result = await showDialog<NetworkScanProgress>(
        context: context,
        barrierDismissible: false,
        builder: (context) => NetworkScanProgressDialog(
          library: widget.library,
          taskId: taskId,
        ),
      );

      setState(() {
        _currentScanTaskId = null;
      });

      // 如果扫描成功，调用回调
      if (result?.status == NetworkScanStatus.completed) {
        widget.onScan();
      }
    } else {
      // 本地库直接调用扫描
      widget.onScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (widget.library.isPrivate) {
            // 检查隐私访问权限
            await PrivacyAccessHandler.checkLibraryAccess(
              context: context,
              library: widget.library,
              onAccessGranted: () {
                widget.onAccessGranted?.call();
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.library.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.library.path,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 启用/禁用开关
                  Switch(
                    value: widget.library.isEnabled,
                    onChanged: widget.onToggleEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 信息行
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: _getTypeLabel(widget.library.type),
                    color: _getTypeColor(widget.library.type),
                  ),
                  _buildInfoChip(
                    icon: Icons.book,
                    label: '${widget.library.mangaCount} 本',
                    color: Colors.blue,
                  ),
                  if (widget.library.isPrivate)
                    _buildInfoChip(
                      icon: Icons.lock,
                      label: '隐私保护中',
                      color: Colors.red,
                    ),
                  if (widget.library.lastScanAt != null)
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: _formatLastScan(widget.library.lastScanAt!),
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 操作按钮行
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  // 扫描按钮
                  ElevatedButton.icon(
                    onPressed: widget.library.isEnabled && !widget.isScanning
                        ? _handleScan
                        : null,
                    icon: widget.isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(widget.isScanning ? '扫描中...' : '扫描'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  // 编辑按钮
                  OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('编辑'),
                  ),

                  // 同步按钮
                  if (widget.onSync != null)
                    OutlinedButton.icon(
                      onPressed: widget.library.isEnabled
                          ? widget.onSync
                          : null,
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('同步'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),

                  // 设置按钮
                  if (widget.onSettings != null)
                    OutlinedButton.icon(
                      onPressed: widget.onSettings,
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('设置'),
                    ),

                  // 隐私设置按钮
                  if (widget.onPrivacySettings != null)
                    OutlinedButton.icon(
                      onPressed: widget.onPrivacySettings,
                      icon: Icon(
                        widget.library.isPrivate
                            ? Icons.lock
                            : Icons.lock_open,
                        size: 16,
                      ),
                      label: widget.library.isPrivate
                          ? const Text('公开')
                          : const Text('锁定'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.library.isPrivate
                            ? Colors.red
                            : null,
                      ),
                    ),

                  // 删除按钮
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: '删除漫画库',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(LibraryType type) {
    switch (type) {
      case LibraryType.local:
        return '本地';
      case LibraryType.network:
        return '网络';
      case LibraryType.cloud:
        return '云端';
    }
  }

  Color _getTypeColor(LibraryType type) {
    switch (type) {
      case LibraryType.local:
        return Colors.green;
      case LibraryType.network:
        return Colors.orange;
      case LibraryType.cloud:
        return Colors.purple;
    }
  }

  String _formatLastScan(DateTime lastScan) {
    final now = DateTime.now();
    final difference = now.difference(lastScan);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${lastScan.month}/${lastScan.day}';
    }
  }
}

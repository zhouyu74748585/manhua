import 'package:flutter/material.dart';

import '../../../data/models/library.dart';
import 'privacy_access_handler.dart';

class LibraryCard extends StatelessWidget {
  final MangaLibrary library;
  final bool isScanning;
  final Function(bool) onToggleEnabled;
  final VoidCallback onScan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSettings;
  final VoidCallback? onPrivacySettings;
  final VoidCallback? onTap;
  final VoidCallback? onAccessGranted;

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
    this.onTap,
    this.onAccessGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (library.isPrivate) {
            // 检查隐私访问权限
            await PrivacyAccessHandler.checkLibraryAccess(
              context: context,
              library: library,
              onAccessGranted: () {
                onAccessGranted?.call();
                onTap?.call();
              },
            );
          } else {
            onTap?.call();
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
                          library.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          library.path,
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
                    value: library.isEnabled,
                    onChanged: onToggleEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 信息行
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: _getTypeLabel(library.type),
                    color: _getTypeColor(library.type),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.book,
                    label: '${library.mangaCount} 本',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  if (library.isPrivate)
                    _buildInfoChip(
                      icon: Icons.lock,
                      label: '隐私保护',
                      color: Colors.red,
                    ),
                  const SizedBox(width: 8),
                  if (library.lastScanAt != null)
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: _formatLastScan(library.lastScanAt!),
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 操作按钮行
              Row(
                children: [
                  // 扫描按钮
                  ElevatedButton.icon(
                    onPressed: library.isEnabled && !isScanning ? onScan : null,
                    icon: isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(isScanning ? '扫描中...' : '扫描'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 编辑按钮
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('编辑'),
                  ),
                  const SizedBox(width: 8),

                  // 设置按钮
                  if (onSettings != null)
                    OutlinedButton.icon(
                      onPressed: onSettings,
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('设置'),
                    ),
                  const SizedBox(width: 8),

                  // 隐私设置按钮
                  if (onPrivacySettings != null)
                    OutlinedButton.icon(
                      onPressed: onPrivacySettings,
                      icon: Icon(
                        library.isPrivate ? Icons.lock : Icons.lock_open,
                        size: 16,
                      ),
                      label: const Text('隐私'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: library.isPrivate ? Colors.red : null,
                      ),
                    ),
                  const Spacer(),

                  // 删除按钮
                  IconButton(
                    onPressed: onDelete,
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

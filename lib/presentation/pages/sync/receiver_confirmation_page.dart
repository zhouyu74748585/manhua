import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/sync/device_info.dart';
import '../../providers/sync_providers.dart';

/// 接收同步请求确认页面
class ReceiverConfirmationPage extends ConsumerStatefulWidget {
  final DeviceInfo sourceDevice;
  final List<Library> requestedLibraries;
  final SyncRequestType requestType;
  final String requestId;

  const ReceiverConfirmationPage({
    super.key,
    required this.sourceDevice,
    required this.requestedLibraries,
    required this.requestType,
    required this.requestId,
  });

  @override
  ConsumerState<ReceiverConfirmationPage> createState() =>
      _ReceiverConfirmationPageState();
}

class _ReceiverConfirmationPageState
    extends ConsumerState<ReceiverConfirmationPage> {
  bool _isProcessing = false;
  Set<String> _selectedLibraryIds = {};

  @override
  void initState() {
    super.initState();
    // 默认选择所有请求的库
    _selectedLibraryIds =
        widget.requestedLibraries.map((lib) => lib.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步请求确认'),
        automaticallyImplyLeading: false,
      ),
      body: _isProcessing ? _buildProcessingView() : _buildConfirmationView(),
      bottomNavigationBar: _isProcessing ? null : _buildActionButtons(),
    );
  }

  Widget _buildProcessingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在处理同步请求...'),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 请求信息卡片
          _buildRequestInfoCard(),

          const SizedBox(height: 16),

          // 设备信息卡片
          _buildDeviceInfoCard(),

          const SizedBox(height: 16),

          // 同步内容选择
          _buildSyncContentCard(),

          const SizedBox(height: 16),

          // 安全提示
          _buildSecurityWarning(),
        ],
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRequestTypeIcon(),
                  color: _getRequestTypeColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  _getRequestTypeTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRequestDescription(),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '来自 "${widget.sourceDevice.name}" 的同步请求',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '源设备信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(_getDeviceIcon(widget.sourceDevice.platform)),
              title: Text(widget.sourceDevice.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('平台: ${widget.sourceDevice.platform}'),
                  Text('IP: ${widget.sourceDevice.ipAddress}'),
                  if (widget.sourceDevice.lastSeen != null)
                    Text(
                        '最后活跃: ${_formatLastSeen(widget.sourceDevice.lastSeen!)}'),
                ],
              ),
              trailing: widget.sourceDevice.isTrusted
                  ? const Icon(Icons.verified, color: Colors.green)
                  : const Icon(Icons.warning, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同步内容选择',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '选择要同步的漫画库',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ...widget.requestedLibraries.map((library) {
              return CheckboxListTile(
                title: Text(library.name),
                subtitle: Text('${library.mangaCount} 本漫画'),
                value: _selectedLibraryIds.contains(library.id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedLibraryIds.add(library.id);
                    } else {
                      _selectedLibraryIds.remove(library.id);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityWarning() {
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '安全提示',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• 请确认源设备是您信任的设备\n'
              '• 同步将会覆盖本地的相关数据\n'
              '• 建议在同步前备份重要数据',
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 12),
            if (!widget.sourceDevice.isTrusted)
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: null,
                  ),
                  const Expanded(
                    child: Text(
                      '信任此设备（下次不再询问）',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _rejectRequest,
              child: const Text('拒绝'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedLibraryIds.isNotEmpty ? _acceptRequest : null,
              child: const Text('接受'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRequestTypeIcon() {
    switch (widget.requestType) {
      case SyncRequestType.librarySync:
        return Icons.library_books;
      case SyncRequestType.progressSync:
        return Icons.sync;
      case SyncRequestType.fullSync:
        return Icons.sync_alt;
    }
  }

  Color _getRequestTypeColor() {
    switch (widget.requestType) {
      case SyncRequestType.librarySync:
        return Colors.blue;
      case SyncRequestType.progressSync:
        return Colors.green;
      case SyncRequestType.fullSync:
        return Colors.purple;
    }
  }

  String _getRequestTypeTitle() {
    switch (widget.requestType) {
      case SyncRequestType.librarySync:
        return '漫画库同步请求';
      case SyncRequestType.progressSync:
        return '阅读进度同步请求';
      case SyncRequestType.fullSync:
        return '完整同步请求';
    }
  }

  String _getRequestDescription() {
    switch (widget.requestType) {
      case SyncRequestType.librarySync:
        return '对方请求同步漫画库数据，包括漫画信息、封面和设置';
      case SyncRequestType.progressSync:
        return '对方请求同步阅读进度，包括当前页面、书签和收藏状态';
      case SyncRequestType.fullSync:
        return '对方请求进行完整同步，包括所有漫画库和阅读进度';
    }
  }

  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.computer;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  void _acceptRequest() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 获取选中的库
      final selectedLibraries = widget.requestedLibraries
          .where((lib) => _selectedLibraryIds.contains(lib.id))
          .toList();

      // 调用同步服务接受请求
      await ref.read(syncCoordinatorProvider).acceptSyncRequest(
            widget.requestId,
            selectedLibraries,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已接受同步请求')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('接受请求失败: $e')),
        );
      }
    }
  }

  void _rejectRequest() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 调用同步服务拒绝请求
      await ref.read(syncCoordinatorProvider).rejectSyncRequest(
            widget.requestId,
          );

      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已拒绝同步请求')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拒绝请求失败: $e')),
        );
      }
    }
  }
}

/// 同步请求类型
enum SyncRequestType {
  librarySync,
  progressSync,
  fullSync,
}

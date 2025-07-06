import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/sync/device_info.dart';
import '../../../data/models/sync/sync_session.dart';
import '../../providers/sync_providers.dart';

/// 同步进度显示页面 - 实时显示同步进度和状态
class SyncProgressPage extends ConsumerStatefulWidget {
  final String sessionId;
  final DeviceInfo targetDevice;

  const SyncProgressPage({
    super.key,
    required this.sessionId,
    required this.targetDevice,
  });

  @override
  ConsumerState<SyncProgressPage> createState() => _SyncProgressPageState();
}

class _SyncProgressPageState extends ConsumerState<SyncProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  bool _isCompleted = false;
  String _currentStatus = '准备同步...';
  double _progress = 0.0;
  int _totalItems = 0;
  int _processedItems = 0;
  String _currentItem = '';
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimationController.repeat(reverse: true);
    _startListeningToProgress();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _startListeningToProgress() {
    // 监听实际的同步进度
    ref.listen<AsyncValue<SyncSession?>>(
      syncSessionProvider(widget.sessionId),
      (previous, next) {
        next.when(
          data: (session) {
            if (session != null) {
              _updateProgressFromSession(session);
            }
          },
          loading: () {
            setState(() {
              _currentStatus = '正在连接设备...';
            });
          },
          error: (error, stack) {
            setState(() {
              _errors.add('同步错误: $error');
              _currentStatus = '同步失败';
            });
          },
        );
      },
    );
  }

  void _updateProgressFromSession(SyncSession session) {
    setState(() {
      _currentStatus = _getStatusText(session.status);
      _totalItems = session.totalItems;
      _processedItems = session.processedItems;
      _progress = session.totalItems > 0
          ? session.processedItems / session.totalItems
          : 0.0;
      _currentItem = session.currentItem ?? '';
      _errors = session.errors.toList();
      _isCompleted = session.status == SyncStatus.completed ||
          session.status == SyncStatus.failed;

      if (_isCompleted) {
        _pulseAnimationController.stop();
      }
    });

    _progressAnimationController.animateTo(_progress);
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return '等待开始...';
      case SyncStatus.inProgress:
        return '正在同步数据...';
      case SyncStatus.completed:
        return '同步完成';
      case SyncStatus.failed:
        return '同步失败';
      case SyncStatus.cancelled:
        return '同步已取消';
      case SyncStatus.conflicted:
        return '存在冲突';
      case SyncStatus.partiallyCompleted:
        return '部分完成';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步进度'),
        leading: _isCompleted
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              )
            : null,
        automaticallyImplyLeading: !_isCompleted,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标设备信息
            _buildDeviceInfoCard(),

            const SizedBox(height: 24),

            // 同步状态卡片
            _buildSyncStatusCard(),

            const SizedBox(height: 24),

            // 进度详情
            _buildProgressDetails(),

            const SizedBox(height: 24),

            // 错误信息（如果有）
            if (_errors.isNotEmpty) _buildErrorSection(),

            const Spacer(),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.devices,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '同步到: ${widget.targetDevice.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      '${widget.targetDevice.ipAddress}:${widget.targetDevice.port}'),
                  Text('会话ID: ${widget.sessionId}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!_isCompleted)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(
                        Icons.sync,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _currentStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 进度条
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('进度: $_processedItems / $_totalItems'),
                    Text('${(_progress * 100).toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnimationController,
                  builder: (context, child) => LinearProgressIndicator(
                    value: _progressAnimationController.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            if (_currentItem.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _currentItem,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同步详情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('会话ID', widget.sessionId),
            _buildDetailRow('目标设备', widget.targetDevice.name),
            _buildDetailRow('开始时间', DateTime.now().toString().substring(0, 19)),
            if (_isCompleted)
              _buildDetailRow(
                  '完成时间', DateTime.now().toString().substring(0, 19)),
            _buildDetailRow('总项目数', _totalItems.toString()),
            _buildDetailRow('已处理', _processedItems.toString()),
            if (_errors.isNotEmpty)
              _buildDetailRow('错误数', _errors.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '错误信息 (${_errors.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_errors.take(3).map((error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $error',
                    style: TextStyle(color: Colors.red[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))),
            if (_errors.length > 3)
              TextButton(
                onPressed: _showAllErrors,
                child: Text('查看全部 ${_errors.length} 个错误'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (_isCompleted) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.check),
              label: const Text('完成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showSyncSummary,
              icon: const Icon(Icons.info),
              label: const Text('查看同步摘要'),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _cancelSync,
          icon: const Icon(Icons.cancel),
          label: const Text('取消同步'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
        ),
      );
    }
  }

  void _showAllErrors() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('所有错误'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _errors.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('${index + 1}. ${_errors[index]}'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSyncSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同步摘要'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('同步会话: ${widget.sessionId}'),
            Text('目标设备: ${widget.targetDevice.name}'),
            Text('总项目数: $_totalItems'),
            Text('成功处理: $_processedItems'),
            Text('错误数量: ${_errors.length}'),
            Text(
                '成功率: ${((_processedItems - _errors.length) / _totalItems * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _cancelSync() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消同步'),
        content: const Text('确定要取消当前同步操作吗？已同步的数据将保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续同步'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
  }
}

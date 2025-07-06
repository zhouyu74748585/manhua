import 'package:flutter/material.dart';

import '../../../core/services/network/network_connection_tester.dart';
import '../../../data/models/network_config.dart';

/// 网络连接测试对话框
class NetworkConnectionTestDialog extends StatefulWidget {
  final NetworkConfig config;

  const NetworkConnectionTestDialog({
    super.key,
    required this.config,
  });

  @override
  State<NetworkConnectionTestDialog> createState() =>
      _NetworkConnectionTestDialogState();
}

class _NetworkConnectionTestDialogState
    extends State<NetworkConnectionTestDialog> {
  bool _isTesting = false;
  NetworkConnectionTestResult? _testResult;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final result = await NetworkConnectionTester.testConnection(
        widget.config,
        timeout: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _testResult = result;
          _isTesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = NetworkConnectionTestResult.failure(
            message: '测试过程中发生错误: $e',
            errorCode: 'TEST_ERROR',
          );
          _isTesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.network_check, color: Colors.blue),
          SizedBox(width: 8),
          Text('网络连接测试'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 配置信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '测试配置',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildConfigRow(
                      '协议', widget.config.protocol.name.toUpperCase()),
                  _buildConfigRow('主机', widget.config.host),
                  _buildConfigRow('端口', (widget.config.port ?? 80).toString()),
                  if (widget.config.username?.isNotEmpty == true)
                    _buildConfigRow('用户名', widget.config.username!),
                  _buildConfigRow('路径', widget.config.remotePath ?? '/'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 测试状态
            if (_isTesting) ...[
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('正在测试连接...'),
                ],
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ] else if (_testResult != null) ...[
              // 测试结果
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.isSuccess
                      ? Colors.green[50]
                      : Colors.red[50],
                  border: Border.all(
                    color: _testResult!.isSuccess
                        ? Colors.green[300]!
                        : Colors.red[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _testResult!.isSuccess
                              ? Icons.check_circle
                              : Icons.error,
                          color: _testResult!.isSuccess
                              ? Colors.green[600]
                              : Colors.red[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResult!.isSuccess ? '连接成功' : '连接失败',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _testResult!.isSuccess
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                        if (_testResult!.responseTime != null)
                          Text(
                            '${_testResult!.responseTime!.inMilliseconds}ms',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testResult!.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_testResult!.errorCode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '错误代码: ${_testResult!.errorCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 建议
              if (!_testResult!.isSuccess) ...[
                const SizedBox(height: 16),
                Text(
                  '解决建议',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: NetworkConnectionTester.getConnectionSuggestions(
                            _testResult!)
                        .map((suggestion) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        if (!_isTesting) ...[
          TextButton(
            onPressed: _startTest,
            child: const Text('重新测试'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_testResult),
            child: const Text('确定'),
          ),
        ],
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

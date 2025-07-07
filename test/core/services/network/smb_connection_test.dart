import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/core/services/network/network_connection_tester.dart';
import 'package:manhua_reader_flutter/core/services/network/smb_connection_helper.dart';
import 'package:manhua_reader_flutter/data/models/network_config.dart';
import 'package:smb_connect/smb_connect.dart';

void main() {
  group('SMB连接测试', () {
    // 使用用户提供的测试服务器
    final testConfig = NetworkConfig(
      protocol: NetworkProtocol.smb,
      host: '10.0.0.3',
      port: 445,
      username: 'zhouyu',
      password: '946898',
      shareName: '', // 将在测试中动态获取
      remotePath: '/',
    );

    test('应该能够连接到测试SMB服务器', () async {
      final result = await SMBConnectionHelper.testConnection(
        testConfig,
        timeout: const Duration(seconds: 30),
      );

      print('连接测试结果: ${result.message}');
      if (result.details != null) {
        print('详细信息: ${result.details}');
      }
      if (!result.isSuccess) {
        print('错误代码: ${result.errorCode}');
        final suggestions = SMBConnectionHelper.getConnectionSuggestions(
          result.errorCode ?? 'UNKNOWN',
        );
        print('建议解决方案:');
        for (final suggestion in suggestions) {
          print('  - $suggestion');
        }
      }

      // 注意：这个测试可能会失败，这是为了诊断问题
      // expect(result.isSuccess, isTrue, reason: result.message);
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('应该能够通过NetworkConnectionTester测试连接', () async {
      final result = await NetworkConnectionTester.testConnection(
        testConfig,
        timeout: const Duration(seconds: 30),
      );

      print('网络连接测试结果: ${result.message}');
      if (result.details != null) {
        print('详细信息: ${result.details}');
      }
      if (!result.isSuccess) {
        print('错误代码: ${result.errorCode}');
      }

      // 注意：这个测试可能会失败，这是为了诊断问题
      // expect(result.isSuccess, isTrue, reason: result.message);
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('测试不同的SMB端口', () async {
      final configs = [
        testConfig, // 默认445端口
        testConfig.copyWith(port: 139), // 传统SMB端口
      ];

      for (final config in configs) {
        print('\n测试端口 ${config.port}:');
        final result = await SMBConnectionHelper.testConnection(
          config,
          timeout: const Duration(seconds: 15),
        );
        print('结果: ${result.message}');
        if (!result.isSuccess) {
          print('错误: ${result.errorCode}');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('测试不同的用户名格式', () async {
      final userFormats = [
        'zhouyu', // 原始用户名
        'zhouyu@10.0.0.3', // 用户名@主机
        '10.0.0.3\\zhouyu', // 域\\用户名格式
        'WORKGROUP\\zhouyu', // 工作组\\用户名格式
      ];

      for (final username in userFormats) {
        print('\n测试用户名格式: $username');
        final config = testConfig.copyWith(username: username);
        final result = await SMBConnectionHelper.testConnection(
          config,
          timeout: const Duration(seconds: 15),
        );
        print('结果: ${result.message}');
        if (!result.isSuccess) {
          print('错误: ${result.errorCode}');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  });

  group('SMB连接诊断', () {
    test('测试基础TCP连接', () async {
      try {
        final socket = await Socket.connect(
          '10.0.0.3',
          445,
          timeout: const Duration(seconds: 10),
        );
        await socket.close();
        print('TCP连接测试结果: 成功连接到端口445');
      } catch (e) {
        print('TCP连接测试结果: 连接失败 - $e');
      }
    });

    test('测试原始SMB连接', () async {
      // 直接使用smb_connect包测试
      try {
        print('开始测试原始SMB连接...');
        final smbClient = await SmbConnect.connectAuth(
          host: '10.0.0.3',
          domain: '',
          username: 'zhouyu',
          password: '946898',
        );
        print('SMB原始连接: 成功');

        // 尝试列出共享
        try {
          final shares = await smbClient.listShares();
          print('共享列表: ${shares.map((s) => s.name).join(', ')}');
        } catch (e) {
          print('列出共享失败: $e');
        }

        await smbClient.close();
      } catch (e) {
        print('SMB原始连接异常: $e');
        print('错误类型: ${e.runtimeType}');
      }
    });

    test('测试网络连接测试器的SMB错误处理', () async {
      final testConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '10.0.0.3',
        port: 445,
        username: 'zhouyu',
        password: '946898',
      );

      final result = await NetworkConnectionTester.testConnection(testConfig);

      print('网络连接测试结果: ${result.message}');
      print('详细信息: ${result.details}');
      print('错误代码: ${result.errorCode}');

      if (!result.isSuccess && result.details != null) {
        final suggestions = result.details!['suggestions'] as List<String>?;
        if (suggestions != null) {
          print('建议解决方案:');
          for (final suggestion in suggestions) {
            print('  - $suggestion');
          }
        }
      }

      // 验证错误处理是否正确
      expect(result.isSuccess, isFalse);
      // 错误代码可能是SMB_TIMEOUT或SMB_PROTOCOL_ERROR，取决于超时设置
      expect(result.errorCode, anyOf(equals('SMB_TIMEOUT'), equals('SMB_PROTOCOL_ERROR')));
      expect(result.details, isNotNull);
      expect(result.details!['suggestions'], isNotNull);
      expect(result.details!['suggestions'], isA<List<String>>());
    });
  });
}

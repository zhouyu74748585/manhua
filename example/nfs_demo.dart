import 'dart:io';

import '../lib/core/services/network/nfs_file_system.dart';
import '../lib/data/models/network_config.dart';

/// NFS文件系统演示
/// 
/// 这个演示展示了如何使用新的真实NFS实现
/// 注意：需要真实的NFS服务器环境才能完全测试
void main() async {
  print('=== NFS文件系统真实实现演示 ===\n');

  // 创建NFS配置
  final config = NetworkConfig(
    protocol: NetworkProtocol.nfs,
    host: 'localhost',  // 替换为真实的NFS服务器地址
    port: 2049,         // NFS默认端口
    remotePath: '/shared',  // NFS共享路径
    username: 'user',   // 可选的用户名
    password: 'pass',   // 可选的密码
  );

  // 创建NFS文件系统实例
  final nfsFileSystem = NFSFileSystem(config);

  try {
    print('1. 测试主机连通性...');
    final pingResult = await nfsFileSystem.ping();
    print('   Ping结果: ${pingResult ? "成功" : "失败"}\n');

    print('2. 尝试连接NFS服务器...');
    try {
      await nfsFileSystem.connect();
      print('   连接成功！\n');

      print('3. 列出根目录内容...');
      final files = await nfsFileSystem.listDirectory('/');
      if (files.isNotEmpty) {
        print('   找到 ${files.length} 个文件/目录:');
        for (final file in files.take(10)) {  // 只显示前10个
          final type = file.isDirectory ? '[目录]' : '[文件]';
          final size = file.isDirectory ? '' : ' (${file.size} bytes)';
          print('   $type ${file.name}$size');
        }
        if (files.length > 10) {
          print('   ... 还有 ${files.length - 10} 个项目');
        }
      } else {
        print('   目录为空');
      }
      print('');

      print('4. 测试文件操作...');
      
      // 测试文件存在性检查
      if (files.isNotEmpty) {
        final firstFile = files.first;
        print('   检查文件存在性: ${firstFile.name}');
        final exists = await nfsFileSystem.exists(firstFile.path);
        print('   结果: ${exists ? "存在" : "不存在"}\n');

        // 获取文件信息
        if (exists) {
          print('   获取文件详细信息...');
          final fileInfo = await nfsFileSystem.getFileInfo(firstFile.path);
          if (fileInfo != null) {
            print('   名称: ${fileInfo.name}');
            print('   路径: ${fileInfo.path}');
            print('   类型: ${fileInfo.isDirectory ? "目录" : "文件"}');
            print('   大小: ${fileInfo.size} bytes');
            print('   修改时间: ${fileInfo.lastModified}');
          }
        }
      }

      print('\n5. 断开连接...');
      await nfsFileSystem.disconnect();
      print('   已断开连接');

    } catch (e) {
      print('   连接失败: $e');
      print('   这是正常的，因为需要真实的NFS服务器环境');
    }

  } catch (e) {
    print('演示过程中发生错误: $e');
  }

  print('\n=== 演示完成 ===');
  print('\n注意事项:');
  print('1. 这个演示需要真实的NFS服务器才能完全工作');
  print('2. 在生产环境中，请确保NFS服务器已正确配置');
  print('3. 某些操作可能需要管理员权限');
  print('4. NFS实现现在使用真实的系统级挂载，不再返回模拟数据');
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'network_file_system.dart';

/// 简单的FTP文件系统实现
/// 注意：这是一个基础实现，仅支持基本的FTP操作
class FTPFileSystem extends NetworkFileSystem {
  Socket? _controlSocket;
  bool _isConnected = false;
  String _currentDirectory = '/';

  FTPFileSystem(super.config);

  @override
  Future<void> connect() async {
    try {
      // 连接到FTP服务器
      _controlSocket = await Socket.connect(
        config.host,
        config.port ?? 21,
        timeout: Duration(seconds: config.timeout),
      );

      // 读取欢迎消息
      final welcomeResponse = await _readResponse();
      if (!welcomeResponse.startsWith('220')) {
        throw NetworkFileSystemException('FTP服务器连接失败: $welcomeResponse');
      }

      // 发送用户名
      await _sendCommand('USER ${config.username}');
      final userResponse = await _readResponse();

      if (userResponse.startsWith('331')) {
        // 需要密码
        await _sendCommand('PASS ${config.password}');
        final passResponse = await _readResponse();

        if (!passResponse.startsWith('230')) {
          throw NetworkAuthenticationException(details: passResponse);
        }
      } else if (!userResponse.startsWith('230')) {
        throw NetworkAuthenticationException(details: userResponse);
      }

      // 设置二进制模式
      await _sendCommand('TYPE I');
      await _readResponse();

      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      if (e is SocketException) {
        throw NetworkConnectionTimeoutException(config.host,
            details: e.toString());
      } else if (e is NetworkAuthenticationException) {
        rethrow;
      } else {
        throw NetworkFileSystemException('FTP连接失败', originalError: e);
      }
    }
  }

  @override
  Future<void> disconnect() async {
    if (_controlSocket != null) {
      try {
        await _sendCommand('QUIT');
        await _readResponse();
      } catch (e) {
        // 忽略断开连接时的错误
      }
      await _controlSocket!.close();
      _controlSocket = null;
    }
    _isConnected = false;
  }

  @override
  Future<bool> ping() async {
    if (!_isConnected || _controlSocket == null) return false;

    try {
      await _sendCommand('NOOP');
      final response = await _readResponse();
      return response.startsWith('200');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<NetworkFileInfo>> listDirectory([String path = '/']) async {
    _ensureConnected();

    try {
      // 切换到指定目录
      if (path != _currentDirectory) {
        await _sendCommand('CWD $path');
        final response = await _readResponse();
        if (!response.startsWith('250')) {
          throw NetworkFileNotFoundException(path);
        }
        _currentDirectory = path;
      }

      // 进入被动模式
      final dataSocket = await _enterPassiveMode();

      // 发送LIST命令
      await _sendCommand('LIST');
      final listResponse = await _readResponse();
      if (!listResponse.startsWith('150') && !listResponse.startsWith('125')) {
        await dataSocket.close();
        throw NetworkFileSystemException('列出目录失败: $listResponse');
      }

      // 读取目录列表
      final listData = await _readDataFromSocket(dataSocket);
      await dataSocket.close();

      // 读取完成响应
      final completeResponse = await _readResponse();
      if (!completeResponse.startsWith('226')) {
        throw NetworkFileSystemException('列出目录完成失败: $completeResponse');
      }

      // 解析目录列表
      return _parseDirectoryListing(listData, path);
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('列出目录失败: $path', originalError: e);
    }
  }

  @override
  Future<bool> exists(String path) async {
    try {
      await getFileInfo(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NetworkFileInfo?> getFileInfo(String path) async {
    _ensureConnected();

    try {
      final parentPath = path.substring(0, path.lastIndexOf('/'));
      final fileName = path.substring(path.lastIndexOf('/') + 1);

      final files = await listDirectory(parentPath.isEmpty ? '/' : parentPath);
      return files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw NetworkFileNotFoundException(path),
      );
    } catch (e) {
      if (e is NetworkFileNotFoundException) rethrow;
      return null;
    }
  }

  @override
  Future<Uint8List> downloadFile(String path) async {
    _ensureConnected();

    try {
      // 进入被动模式
      final dataSocket = await _enterPassiveMode();

      // 发送RETR命令
      await _sendCommand('RETR $path');
      final retrResponse = await _readResponse();
      if (!retrResponse.startsWith('150') && !retrResponse.startsWith('125')) {
        await dataSocket.close();
        if (retrResponse.contains('550')) {
          throw NetworkFileNotFoundException(path);
        }
        throw NetworkFileSystemException('下载文件失败: $retrResponse');
      }

      // 读取文件数据
      final fileData = await _readDataFromSocket(dataSocket);
      await dataSocket.close();

      // 读取完成响应
      final completeResponse = await _readResponse();
      if (!completeResponse.startsWith('226')) {
        throw NetworkFileSystemException('下载文件完成失败: $completeResponse');
      }

      return Uint8List.fromList(fileData);
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('下载文件失败: $path', originalError: e);
    }
  }

  @override
  Future<void> downloadFileToLocal(
    String remotePath,
    String localPath, {
    Function(int downloaded, int total)? onProgress,
  }) async {
    final data = await downloadFile(remotePath);
    final file = File(localPath);
    await file.writeAsBytes(data);
    onProgress?.call(data.length, data.length);
  }

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    Function(int uploaded, int total)? onProgress,
  }) async {
    // FTP上传实现较复杂，暂时抛出未实现异常
    throw NetworkFileSystemException('FTP上传功能暂未实现');
  }

  @override
  Future<void> createDirectory(String path) async {
    _ensureConnected();

    try {
      await _sendCommand('MKD $path');
      final response = await _readResponse();
      if (!response.startsWith('257')) {
        throw NetworkFileSystemException('创建目录失败: $response');
      }
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('创建目录失败: $path', originalError: e);
    }
  }

  @override
  Future<void> delete(String path) async {
    _ensureConnected();

    try {
      // 尝试删除文件
      await _sendCommand('DELE $path');
      final response = await _readResponse();
      if (!response.startsWith('250')) {
        // 如果删除文件失败，尝试删除目录
        await _sendCommand('RMD $path');
        final rmdResponse = await _readResponse();
        if (!rmdResponse.startsWith('250')) {
          throw NetworkFileSystemException('删除失败: $rmdResponse');
        }
      }
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('删除失败: $path', originalError: e);
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    _ensureConnected();

    try {
      await _sendCommand('RNFR $oldPath');
      final rnfrResponse = await _readResponse();
      if (!rnfrResponse.startsWith('350')) {
        throw NetworkFileSystemException('重命名失败: $rnfrResponse');
      }

      await _sendCommand('RNTO $newPath');
      final rntoResponse = await _readResponse();
      if (!rntoResponse.startsWith('250')) {
        throw NetworkFileSystemException('重命名失败: $rntoResponse');
      }
    } catch (e) {
      if (e is NetworkFileSystemException) rethrow;
      throw NetworkFileSystemException('重命名失败: $oldPath -> $newPath',
          originalError: e);
    }
  }

  /// 确保已连接
  void _ensureConnected() {
    if (!_isConnected || _controlSocket == null) {
      throw NetworkFileSystemException('FTP客户端未连接');
    }
  }

  /// 发送FTP命令
  Future<void> _sendCommand(String command) async {
    _controlSocket!.write('$command\r\n');
    await _controlSocket!.flush();
  }

  /// 读取FTP响应
  Future<String> _readResponse() async {
    final buffer = StringBuffer();
    await for (final data in _controlSocket!) {
      final text = utf8.decode(data);
      buffer.write(text);
      if (text.contains('\n')) {
        break;
      }
    }
    return buffer.toString().trim();
  }

  /// 进入被动模式并返回数据连接
  Future<Socket> _enterPassiveMode() async {
    await _sendCommand('PASV');
    final pasvResponse = await _readResponse();
    if (!pasvResponse.startsWith('227')) {
      throw NetworkFileSystemException('进入被动模式失败: $pasvResponse');
    }

    // 解析被动模式响应获取数据端口
    final match = RegExp(r'\((\d+),(\d+),(\d+),(\d+),(\d+),(\d+)\)')
        .firstMatch(pasvResponse);
    if (match == null) {
      throw NetworkFileSystemException('解析被动模式响应失败: $pasvResponse');
    }

    final ip =
        '${match.group(1)}.${match.group(2)}.${match.group(3)}.${match.group(4)}';
    final port = int.parse(match.group(5)!) * 256 + int.parse(match.group(6)!);

    return await Socket.connect(ip, port,
        timeout: Duration(seconds: config.timeout));
  }

  /// 从数据连接读取所有数据
  Future<List<int>> _readDataFromSocket(Socket socket) async {
    final data = <int>[];
    await for (final chunk in socket) {
      data.addAll(chunk);
    }
    return data;
  }

  /// 解析目录列表
  List<NetworkFileInfo> _parseDirectoryListing(
      List<int> data, String basePath) {
    final text = utf8.decode(data);
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    final files = <NetworkFileInfo>[];

    for (final line in lines) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length < 9) continue;

      final permissions = parts[0];
      final isDirectory = permissions.startsWith('d');
      final size = int.tryParse(parts[4]) ?? 0;
      final name = parts.sublist(8).join(' ');

      if (name == '.' || name == '..') continue;

      final path =
          basePath.endsWith('/') ? '$basePath$name' : '$basePath/$name';

      files.add(NetworkFileInfo(
        name: name,
        path: path,
        isDirectory: isDirectory,
        size: size,
      ));
    }

    return files;
  }
}

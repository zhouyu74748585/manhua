import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/data/models/library.dart';
import 'package:manhua_reader_flutter/data/models/network_config.dart';

void main() {
  group('网络漫画库认证信息存储测试', () {
    test('应该能够在LibrarySettings中存储和读取NetworkConfig', () {
      // 创建包含认证信息的网络配置
      const networkConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        port: 445,
        username: 'testuser',
        password: 'testpass',
        shareName: 'manga',
        remotePath: '/comics',
      );

      // 创建包含网络配置的库设置
      final settings = LibrarySettings(
        networkConfig: networkConfig,
      );

      // 验证网络配置被正确存储
      expect(settings.networkConfig, isNotNull);
      expect(settings.networkConfig!.username, equals('testuser'));
      expect(settings.networkConfig!.password, equals('testpass'));
      expect(settings.networkConfig!.host, equals('192.168.1.100'));
      expect(settings.networkConfig!.shareName, equals('manga'));
    });

    test('应该能够通过JSON序列化保持认证信息', () {
      // 创建包含认证信息的网络配置
      const networkConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        username: 'testuser',
        password: 'testpass',
        shareName: 'manga',
      );

      // 创建包含网络配置的库设置
      final originalSettings = LibrarySettings(
        networkConfig: networkConfig,
      );

      // 序列化为JSON
      final json = originalSettings.toJson();

      // 从JSON反序列化
      final deserializedSettings = LibrarySettings.fromJson(json);

      // 验证认证信息被正确保持
      expect(deserializedSettings.networkConfig, isNotNull);
      expect(deserializedSettings.networkConfig!.username, equals('testuser'));
      expect(deserializedSettings.networkConfig!.password, equals('testpass'));
      expect(deserializedSettings.networkConfig!.host, equals('192.168.1.100'));
      expect(deserializedSettings.networkConfig!.shareName, equals('manga'));
    });

    test('应该能够在MangaLibrary中存储网络认证信息', () {
      // 创建包含认证信息的网络配置
      const networkConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        username: 'testuser',
        password: 'testpass',
        shareName: 'manga',
      );

      // 创建包含网络配置的库设置
      final settings = LibrarySettings(
        networkConfig: networkConfig,
      );

      // 创建网络类型的漫画库
      final library = MangaLibrary(
        id: 'test-lib-1',
        name: '测试网络库',
        path: 'smb://192.168.1.100/manga',
        type: LibraryType.network,
        createdAt: DateTime.now(),
        settings: settings,
      );

      // 验证漫画库包含完整的网络配置
      expect(library.settings.networkConfig, isNotNull);
      expect(library.settings.networkConfig!.username, equals('testuser'));
      expect(library.settings.networkConfig!.password, equals('testpass'));
    });

    test('应该能够通过MangaLibrary的JSON序列化保持认证信息', () {
      // 创建包含认证信息的网络配置
      const networkConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        username: 'testuser',
        password: 'testpass',
        shareName: 'manga',
      );

      // 创建包含网络配置的库设置
      final settings = LibrarySettings(
        networkConfig: networkConfig,
      );

      // 创建网络类型的漫画库
      final originalLibrary = MangaLibrary(
        id: 'test-lib-1',
        name: '测试网络库',
        path: 'smb://192.168.1.100/manga',
        type: LibraryType.network,
        createdAt: DateTime.now(),
        settings: settings,
      );

      // 序列化为JSON
      final json = originalLibrary.toJson();

      // 从JSON反序列化
      final deserializedLibrary = MangaLibrary.fromJson(json);

      // 验证认证信息被正确保持
      expect(deserializedLibrary.settings.networkConfig, isNotNull);
      expect(deserializedLibrary.settings.networkConfig!.username,
          equals('testuser'));
      expect(deserializedLibrary.settings.networkConfig!.password,
          equals('testpass'));
      expect(deserializedLibrary.settings.networkConfig!.host,
          equals('192.168.1.100'));
      expect(deserializedLibrary.settings.networkConfig!.shareName,
          equals('manga'));
    });

    test('copyWith方法应该正确处理networkConfig', () {
      // 创建原始网络配置
      const originalConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        username: 'olduser',
        password: 'oldpass',
        shareName: 'manga',
      );

      // 创建新的网络配置
      const newConfig = NetworkConfig(
        protocol: NetworkProtocol.smb,
        host: '192.168.1.100',
        username: 'newuser',
        password: 'newpass',
        shareName: 'manga',
      );

      // 创建原始设置
      final originalSettings = LibrarySettings(
        networkConfig: originalConfig,
      );

      // 使用copyWith更新网络配置
      final updatedSettings = originalSettings.copyWith(
        networkConfig: newConfig,
      );

      // 验证配置被正确更新
      expect(updatedSettings.networkConfig!.username, equals('newuser'));
      expect(updatedSettings.networkConfig!.password, equals('newpass'));
    });
  });
}

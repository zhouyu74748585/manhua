import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/core/services/permission_service.dart';

void main() {
  group('PermissionService Tests', () {
    setUp(() async {
      // 清理测试环境
      SharedPreferences.setMockInitialValues({});
    });

    test('应该能够保存和获取已授权路径', () async {
      const testPath1 = '/storage/emulated/0/Download/manga';
      const testPath2 = '/storage/emulated/0/Pictures/comics';

      // 保存路径
      await PermissionService.saveGrantedPath(testPath1);
      await PermissionService.saveGrantedPath(testPath2);

      // 获取路径列表
      final paths = await PermissionService.getGrantedPaths();

      expect(paths, contains(testPath1));
      expect(paths, contains(testPath2));
      expect(paths.length, equals(2));
    });

    test('应该能够检查路径是否已授权', () async {
      const testPath = '/storage/emulated/0/Download/manga';

      // 初始状态应该是未授权
      final initialStatus = await PermissionService.isPathGranted(testPath);
      expect(initialStatus, isFalse);

      // 保存路径后应该是已授权
      await PermissionService.saveGrantedPath(testPath);
      final afterSaveStatus = await PermissionService.isPathGranted(testPath);
      expect(afterSaveStatus, isTrue);
    });

    test('应该能够检查父路径权限', () async {
      const parentPath = '/storage/emulated/0/Download';
      const childPath = '/storage/emulated/0/Download/manga/series1';

      // 保存父路径权限
      await PermissionService.saveGrantedPath(parentPath);

      // 子路径应该也被认为是已授权的
      final childStatus = await PermissionService.isPathGranted(childPath);
      expect(childStatus, isTrue);
    });

    test('应该能够清除所有权限数据', () async {
      const testPath1 = '/storage/emulated/0/Download/manga';
      const testPath2 = '/storage/emulated/0/Pictures/comics';

      // 保存一些路径
      await PermissionService.saveGrantedPath(testPath1);
      await PermissionService.saveGrantedPath(testPath2);

      // 确认路径已保存
      final pathsBeforeClear = await PermissionService.getGrantedPaths();
      expect(pathsBeforeClear.length, equals(2));

      // 清除所有权限
      await PermissionService.clearAllPermissions();

      // 确认路径已清除
      final pathsAfterClear = await PermissionService.getGrantedPaths();
      expect(pathsAfterClear.length, equals(0));

      // 确认路径不再被认为是已授权的
      final path1Status = await PermissionService.isPathGranted(testPath1);
      final path2Status = await PermissionService.isPathGranted(testPath2);
      expect(path1Status, isFalse);
      expect(path2Status, isFalse);
    });

    test('应该避免重复保存相同路径', () async {
      const testPath = '/storage/emulated/0/Download/manga';

      // 多次保存相同路径
      await PermissionService.saveGrantedPath(testPath);
      await PermissionService.saveGrantedPath(testPath);
      await PermissionService.saveGrantedPath(testPath);

      // 应该只有一个路径
      final paths = await PermissionService.getGrantedPaths();
      expect(paths.length, equals(1));
      expect(paths.first, equals(testPath));
    });

    test('应该正确处理路径规范化', () async {
      const path1 = '/storage/emulated/0/Download/manga/';  // 带尾部斜杠
      const path2 = '/storage/emulated/0/Download/manga';   // 不带尾部斜杠

      // 保存带尾部斜杠的路径
      await PermissionService.saveGrantedPath(path1);

      // 检查不带尾部斜杠的路径应该也被认为是已授权的
      final status = await PermissionService.isPathGranted(path2);
      expect(status, isTrue);

      // 路径列表中应该只有一个规范化的路径
      final paths = await PermissionService.getGrantedPaths();
      expect(paths.length, equals(1));
    });

    test('应该正确处理空路径和无效路径', () async {
      // 测试空路径
      await PermissionService.saveGrantedPath('');
      final emptyPathStatus = await PermissionService.isPathGranted('');
      expect(emptyPathStatus, isFalse);

      // 测试null路径（通过空字符串模拟）
      final paths = await PermissionService.getGrantedPaths();
      expect(paths, isNot(contains('')));
    });

    test('应该能够处理大量路径', () async {
      final testPaths = List.generate(100, (index) => '/storage/test/path$index');

      // 保存大量路径
      for (final path in testPaths) {
        await PermissionService.saveGrantedPath(path);
      }

      // 验证所有路径都已保存
      final savedPaths = await PermissionService.getGrantedPaths();
      expect(savedPaths.length, equals(100));

      for (final path in testPaths) {
        expect(savedPaths, contains(path));
        final status = await PermissionService.isPathGranted(path);
        expect(status, isTrue);
      }
    });
  });
}

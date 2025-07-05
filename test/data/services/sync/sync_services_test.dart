import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manhua_reader_flutter/data/models/sync/device_info.dart';
import 'package:manhua_reader_flutter/data/models/sync/sync_session.dart'
    as sync_models;
import 'package:manhua_reader_flutter/data/services/sync/library_sync_service.dart';
import 'package:manhua_reader_flutter/data/services/sync/multi_device_sync_service.dart';
import 'package:manhua_reader_flutter/data/services/sync/sync_coordinator_service.dart'
    as sync_services;
import 'package:manhua_reader_flutter/presentation/providers/sync_providers.dart';

void main() {
  group('Sync Services Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('MultiDeviceSyncService can be created', () {
      final service = container.read(multiDeviceSyncServiceProvider);
      expect(service, isNotNull);
      expect(service, isA<MultiDeviceSyncService>());
    });

    test('LibrarySyncService can be created', () {
      final service = container.read(librarySyncServiceProvider);
      expect(service, isNotNull);
      expect(service, isA<LibrarySyncService>());
    });

    test('SyncCoordinatorService can be created', () {
      final service = container.read(syncCoordinatorServiceProvider);
      expect(service, isNotNull);
      expect(service, isA<sync_services.SyncCoordinatorService>());
    });

    test('DeviceInfo model works correctly', () {
      final device = DeviceInfo(
        id: 'test-device-1',
        name: 'Test Device',
        platform: 'Android', // 添加必需的 platform 参数
        version: '1.0.0', // 添加必需的 version 参数
        ipAddress: '192.168.1.100',
        port: 8080,
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      expect(device.id, equals('test-device-1'));
      expect(device.name, equals('Test Device'));
      expect(device.ipAddress, equals('192.168.1.100'));
      expect(device.port, equals(8080));
      expect(device.isOnline, isTrue);
    });

    test('SyncSession model works correctly', () {
      final session = sync_models.SyncSession(
        id: 'session-1',
        sourceDeviceId: 'device-1',
        targetDeviceId: 'device-2',
        type: sync_models.SyncType.library,
        direction: sync_models.SyncDirection.bidirectional,
        status: sync_models.SyncStatus.inProgress,
        startTime: DateTime.now(),
        libraryIds: ['lib-1', 'lib-2'], // 添加必需的 libraryIds 参数
        totalItems: 100,
        processedItems: 50,
      );

      expect(session.id, equals('session-1'));
      expect(session.sourceDeviceId, equals('device-1'));
      expect(session.targetDeviceId, equals('device-2'));
      expect(session.type, equals(sync_models.SyncType.library));
      expect(
          session.direction, equals(sync_models.SyncDirection.bidirectional));
      expect(session.status, equals(sync_models.SyncStatus.inProgress));
      expect(session.totalItems, equals(100));
      expect(session.processedItems, equals(50));
    });

    // 注意：SyncResult、SyncProgress、SyncCoordinatorEvent 等类尚未实现
    // 这些测试将在相关类实现后添加
  });
}

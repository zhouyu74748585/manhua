import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';

import '../../../data/models/library.dart';
import '../../../data/models/manga.dart';
import '../../../data/models/reading_progress.dart';
import '../../../data/models/sync/device_info.dart';
import '../../../data/models/sync/sync_session.dart';
import '../../../data/services/drift_database_service.dart';
import 'connection_pool_manager.dart';

/// HTTP communication service for device-to-device sync
class SyncCommunicationService {
  static const int _defaultPort = 8080;
  static const Duration _requestTimeout =
      Duration(minutes: 5); // 优化：增加超时时间用于大文件传输
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout =
      Duration(minutes: 10); // 优化：接收大文件时需要更长时间

  HttpServer? _server;
  late Dio _dio;
  int _port = _defaultPort;
  bool _isServerRunning = false;
  bool _isDisposed = false;

  /// Callbacks for handling sync requests
  Function(DeviceInfo)? onDeviceConnected;
  Function(String, List<String>)? onLibrarySyncRequested;
  Function(String, String)? onProgressSyncRequested;
  Function(SyncSession)? onSyncSessionUpdate;

  /// Initialize the communication service
  Future<void> initialize({int? port}) async {
    _port = port ?? _defaultPort;

    // Initialize connection pool manager
    ConnectionPoolManager.instance.initialize();

    // Initialize Dio client with optimized timeouts (fallback for non-pooled requests)
    _dio = Dio(BaseOptions(
      connectTimeout: _connectionTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Manhua-Reader/1.0.0',
      },
    ));

    log('Sync communication service initialized on port $_port');
  }

  /// Start the HTTP server
  Future<void> startServer() async {
    if (_isServerRunning) {
      log('Server already running');
      return;
    }

    try {
      final router = _createRouter();
      final handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addMiddleware(_corsMiddleware())
          .addHandler(router);

      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _server!.listen((request) async {
        // 转换 HttpRequest 头部为 Map<String, String>
        final headers = <String, String>{};
        request.headers.forEach((name, values) {
          headers[name] = values.join(',');
        });

        // 创建 Shelf Request
        final shelfRequest = shelf.Request(
          request.method,
          request.uri,
          headers: headers,
          body: request,
        );

        final response = await handler(shelfRequest);

        // 设置响应状态码
        request.response.statusCode = response.statusCode;

        // 设置响应头部
        response.headers.forEach((name, value) {
          request.response.headers.set(name, value);
        });

        // 写入响应体
        final responseBody = await response.readAsString();
        if (responseBody.isNotEmpty) {
          request.response.write(responseBody);
        }
        await request.response.close();
      });

      _isServerRunning = true;
      log('HTTP server started on port $_port');
    } catch (e, stackTrace) {
      log('Failed to start HTTP server: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stop the HTTP server
  Future<void> stopServer() async {
    if (!_isServerRunning) return;

    try {
      await _server?.close();
      _server = null;
      _isServerRunning = false;
      log('HTTP server stopped');
    } catch (e, stackTrace) {
      log('Failed to stop HTTP server: $e', stackTrace: stackTrace);
    }
  }

  /// Create the router with API endpoints
  Router _createRouter() {
    final router = Router();

    // Device info endpoint
    router.get('/api/device', _handleGetDeviceInfo);

    // Ping endpoint for connectivity check
    router.get('/api/ping', _handlePing);

    // Library sync endpoints
    router.get('/api/libraries', _handleGetLibraries);
    router.post('/api/libraries/sync', _handleLibrarySync);

    // Manga endpoints
    router.get('/api/libraries/<libraryId>/mangas', _handleGetMangas);
    router.post('/api/libraries/<libraryId>/mangas/sync', _handleMangaSync);

    // Reading progress endpoints
    router.get('/api/progress', _handleGetProgress);
    router.post('/api/progress/sync', _handleProgressSync);

    // Sync session endpoints
    router.post('/api/sync/session', _handleCreateSyncSession);
    router.get('/api/sync/session/<sessionId>', _handleGetSyncSession);
    router.put('/api/sync/session/<sessionId>', _handleUpdateSyncSession);

    // Additional library sync endpoints
    router.post('/api/sync/libraries', _handleGetSyncLibraries);
    router.post('/api/sync/manga', _handleGetSyncManga);
    router.post('/api/sync/library', _handleSyncLibraryUpdate);
    router.post('/api/sync/manga/update', _handleSyncMangaUpdate);
    router.get('/api/sync/progress/<mangaId>', _handleGetSyncProgress);
    router.post('/api/sync/progress', _handleUpdateSyncProgress);

    return router;
  }

  /// CORS middleware
  shelf.Middleware _corsMiddleware() {
    return (shelf.Handler innerHandler) {
      return (shelf.Request request) async {
        if (request.method == 'OPTIONS') {
          return shelf.Response.ok('', headers: _corsHeaders);
        }

        final response = await innerHandler(request);
        return response.change(headers: {...response.headers, ..._corsHeaders});
      };
    };
  }

  /// CORS headers
  Map<String, String> get _corsHeaders => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      };

  // ==================== Request Handlers ====================

  /// Handle device info request
  Future<shelf.Response> _handleGetDeviceInfo(shelf.Request request) async {
    try {
      // This would be provided by the device discovery service
      final deviceInfo = {
        'id': 'current_device_id',
        'name': 'Current Device',
        'platform': Platform.operatingSystem,
        'version': '1.0.0',
        'capabilities': {
          'supports_library_sync': true,
          'supports_progress_sync': true,
          'supports_file_transfer': true,
        },
      };

      return shelf.Response.ok(
        jsonEncode(deviceInfo),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling device info request: $e', stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get device info'}),
      );
    }
  }

  /// Handle ping request
  Future<shelf.Response> _handlePing(shelf.Request request) async {
    return shelf.Response.ok(
      jsonEncode(
          {'status': 'ok', 'timestamp': DateTime.now().toIso8601String()}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Handle get libraries request
  Future<shelf.Response> _handleGetLibraries(shelf.Request request) async {
    try {
      // This would be implemented by calling the library service
      final libraries = <Map<String, dynamic>>[];

      return shelf.Response.ok(
        jsonEncode({'libraries': libraries}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get libraries request: $e', stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get libraries'}),
      );
    }
  }

  /// Handle library sync request
  Future<shelf.Response> _handleLibrarySync(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final libraryIds = List<String>.from(data['library_ids'] ?? []);
      final sourceDeviceId = data['source_device_id'] as String?;

      if (sourceDeviceId != null && onLibrarySyncRequested != null) {
        onLibrarySyncRequested!(sourceDeviceId, libraryIds);
      }

      return shelf.Response.ok(
        jsonEncode({'status': 'sync_started', 'library_ids': libraryIds}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling library sync request: $e', stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid sync request'}),
      );
    }
  }

  /// Handle get mangas request
  Future<shelf.Response> _handleGetMangas(shelf.Request request) async {
    try {
      final libraryId = request.params['libraryId'];
      if (libraryId == null) {
        return shelf.Response.badRequest(
          body: jsonEncode({'error': 'Library ID required'}),
        );
      }

      // This would be implemented by calling the manga service
      final mangas = <Map<String, dynamic>>[];

      return shelf.Response.ok(
        jsonEncode({'mangas': mangas}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get mangas request: $e', stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get mangas'}),
      );
    }
  }

  /// Handle manga sync request
  Future<shelf.Response> _handleMangaSync(shelf.Request request) async {
    try {
      final libraryId = request.params['libraryId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Process manga sync data
      final mangas = data['mangas'] as List<dynamic>? ?? [];

      return shelf.Response.ok(
        jsonEncode({'status': 'mangas_synced', 'count': mangas.length}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling manga sync request: $e', stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid manga sync request'}),
      );
    }
  }

  /// Handle get progress request
  Future<shelf.Response> _handleGetProgress(shelf.Request request) async {
    try {
      // This would be implemented by calling the reading progress service
      final progress = <Map<String, dynamic>>[];

      return shelf.Response.ok(
        jsonEncode({'progress': progress}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get progress request: $e', stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get progress'}),
      );
    }
  }

  /// Handle progress sync request
  Future<shelf.Response> _handleProgressSync(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final sourceDeviceId = data['source_device_id'] as String?;
      final mangaId = data['manga_id'] as String?;

      if (sourceDeviceId != null &&
          mangaId != null &&
          onProgressSyncRequested != null) {
        onProgressSyncRequested!(sourceDeviceId, mangaId);
      }

      return shelf.Response.ok(
        jsonEncode({'status': 'progress_sync_started'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling progress sync request: $e', stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid progress sync request'}),
      );
    }
  }

  /// Handle create sync session request
  Future<shelf.Response> _handleCreateSyncSession(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Create sync session
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

      return shelf.Response.ok(
        jsonEncode({'session_id': sessionId, 'status': 'created'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling create sync session request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid session creation request'}),
      );
    }
  }

  /// Handle get sync session request
  Future<shelf.Response> _handleGetSyncSession(shelf.Request request) async {
    try {
      final sessionId = request.params['sessionId'];
      if (sessionId == null) {
        return shelf.Response.badRequest(
          body: jsonEncode({'error': 'Session ID required'}),
        );
      }

      // This would be implemented by calling the sync session service
      final session = {
        'id': sessionId,
        'status': 'completed',
        'progress': 100.0,
      };

      return shelf.Response.ok(
        jsonEncode(session),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get sync session request: $e',
          stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get sync session'}),
      );
    }
  }

  /// Handle update sync session request
  Future<shelf.Response> _handleUpdateSyncSession(shelf.Request request) async {
    try {
      final sessionId = request.params['sessionId'];
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (sessionId == null) {
        return shelf.Response.badRequest(
          body: jsonEncode({'error': 'Session ID required'}),
        );
      }

      return shelf.Response.ok(
        jsonEncode({'status': 'updated', 'session_id': sessionId}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling update sync session request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid session update request'}),
      );
    }
  }

  // ==================== Additional Sync Handlers ====================

  /// Handle get sync libraries request
  Future<shelf.Response> _handleGetSyncLibraries(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final libraryIds = List<String>.from(data['library_ids'] ?? []);

      // Get libraries from database
      final libraries = <Map<String, dynamic>>[];
      for (final id in libraryIds) {
        final library = await DriftDatabaseService.getLibraryById(id);
        if (library != null) {
          libraries.add(library.toJson());
        }
      }

      return shelf.Response.ok(
        jsonEncode({'libraries': libraries}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get sync libraries request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid get libraries request'}),
      );
    }
  }

  /// Handle get sync manga request
  Future<shelf.Response> _handleGetSyncManga(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final libraryIds = List<String>.from(data['library_ids'] ?? []);

      // Get manga from database
      final allManga = <Map<String, dynamic>>[];
      for (final libraryId in libraryIds) {
        final manga = await DriftDatabaseService.getMangaByLibraryId(libraryId);
        allManga.addAll(manga.map((m) => m.toJson()));
      }

      return shelf.Response.ok(
        jsonEncode({'manga': allManga}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get sync manga request: $e', stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid get manga request'}),
      );
    }
  }

  /// Handle sync library update request
  Future<shelf.Response> _handleSyncLibraryUpdate(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final library = MangaLibrary.fromJson(data);

      // Update or insert library
      await DriftDatabaseService.insertOrUpdateLibrary(library);

      return shelf.Response.ok(
        jsonEncode({'status': 'success', 'library_id': library.id}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling sync library update request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid library update request'}),
      );
    }
  }

  /// Handle sync manga update request
  Future<shelf.Response> _handleSyncMangaUpdate(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final manga = Manga.fromJson(data);

      // Update or insert manga
      await DriftDatabaseService.insertOrUpdateManga(manga);

      return shelf.Response.ok(
        jsonEncode({'status': 'success', 'manga_id': manga.id}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling sync manga update request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid manga update request'}),
      );
    }
  }

  /// Handle get sync progress request
  Future<shelf.Response> _handleGetSyncProgress(shelf.Request request) async {
    try {
      final mangaId = request.params['mangaId'];
      if (mangaId == null) {
        return shelf.Response.badRequest(
          body: jsonEncode({'error': 'Manga ID required'}),
        );
      }

      final progress =
          await DriftDatabaseService.getReadingProgressByMangaId(mangaId);

      return shelf.Response.ok(
        jsonEncode({'progress': progress?.toJson()}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling get sync progress request: $e',
          stackTrace: stackTrace);
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get reading progress'}),
      );
    }
  }

  /// Handle update sync progress request
  Future<shelf.Response> _handleUpdateSyncProgress(
      shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final progress = ReadingProgress.fromJson(data);

      // Update reading progress
      await DriftDatabaseService.insertOrUpdateReadingProgress(progress);

      return shelf.Response.ok(
        jsonEncode({'status': 'success', 'manga_id': progress.mangaId}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      log('Error handling update sync progress request: $e',
          stackTrace: stackTrace);
      return shelf.Response.badRequest(
        body: jsonEncode({'error': 'Invalid progress update request'}),
      );
    }
  }

  // ==================== Client Methods ====================

  /// 获取连接池中的连接
  Dio _getPooledConnection(String baseUrl, {Map<String, String>? headers}) {
    try {
      return ConnectionPoolManager.instance
          .getConnection(baseUrl, headers: headers);
    } catch (e) {
      log('获取连接池连接失败，使用默认连接: $e');
      return _dio;
    }
  }

  /// Send a ping request to a device
  Future<bool> pingDevice(DeviceInfo device) async {
    try {
      final baseUrl = 'http://${device.ipAddress}:${device.port}';
      final dio = _getPooledConnection(baseUrl);
      final response = await dio.get('/api/ping');
      return response.statusCode == 200;
    } catch (e) {
      log('Failed to ping device ${device.name}: $e');
      return false;
    }
  }

  /// Get device information from a remote device
  Future<DeviceInfo?> getDeviceInfo(String ipAddress, int port) async {
    try {
      final baseUrl = 'http://$ipAddress:$port';
      final dio = _getPooledConnection(baseUrl);
      final response = await dio.get('/api/device');
      if (response.statusCode == 200) {
        return DeviceInfo.fromJson(response.data);
      }
    } catch (e) {
      log('Failed to get device info from $ipAddress:$port: $e');
    }
    return null;
  }

  /// Request library sync from a remote device
  Future<bool> requestLibrarySync(
      DeviceInfo device, List<String> libraryIds) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/libraries/sync',
        data: {
          'library_ids': libraryIds,
          'source_device_id':
              'current_device_id', // This would come from current device
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Failed to request library sync from ${device.name}: $e');
      return false;
    }
  }

  /// Request progress sync from a remote device
  Future<bool> requestProgressSync(DeviceInfo device, String mangaId) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/progress/sync',
        data: {
          'manga_id': mangaId,
          'source_device_id':
              'current_device_id', // This would come from current device
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Failed to request progress sync from ${device.name}: $e');
      return false;
    }
  }

  // ==================== Library Sync Methods ====================

  /// Get libraries from remote device
  Future<List<MangaLibrary>> getLibraries(
      DeviceInfo device, List<String> libraryIds) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/sync/libraries',
        data: {'library_ids': libraryIds},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['libraries'];
        return data.map((json) => MangaLibrary.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get libraries: ${response.statusCode}');
      }
    } catch (e) {
      log('Failed to get libraries from ${device.name}: $e');
      rethrow;
    }
  }

  /// Get manga from remote device
  Future<List<Manga>> getManga(
      DeviceInfo device, List<String> libraryIds) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/sync/manga',
        data: {'library_ids': libraryIds},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['manga'];
        return data.map((json) => Manga.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get manga: ${response.statusCode}');
      }
    } catch (e) {
      log('Failed to get manga from ${device.name}: $e');
      rethrow;
    }
  }

  /// Sync library to remote device
  Future<bool> syncLibrary(DeviceInfo device, MangaLibrary library) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/sync/library',
        data: library.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Failed to sync library to ${device.name}: $e');
      return false;
    }
  }

  /// Sync manga to remote device
  Future<bool> syncManga(DeviceInfo device, Manga manga) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/sync/manga/update',
        data: manga.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Failed to sync manga to ${device.name}: $e');
      return false;
    }
  }

  /// Get reading progress from remote device
  Future<ReadingProgress?> getReadingProgress(
      DeviceInfo device, String mangaId) async {
    try {
      final response = await _dio.get(
        'http://${device.ipAddress}:${device.port}/api/sync/progress/$mangaId',
      );

      if (response.statusCode == 200 && response.data['progress'] != null) {
        return ReadingProgress.fromJson(response.data['progress']);
      }
      return null;
    } catch (e) {
      log('Failed to get reading progress from ${device.name}: $e');
      return null;
    }
  }

  /// Update reading progress on remote device
  Future<bool> updateReadingProgress(
      DeviceInfo device, ReadingProgress progress) async {
    try {
      final response = await _dio.post(
        'http://${device.ipAddress}:${device.port}/api/sync/progress',
        data: progress.toJson(),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Failed to update reading progress on ${device.name}: $e');
      return false;
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_isDisposed) return;

    log('开始释放SyncCommunicationService资源');
    _isDisposed = true;

    try {
      // 停止HTTP服务器
      await stopServer();

      // 关闭Dio客户端
      _dio.close();

      // 释放连接池资源
      await ConnectionPoolManager.instance.dispose();

      // 清理回调函数
      onDeviceConnected = null;
      onLibrarySyncRequested = null;
      onProgressSyncRequested = null;
      onSyncSessionUpdate = null;

      log('SyncCommunicationService资源释放完成');
    } catch (e, stackTrace) {
      log('释放SyncCommunicationService资源时发生错误: $e', stackTrace: stackTrace);
    }
  }
}

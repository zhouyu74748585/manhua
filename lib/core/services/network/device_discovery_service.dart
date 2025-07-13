import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../data/models/sync/device_info.dart';
import 'udp_discovery_service.dart';

/// Service for discovering devices on the local network using mDNS or UDP broadcast
class DeviceDiscoveryService {
  static const String _serviceType = '_manhua_reader._tcp';
  static const String _serviceName = 'Manhua Reader';
  static const int _defaultPort = 8080;
  static const Duration _discoveryTimeout = Duration(seconds: 30); // 优化：减少发现频率
  static const Duration _heartbeatInterval = Duration(seconds: 60); // 优化：减少心跳频率

  MDnsClient? _mdnsClient;
  UdpDiscoveryService? _udpDiscoveryService;
  Timer? _heartbeatTimer;
  Timer? _discoveryTimer;

  final StreamController<List<DeviceInfo>> _devicesController =
      StreamController<List<DeviceInfo>>.broadcast();
  final Map<String, DeviceInfo> _discoveredDevices = {};

  DeviceInfo? _currentDevice;
  bool _isDiscovering = false;
  bool _isAdvertising = false;
  bool _isDisposed = false;
  bool _useUdpFallback = false;

  /// Stream of discovered devices
  Stream<List<DeviceInfo>> get devicesStream => _devicesController.stream;

  /// List of currently discovered devices
  List<DeviceInfo> get discoveredDevices => _discoveredDevices.values.toList();

  /// Current device information
  DeviceInfo? get currentDevice => _currentDevice;

  /// Whether discovery is active
  bool get isDiscovering => _isDiscovering;

  /// Whether advertising is active
  bool get isAdvertising => _isAdvertising;

  /// Initialize the discovery service
  Future<void> initialize() async {
    try {
      _currentDevice = await _createCurrentDeviceInfo();
      log('Device discovery service initialized: ${_currentDevice?.name}');
    } catch (e, stackTrace) {
      log('Failed to initialize device discovery service: $e',
          stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Start advertising this device on the network
  Future<void> startAdvertising({int? port}) async {
    if (_isAdvertising) {
      log('Already advertising');
      return;
    }

    try {
      _mdnsClient ??= MDnsClient();
      await _mdnsClient!.start();

      final devicePort = port ?? _defaultPort;
      final deviceInfo = _currentDevice?.copyWith(port: devicePort);

      if (deviceInfo == null) {
        throw Exception('Current device info not available');
      }

      // Create TXT records with device information
      final txtRecords = <String>[
        'id=${deviceInfo.id}',
        'name=${deviceInfo.name}',
        'platform=${deviceInfo.platform}',
        'version=${deviceInfo.version}',
        'capabilities=${jsonEncode(deviceInfo.capabilities)}',
      ];

      // Advertise the service
      await _mdnsClient!.start(
        interfacesFactory: (InternetAddressType type) =>
            NetworkInterface.list(),
      );

      _isAdvertising = true;
      _currentDevice = deviceInfo;

      // Start heartbeat to keep the service alive
      _startHeartbeat();

      log('Started advertising device: ${deviceInfo.name} on port $devicePort');
    } catch (e, stackTrace) {
      log('Failed to start advertising: $e', stackTrace: stackTrace);
      _isAdvertising = false;
      rethrow;
    }
  }

  /// Stop advertising this device
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;

      _mdnsClient?.stop();
      _isAdvertising = false;

      log('Stopped advertising device');
    } catch (e, stackTrace) {
      log('Failed to stop advertising: $e', stackTrace: stackTrace);
    }
  }

  /// Start discovering devices on the network
  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      log('Already discovering');
      return;
    }

    try {
      _isDiscovering = true;
      _discoveredDevices.clear();
      _notifyDevicesChanged();

      // 尝试使用mDNS，如果失败则使用UDP广播
      bool mdnsSuccess = false;

      if (!_useUdpFallback) {
        try {
          _mdnsClient ??= MDnsClient();
          await _mdnsClient!.start();

          // Start periodic discovery
          _discoveryTimer =
              Timer.periodic(_discoveryTimeout, (_) => _performDiscovery());

          // Perform initial discovery
          await _performDiscovery();

          mdnsSuccess = true;
          log('Started mDNS device discovery');
        } catch (e) {
          log('mDNS discovery failed, falling back to UDP broadcast: $e');
          _useUdpFallback = true;
          mdnsSuccess = false;
        }
      }

      // 如果mDNS失败或者已经设置为使用UDP，则使用UDP广播
      if (!mdnsSuccess || _useUdpFallback) {
        await _startUdpDiscovery();
      }
    } catch (e, stackTrace) {
      log('Failed to start discovery: $e', stackTrace: stackTrace);
      _isDiscovering = false;
      rethrow;
    }
  }

  /// Stop discovering devices
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      _discoveryTimer?.cancel();
      _discoveryTimer = null;

      // 停止UDP发现服务
      if (_udpDiscoveryService != null) {
        await _udpDiscoveryService!.stopDiscovery();
      }

      _isDiscovering = false;

      log('Stopped device discovery');
    } catch (e, stackTrace) {
      log('Failed to stop discovery: $e', stackTrace: stackTrace);
    }
  }

  /// 启动UDP发现服务
  Future<void> _startUdpDiscovery() async {
    if (_currentDevice == null) {
      throw Exception('Current device info not available for UDP discovery');
    }

    try {
      _udpDiscoveryService ??= UdpDiscoveryService();
      await _udpDiscoveryService!.initialize(_currentDevice!);

      // 监听UDP发现的设备
      _udpDiscoveryService!.devicesStream.listen((devices) {
        _discoveredDevices.clear();
        for (final device in devices) {
          _discoveredDevices[device.id] = device;
        }
        _notifyDevicesChanged();
      });

      await _udpDiscoveryService!.startDiscovery();
      log('Started UDP device discovery');
    } catch (e) {
      log('Failed to start UDP discovery: $e');
      rethrow;
    }
  }

  /// Perform a single discovery scan
  Future<void> _performDiscovery() async {
    try {
      if (_mdnsClient == null) return;

      await for (final PtrResourceRecord ptr in _mdnsClient!
          .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(_serviceType))
          .timeout(_discoveryTimeout)) {
        // Get SRV record for the service
        await for (final SrvResourceRecord srv in _mdnsClient!
            .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))
            .timeout(const Duration(seconds: 5))) {
          // Get TXT records for additional information
          final txtRecords = <String>[];
          await for (final TxtResourceRecord txt in _mdnsClient!
              .lookup<TxtResourceRecord>(
                  ResourceRecordQuery.text(ptr.domainName))
              .timeout(const Duration(seconds: 2))) {
            txtRecords.add(txt.text);
          }

          final deviceInfo = _parseDeviceInfo(srv, txtRecords);
          if (deviceInfo != null && deviceInfo.id != _currentDevice?.id) {
            _discoveredDevices[deviceInfo.id] = deviceInfo;
            _notifyDevicesChanged();
          }
        }
      }
    } catch (e) {
      // Discovery timeouts are expected, don't log as errors
      if (e is! TimeoutException) {
        log('Discovery error: $e');
      }
    }
  }

  /// Parse device information from mDNS records
  DeviceInfo? _parseDeviceInfo(SrvResourceRecord srv, List<String> txtRecords) {
    try {
      final txtMap = <String, String>{};
      for (final record in txtRecords) {
        final parts = record.split('=');
        if (parts.length == 2) {
          txtMap[parts[0]] = parts[1];
        }
      }

      final id = txtMap['id'];
      final name = txtMap['name'];
      final platform = txtMap['platform'];
      final version = txtMap['version'];
      final capabilitiesStr = txtMap['capabilities'];

      if (id == null || name == null || platform == null || version == null) {
        return null;
      }

      Map<String, dynamic> capabilities = {};
      if (capabilitiesStr != null) {
        try {
          capabilities = jsonDecode(capabilitiesStr);
        } catch (e) {
          log('Failed to parse capabilities: $e');
        }
      }

      return DeviceInfo(
        id: id,
        name: name,
        platform: platform,
        version: version,
        ipAddress: srv.target,
        port: srv.port,
        lastSeen: DateTime.now(),
        isOnline: true,
        capabilities: capabilities,
      );
    } catch (e, stackTrace) {
      log('Failed to parse device info: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// Create device information for the current device
  Future<DeviceInfo> _createCurrentDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final networkInfo = NetworkInfo();

    String deviceName = 'Unknown Device';
    String platform = 'unknown';
    String deviceId = 'unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.model;
        platform = 'android';
        deviceId = androidInfo.id;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceName = windowsInfo.computerName;
        platform = 'windows';
        deviceId = windowsInfo.deviceId ??
            'windows_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = iosInfo.name;
        platform = 'ios';
        deviceId = iosInfo.identifierForVendor ??
            'ios_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        deviceName = macInfo.computerName;
        platform = 'macos';
        deviceId = macInfo.systemGUID ??
            'macos_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceName = linuxInfo.name;
        platform = 'linux';
        deviceId = linuxInfo.machineId ??
            'linux_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      log('Failed to get device info: $e');
    }

    // Get IP address
    String ipAddress = '127.0.0.1';
    try {
      final wifiIP = await networkInfo.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        ipAddress = wifiIP;
      }
    } catch (e) {
      log('Failed to get IP address: $e');
    }

    return DeviceInfo(
      id: deviceId,
      name: deviceName,
      platform: platform,
      version: '1.0.0', // TODO: Get from package info
      ipAddress: ipAddress,
      port: _defaultPort,
      lastSeen: DateTime.now(),
      isOnline: true,
      capabilities: {
        'supports_library_sync': true,
        'supports_progress_sync': true,
        'supports_file_transfer': true,
      },
    );
  }

  /// Start heartbeat timer to keep the service alive
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      // Update last seen time for current device
      if (_currentDevice != null) {
        _currentDevice = _currentDevice!.copyWith(lastSeen: DateTime.now());
      }

      // Remove offline devices (not seen for more than 2 minutes)
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 2));
      _discoveredDevices
          .removeWhere((id, device) => device.lastSeen.isBefore(cutoffTime));
      _notifyDevicesChanged();
    });
  }

  /// Notify listeners about device list changes
  void _notifyDevicesChanged() {
    if (!_devicesController.isClosed && !_isDisposed) {
      _devicesController.add(discoveredDevices);
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_isDisposed) return;

    log('开始释放DeviceDiscoveryService资源');
    _isDisposed = true;

    try {
      // 停止发现和广播
      await stopDiscovery();
      await stopAdvertising();

      // 取消定时器
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
      _discoveryTimer?.cancel();
      _discoveryTimer = null;

      // 停止mDNS客户端
      try {
        _mdnsClient?.stop();
      } catch (e) {
        log('停止mDNS客户端时发生错误: $e');
      }
      _mdnsClient = null;

      // 停止UDP发现服务
      try {
        if (_udpDiscoveryService != null) {
          await _udpDiscoveryService!.dispose();
          _udpDiscoveryService = null;
        }
      } catch (e) {
        log('停止UDP发现服务时发生错误: $e');
      }

      // 关闭StreamController
      if (!_devicesController.isClosed) {
        await _devicesController.close();
      }

      // 清理数据
      _discoveredDevices.clear();
      _currentDevice = null;

      // 重置状态
      _isDiscovering = false;
      _isAdvertising = false;

      log('DeviceDiscoveryService资源释放完成');
    } catch (e, stackTrace) {
      log('释放DeviceDiscoveryService资源时发生错误: $e', stackTrace: stackTrace);
    }
  }
}

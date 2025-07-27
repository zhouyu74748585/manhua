import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../../data/models/sync/device_info.dart';

/// UDP广播设备发现服务，用于Windows等不支持mDNS的平台
class UdpDiscoveryService {
  static const int _broadcastPort = 8081;
  static const String _discoveryMessage = 'MANHUA_READER_DISCOVERY';
  static const String _responseMessage = 'MANHUA_READER_RESPONSE';
  static const Duration _discoveryInterval = Duration(seconds: 10);
  static const Duration _responseTimeout = Duration(seconds: 3);

  RawDatagramSocket? _socket;
  Timer? _discoveryTimer;
  Timer? _cleanupTimer;
  
  final StreamController<List<DeviceInfo>> _devicesController =
      StreamController<List<DeviceInfo>>.broadcast();
  final Map<String, DeviceInfo> _discoveredDevices = {};
  
  DeviceInfo? _currentDevice;
  bool _isDiscovering = false;
  bool _isListening = false;
  bool _isDisposed = false;

  /// 发现的设备列表
  List<DeviceInfo> get discoveredDevices => _discoveredDevices.values.toList();
  
  /// 设备流
  Stream<List<DeviceInfo>> get devicesStream => _devicesController.stream;
  
  /// 当前设备信息
  DeviceInfo? get currentDevice => _currentDevice;
  
  /// 是否正在发现
  bool get isDiscovering => _isDiscovering;

  /// 初始化服务
  Future<void> initialize(DeviceInfo currentDevice) async {
    if (_isDisposed) return;
    
    _currentDevice = currentDevice;
    
    try {
      // 创建UDP socket
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _broadcastPort);
      _socket!.broadcastEnabled = true;
      
      // 监听传入的消息
      _socket!.listen(_handleIncomingMessage);
      _isListening = true;
      
      log('UDP发现服务初始化成功，监听端口: $_broadcastPort');
    } catch (e) {
      log('UDP发现服务初始化失败: $e');
      rethrow;
    }
  }

  /// 开始设备发现
  Future<void> startDiscovery() async {
    if (_isDiscovering || _isDisposed) return;
    
    _isDiscovering = true;
    _discoveredDevices.clear();
    _notifyDevicesChanged();
    
    // 定期发送发现广播
    _discoveryTimer = Timer.periodic(_discoveryInterval, (_) => _sendDiscoveryBroadcast());
    
    // 定期清理过期设备
    _cleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) => _cleanupExpiredDevices());
    
    // 立即发送一次发现广播
    await _sendDiscoveryBroadcast();
    
    log('UDP设备发现已开始');
  }

  /// 停止设备发现
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;
    
    _isDiscovering = false;
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    log('UDP设备发现已停止');
  }

  /// 发送发现广播
  Future<void> _sendDiscoveryBroadcast() async {
    if (_socket == null || _currentDevice == null || _isDisposed) return;
    
    try {
      final message = {
        'type': _discoveryMessage,
        'device': _currentDevice!.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final data = utf8.encode(jsonEncode(message));
      
      // 获取广播地址
      final broadcastAddresses = await _getBroadcastAddresses();
      
      for (final address in broadcastAddresses) {
        try {
          _socket!.send(data, address, _broadcastPort);
        } catch (e) {
          log('发送广播到 $address 失败: $e');
        }
      }
      
      log('发送设备发现广播到 ${broadcastAddresses.length} 个地址');
    } catch (e) {
      log('发送发现广播失败: $e');
    }
  }

  /// 处理传入的消息
  void _handleIncomingMessage(RawSocketEvent event) {
    if (event == RawSocketEvent.read && _socket != null) {
      final datagram = _socket!.receive();
      if (datagram != null) {
        try {
          final message = utf8.decode(datagram.data);
          final data = jsonDecode(message) as Map<String, dynamic>;
          
          final type = data['type'] as String?;
          
          if (type == _discoveryMessage) {
            // 收到发现请求，发送响应
            _sendDiscoveryResponse(datagram.address);
          } else if (type == _responseMessage) {
            // 收到设备响应，添加到发现列表
            _handleDeviceResponse(data);
          }
        } catch (e) {
          log('处理传入消息失败: $e');
        }
      }
    }
  }

  /// 发送发现响应
  void _sendDiscoveryResponse(InternetAddress targetAddress) async {
    if (_socket == null || _currentDevice == null || _isDisposed) return;
    
    try {
      final message = {
        'type': _responseMessage,
        'device': _currentDevice!.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final data = utf8.encode(jsonEncode(message));
      _socket!.send(data, targetAddress, _broadcastPort);
      
      log('发送设备响应到: $targetAddress');
    } catch (e) {
      log('发送设备响应失败: $e');
    }
  }

  /// 处理设备响应
  void _handleDeviceResponse(Map<String, dynamic> data) {
    try {
      final deviceData = data['device'] as Map<String, dynamic>?;
      if (deviceData == null) return;
      
      final device = DeviceInfo.fromJson(deviceData);
      
      // 不添加自己
      if (device.id == _currentDevice?.id) return;
      
      // 更新设备信息
      _discoveredDevices[device.id] = device.copyWith(lastSeen: DateTime.now());
      _notifyDevicesChanged();
      
      log('发现设备: ${device.name} (${device.id})');
    } catch (e) {
      log('处理设备响应失败: $e');
    }
  }

  /// 获取广播地址列表
  Future<List<InternetAddress>> _getBroadcastAddresses() async {
    final addresses = <InternetAddress>[];
    
    try {
      final interfaces = await NetworkInterface.list();
      
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            // 计算广播地址
            final broadcastAddress = _calculateBroadcastAddress(address.address);
            if (broadcastAddress != null) {
              addresses.add(InternetAddress(broadcastAddress));
            }
          }
        }
      }
      
      // 如果没有找到特定的广播地址，使用通用广播地址
      if (addresses.isEmpty) {
        addresses.add(InternetAddress('255.255.255.255'));
      }
    } catch (e) {
      log('获取广播地址失败: $e');
      // 使用默认广播地址
      addresses.add(InternetAddress('255.255.255.255'));
    }
    
    return addresses;
  }

  /// 计算广播地址
  String? _calculateBroadcastAddress(String ipAddress) {
    try {
      final parts = ipAddress.split('.');
      if (parts.length != 4) return null;
      
      // 简单的C类网络广播地址计算
      return '${parts[0]}.${parts[1]}.${parts[2]}.255';
    } catch (e) {
      return null;
    }
  }

  /// 清理过期设备
  void _cleanupExpiredDevices() {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 1));
    final removedCount = _discoveredDevices.length;
    
    _discoveredDevices.removeWhere((id, device) => 
        device.lastSeen.isBefore(cutoffTime));
    
    final currentCount = _discoveredDevices.length;
    if (removedCount != currentCount) {
      _notifyDevicesChanged();
      log('清理了 ${removedCount - currentCount} 个过期设备');
    }
  }

  /// 通知设备列表变化
  void _notifyDevicesChanged() {
    if (!_devicesController.isClosed && !_isDisposed) {
      _devicesController.add(discoveredDevices);
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    try {
      await stopDiscovery();
      
      _socket?.close();
      _socket = null;
      
      if (!_devicesController.isClosed) {
        await _devicesController.close();
      }
      
      _discoveredDevices.clear();
      _isListening = false;
      
      log('UDP发现服务已释放');
    } catch (e) {
      log('释放UDP发现服务失败: $e');
    }
  }
}

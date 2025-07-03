import 'dart:async';
import 'dart:developer';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 隐私模式管理服务
class PrivacyService {
  static const String _activatedLibrariesKey = 'activated_libraries';
  static const String _passwordHashKey = 'password_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final StreamController<Set<String>> _activatedLibrariesController = 
      StreamController<Set<String>>.broadcast();
  
  /// 已激活的隐私库ID集合
  static Set<String> _activatedLibraries = {};
  
  /// 监听已激活的隐私库变化
  static Stream<Set<String>> get activatedLibrariesStream => 
      _activatedLibrariesController.stream;
  
  /// 获取当前已激活的隐私库
  static Set<String> get activatedLibraries => Set.from(_activatedLibraries);
  
  /// 初始化隐私服务
  static Future<void> initialize() async {
    // 应用启动时清空所有激活状态
    _activatedLibraries.clear();
    await _saveActivatedLibraries();
    _activatedLibrariesController.add(Set.from(_activatedLibraries));
  }
  
  /// 设置密码
  static Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hashPassword(password);
    await prefs.setString(_passwordHashKey, hash);
  }
  
  /// 验证密码
  static Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_passwordHashKey);
    if (storedHash == null) return false;
    
    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }
  
  /// 检查是否已设置密码
  static Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passwordHashKey);
  }
  
  /// 启用/禁用生物识别
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
  
  /// 检查是否启用生物识别
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  /// 检查设备是否支持生物识别
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e,stackTrace) {
      log('检查生物识别可用性失败: $e,堆栈:$stackTrace');
      return false;
    }
  }
  
  /// 获取可用的生物识别类型
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e,stackTrace) {
      log('获取生物识别类型失败: $e,堆栈:$stackTrace');
      return [];
    }
  }
  
  /// 使用生物识别验证
  static Future<bool> authenticateWithBiometric() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;
      
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: '请验证身份以访问隐私库',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return isAuthenticated;
    } catch (e,stackTrace) {
      log('生物识别验证失败: $e,堆栈:$stackTrace');
      return false;
    }
  }
  
  /// 激活隐私库
  static Future<bool> activatePrivateLibrary(String libraryId, {String? password}) async {
    try {
      bool authenticated = false;
      
      // 如果提供了密码，验证密码
      if (password != null) {
        authenticated = await verifyPassword(password);
      } else {
        // 尝试生物识别
        authenticated = await authenticateWithBiometric();
      }
      
      if (authenticated) {
        _activatedLibraries.add(libraryId);
        await _saveActivatedLibraries();
        _activatedLibrariesController.add(Set.from(_activatedLibraries));
        log('隐私库已激活: $libraryId');
        return true;
      }
      
      return false;
    } catch (e,stackTrace) {
      log('激活隐私库失败: $e,堆栈:$stackTrace');
      return false;
    }
  }
  
  /// 取消激活隐私库
  static Future<void> deactivatePrivateLibrary(String libraryId) async {
    _activatedLibraries.remove(libraryId);
    await _saveActivatedLibraries();
    _activatedLibrariesController.add(Set.from(_activatedLibraries));
    log('隐私库已取消激活: $libraryId');
  }
  
  /// 取消激活所有隐私库
  static Future<void> deactivateAllPrivateLibraries() async {
    _activatedLibraries.clear();
    await _saveActivatedLibraries();
    _activatedLibrariesController.add(Set.from(_activatedLibraries));
    log('所有隐私库已取消激活');
  }
  
  /// 检查隐私库是否已激活
  static bool isLibraryActivated(String libraryId) {
    return _activatedLibraries.contains(libraryId);
  }
  
  /// 应用进入后台时的处理
  static Future<void> onAppPaused() async {
    // 应用进入后台时不做任何处理，保持激活状态
    log('应用进入后台，隐私库保持激活状态');
  }
  
  /// 应用从后台恢复时的处理
  static Future<bool> onAppResumed() async {
    // 如果有激活的隐私库，需要重新验证
    if (_activatedLibraries.isNotEmpty) {
      log('应用从后台恢复，需要重新验证隐私库');
      return false; // 返回false表示需要重新验证
    }
    return true; // 没有激活的隐私库，无需验证
  }
  
  /// 应用重新启动时的处理
  static Future<void> onAppRestarted() async {
    // 应用重启时清空所有激活状态
    await initialize();
  }
  
  /// 保存已激活的隐私库到本地存储
  static Future<void> _saveActivatedLibraries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_activatedLibrariesKey, _activatedLibraries.toList());
  }

  
  /// 密码哈希
  static String _hashPassword(String password) {
    final bytes = utf8.encode('${password}manhua_reader_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 清理资源
  static void dispose() {
    _activatedLibrariesController.close();
  }
}
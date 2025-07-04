import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  static const String _passwordPrefix = 'library_password_';
  static const String _biometricPrefix = 'library_biometric_';
  static const String _activationPrefix = 'library_activation_';

  // 设置漫画库密码
  static Future<void> setLibraryPassword(String libraryId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPassword = _hashPassword(password);
    await prefs.setString('$_passwordPrefix$libraryId', hashedPassword);
  }

  // 验证漫画库密码
  static Future<bool> verifyLibraryPassword(String libraryId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('$_passwordPrefix$libraryId');
    if (storedHash == null) return false;

    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }

  // 检查漫画库是否设置了密码
  static Future<bool> hasLibraryPassword(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_passwordPrefix$libraryId');
  }

  // 移除漫画库密码
  static Future<void> removeLibraryPassword(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_passwordPrefix$libraryId');
  }

  // 设置漫画库生物识别
  static Future<void> setLibraryBiometric(String libraryId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_biometricPrefix$libraryId', enabled);
  }

  // 检查漫画库是否启用生物识别
  static Future<bool> isLibraryBiometricEnabled(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_biometricPrefix$libraryId') ?? false;
  }

  // 移除漫画库生物识别设置
  static Future<void> removeLibraryBiometric(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_biometricPrefix$libraryId');
  }

  // 设置漫画库隐私激活状态
  static Future<void> setLibraryActivationStatus(String libraryId, bool activated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_activationPrefix$libraryId', activated);
  }

  // 获取漫画库隐私激活状态
  static Future<bool> getLibraryActivationStatus(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_activationPrefix$libraryId') ?? false;
  }

  // 重置漫画库隐私激活状态
  static Future<void> resetLibraryActivationStatus(String libraryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_activationPrefix$libraryId');
  }

  // 清除漫画库所有隐私设置
  static Future<void> clearLibraryPrivacySettings(String libraryId) async {
    await removeLibraryPassword(libraryId);
    await removeLibraryBiometric(libraryId);
    await resetLibraryActivationStatus(libraryId);
  }

  // 获取漫画库隐私验证方式
  static Future<PrivacyAuthMethod> getLibraryAuthMethod(String libraryId) async {
    final hasBiometric = await isLibraryBiometricEnabled(libraryId);
    if (hasBiometric) {
      return PrivacyAuthMethod.biometric;
    }

    final hasPassword = await hasLibraryPassword(libraryId);
    if (hasPassword) {
      return PrivacyAuthMethod.password;
    }

    return PrivacyAuthMethod.none;
  }

  // 检查漫画库是否需要隐私验证
  static Future<bool> requiresPrivacyAuth(String libraryId) async {
    final authMethod = await getLibraryAuthMethod(libraryId);
    if (authMethod == PrivacyAuthMethod.none) {
      return false;
    }

    // 检查是否已经验证过
    final isActivated = await getLibraryActivationStatus(libraryId);
    return !isActivated;
  }

  // 密码哈希函数
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

enum PrivacyAuthMethod {
  none,
  password,
  biometric,
}

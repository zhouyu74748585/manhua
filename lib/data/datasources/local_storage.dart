import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage.g.dart';

@riverpod
LocalStorage localStorage(LocalStorageRef ref) {
  return SharedPreferencesStorage();
}

abstract class LocalStorage {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> setList(String key, List<dynamic> value);
  Future<List<dynamic>?> getList(String key);
  Future<void> setMap(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getMap(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
}

class SharedPreferencesStorage implements LocalStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> setString(String key, String value) async {
    final preferences = await prefs;
    await preferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final preferences = await prefs;
    return preferences.getString(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final preferences = await prefs;
    await preferences.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final preferences = await prefs;
    return preferences.getInt(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final preferences = await prefs;
    await preferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final preferences = await prefs;
    return preferences.getBool(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    final preferences = await prefs;
    await preferences.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    final preferences = await prefs;
    return preferences.getDouble(key);
  }

  @override
  Future<void> setList(String key, List<dynamic> value) async {
    final preferences = await prefs;
    final jsonString = jsonEncode(value);
    await preferences.setString(key, jsonString);
  }

  @override
  Future<List<dynamic>?> getList(String key) async {
    final preferences = await prefs;
    final jsonString = preferences.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e,stackTrace) {
      return null;
    }
  }

  @override
  Future<void> setMap(String key, Map<String, dynamic> value) async {
    final preferences = await prefs;
    final jsonString = jsonEncode(value);
    await preferences.setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getMap(String key) async {
    final preferences = await prefs;
    final jsonString = preferences.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e,stackTrace) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    final preferences = await prefs;
    await preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    final preferences = await prefs;
    await preferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    final preferences = await prefs;
    return preferences.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    final preferences = await prefs;
    return preferences.getKeys();
  }
}

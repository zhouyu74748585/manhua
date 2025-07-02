import '../constants/app_constants.dart';

class StorageService {
  // 内存存储，用于演示
  static final Map<String, dynamic> _storage = {};

  // 初始化存储服务
  static Future<void> init() async {
    // 简化版本，不需要初始化
  }

  // 设置相关
  static Future<void> setThemeMode(String themeMode) async {
    _storage[AppConstants.themeKey] = themeMode;
  }

  static String getThemeMode() {
    return _storage[AppConstants.themeKey] ?? 'system';
  }

  static Future<void> setLanguage(String language) async {
    _storage[AppConstants.languageKey] = language;
  }

  static String getLanguage() {
    return _storage[AppConstants.languageKey] ?? 'zh_CN';
  }

  // 阅读器设置
  static Future<void> setReaderSettings(Map<String, dynamic> settings) async {
    _storage[AppConstants.readerSettingsKey] = settings;
  }

  static Map<String, dynamic> getReaderSettings() {
    return Map<String, dynamic>.from(
      _storage[AppConstants.readerSettingsKey] ??
          {
            'readingMode': 'single',
            'readingDirection': 'leftToRight',
            'imageFitMode': 'fitWidth',
            'zoomLevel': 1.0,
            'showPageNumber': true,
            'fullScreenMode': false,
            'keepScreenOn': true,
            'backgroundColor': 'black',
          },
    );
  }

  // 漫画库设置
  static Future<void> setLibraries(List<Map<String, dynamic>> libraries) async {
    _storage[AppConstants.librariesKey] = libraries;
  }

  static List<Map<String, dynamic>> getLibraries() {
    final libraries =
        _storage[AppConstants.librariesKey] ?? <Map<String, dynamic>>[];
    return List<Map<String, dynamic>>.from(libraries);
  }

  // 阅读进度
  static Future<void> setReadingProgress(
      String mangaId, Map<String, dynamic> progress) async {
    final allProgress = getReadingProgress();
    allProgress[mangaId] = progress;
    _storage[AppConstants.readingProgressKey] = allProgress;
  }

  static Map<String, dynamic> getReadingProgress() {
    return Map<String, dynamic>.from(
      _storage[AppConstants.readingProgressKey] ?? <String, dynamic>{},
    );
  }

  static Map<String, dynamic>? getMangaProgress(String mangaId) {
    final allProgress = getReadingProgress();
    return allProgress[mangaId] != null
        ? Map<String, dynamic>.from(allProgress[mangaId])
        : null;
  }

  // 缓存管理
  static Future<void> setCacheData(String key, dynamic data) async {
    _storage['cache_$key'] = data;
  }

  static T? getCacheData<T>(String key) {
    return _storage['cache_$key'];
  }

  static Future<void> removeCacheData(String key) async {
    _storage.remove('cache_$key');
  }

  static Future<void> clearCache() async {
    _storage.removeWhere((key, value) => key.startsWith('cache_'));
  }

  // 简化的存储方法
  static Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  static String? getString(String key) {
    return _storage[key];
  }

  static Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  static int? getInt(String key) {
    return _storage[key];
  }

  static Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  static bool? getBool(String key) {
    return _storage[key];
  }

  static Future<void> setDouble(String key, double value) async {
    _storage[key] = value;
  }

  static double? getDouble(String key) {
    return _storage[key];
  }

  static Future<void> setStringList(String key, List<String> value) async {
    _storage[key] = value;
  }

  static List<String>? getStringList(String key) {
    return _storage[key]?.cast<String>();
  }

  static Future<void> remove(String key) async {
    _storage.remove(key);
  }

  static Future<void> clear() async {
    _storage.clear();
  }

  // 获取所有键
  static Set<String> getKeys() {
    return _storage.keys.toSet();
  }

  // 检查键是否存在
  static bool containsKey(String key) {
    return _storage.containsKey(key);
  }

  // 清理过期缓存
  static Future<void> cleanExpiredCache() async {
    final now = DateTime.now();
    final keysToDelete = <String>[];

    for (final key in _storage.keys) {
      if (key.startsWith('cache_')) {
        final data = _storage[key];
        if (data is Map && data.containsKey('expiry')) {
          final expiry = DateTime.parse(data['expiry']);
          if (now.isAfter(expiry)) {
            keysToDelete.add(key);
          }
        }
      }
    }

    for (final key in keysToDelete) {
      _storage.remove(key);
    }
  }

  // 获取存储使用情况
  static Map<String, int> getStorageInfo() {
    final cacheCount =
        _storage.keys.where((key) => key.startsWith('cache_')).length;
    return {
      'totalCount': _storage.length,
      'cacheCount': cacheCount,
      'settingsCount': _storage.length - cacheCount,
    };
  }
}

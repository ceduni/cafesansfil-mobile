import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _prefs;

  // Ensure SharedPreferences is initialized only once (Singleton Pattern)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save data to cache
  static Future<bool> saveToCache<T>(String key, T value) async {
    await init(); // Ensure SharedPreferences is initialized

    if (value is String) {
      return _prefs!.setString(key, value);
    } else if (value is int) {
      return _prefs!.setInt(key, value);
    } else if (value is double) {
      return _prefs!.setDouble(key, value);
    } else if (value is bool) {
      return _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      return _prefs!.setStringList(key, value);
    } else {
      throw ArgumentError('Unsupported type for SharedPreferences');
    }
  }

  // Retrieve data from cache
  static T? getFromCache<T>(String key) {
    if (_prefs == null) return null; // Prevents null errors if not initialized

    if (T == String) return _prefs!.getString(key) as T?;
    if (T == int) return _prefs!.getInt(key) as T?;
    if (T == double) return _prefs!.getDouble(key) as T?;
    if (T == bool) return _prefs!.getBool(key) as T?;
    if (T == List<String>) return _prefs!.getStringList(key) as T?;

    return null;
  }

  // Remove a specific cache item
  static Future<bool> clearCache(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  // Clear all cache data
  static Future<bool> clearAllCache() async {
    await init();
    return _prefs!.clear();
  }
}

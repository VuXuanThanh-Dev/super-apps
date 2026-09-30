import 'package:shared_preferences/shared_preferences.dart';

/// Lưu cặp key-value nhỏ (cài đặt). Interface để test dùng bản trong bộ nhớ.
abstract interface class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// Bản thật: shared_preferences (NSUserDefaults trên iOS, SharedPreferences/DataStore trên Android,
/// localStorage trên web). Dùng API `SharedPreferencesAsync` (mọi lời gọi đều async).
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore([SharedPreferencesAsync? prefs]) : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Bản trong bộ nhớ (test, hoặc khi chưa cần lưu bền).
class MemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kho lưu bí mật. Bản thật: Keychain (iOS) / Keystore + AES-GCM (Android) / WebCrypto (web, chỉ HTTPS hoặc localhost).
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Chỉ đọc được sau khi máy mở khóa lần đầu kể từ lúc khởi động (README: IOSOptions.accessibility).
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Bản trong bộ nhớ cho test.
class MemorySecureStore implements SecureStore {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

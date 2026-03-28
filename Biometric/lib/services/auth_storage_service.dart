import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages all secure storage operations
class AuthStorageService {
  static const _keyMode = 'auth_mode';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyPasswordHash = 'password_hash';

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> readMode() => _secureStorage.read(key: _keyMode);
  Future<String?> readUsername() => _secureStorage.read(key: _keyUsername);
  Future<String?> readPassword() => _secureStorage.read(key: _keyPassword);
  Future<String?> readPasswordHash() => _secureStorage.read(key: _keyPasswordHash);

  Future<void> writeMode(String value) =>
      _secureStorage.write(key: _keyMode, value: value);
  Future<void> writeUsername(String value) =>
      _secureStorage.write(key: _keyUsername, value: value);
  Future<void> writePassword(String value) =>
      _secureStorage.write(key: _keyPassword, value: value);
  Future<void> writePasswordHash(String value) =>
      _secureStorage.write(key: _keyPasswordHash, value: value);

  Future<void> deleteMode() => _secureStorage.delete(key: _keyMode);
  Future<void> deletePassword() => _secureStorage.delete(key: _keyPassword);
  Future<void> deletePasswordHash() => _secureStorage.delete(key: _keyPasswordHash);
}

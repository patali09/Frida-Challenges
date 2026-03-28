import 'package:local_auth/local_auth.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Handles secure biometric authentication with encrypted storage
class SecureAuthService {
  static const _secureVault = 'secure_biometric_vault';
  static const _keyPasswordHash = 'password_hash';

  final _localAuth = LocalAuthentication();

  /// Authenticate using device biometrics
  Future<bool> authenticateBiometric(String reason) async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final hasBiometric = await _localAuth.canCheckBiometrics;

      if (!supported || !hasBiometric) {
        return false;
      }

      return _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Enroll secure credentials with biometric protection
  Future<void> enrollSecure({
    required String username,
    required String password,
    required Function(String key, String value) saveToStorage,
  }) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    // Save hash to secure storage
    await saveToStorage(_keyPasswordHash, passwordHash);

    // Save credentials to biometric-protected file
    final secureFile = await BiometricStorage().getStorage(
      _secureVault,
      options: StorageFileInitOptions(authenticationRequired: true),
    );

    await secureFile.write(
      jsonEncode({'username': username, 'password': password}),
    );
  }

  /// Validate credentials against stored hash
  Future<bool> validateSecureCredentials({
    required String inputPassword,
    required String storedHash,
  }) async {
    final inputHash = sha256.convert(utf8.encode(inputPassword)).toString();
    return storedHash == inputHash;
  }

  /// Login with biometric and retrieve credentials from secure storage
  Future<Map<String, String>?> biometricLogin({
    required String storedUsername,
    required String storedHash,
  }) async {
    try {
      final secureFile = await BiometricStorage().getStorage(
        _secureVault,
        options: StorageFileInitOptions(authenticationRequired: true),
      );
      final secureData = await secureFile.read();

      if (secureData == null || secureData.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(secureData) as Map<String, dynamic>;
      final secureUsername = (decoded['username'] as String?) ?? '';
      final securePassword = (decoded['password'] as String?) ?? '';

      // Validate stored credentials
      final secureHash = sha256.convert(utf8.encode(securePassword)).toString();

      if (storedUsername != secureUsername || storedHash != secureHash) {
        return null;
      }

      return {'username': secureUsername, 'password': securePassword};
    } catch (_) {
      return null;
    }
  }
}

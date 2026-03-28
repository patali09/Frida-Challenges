import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Handles less-secure biometric authentication with plaintext credentials
/// WARNING: This stores credentials in plaintext in secure storage
/// Use SecureAuthService for production applications
class InsecureAuthService {
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

  /// Enroll bypassable credentials (stored in plaintext)
  Future<void> enrollBypassable({
    required String username,
    required String password,
    required Function(String key, String value) saveToStorage,
    required Function(String key) deleteFromStorage,
  }) async {
    await saveToStorage('username', username);
    await saveToStorage('password', password);
    // Remove hash if it exists
    await deleteFromStorage('password_hash');
  }

  /// Validate bypassable credentials
  bool validateBypassableCredentials({
    required String inputUsername,
    required String inputPassword,
    required String storedUsername,
    required String storedPassword,
  }) {
    return inputUsername == storedUsername && inputPassword == storedPassword;
  }

  /// Retrieve stored bypassable credentials after biometric auth
  Future<Map<String, String>?> biometricLogin({
    required String? storedUsername,
    required String? storedPassword,
  }) async {
    if (storedUsername == null || storedPassword == null) {
      return null;
    }

    return {'username': storedUsername, 'password': storedPassword};
  }
}

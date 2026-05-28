import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'hash_service.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static const _keyAppPasswordHash = 'app_password_hash';
  static const _keyDbEncryption = 'db_encryption_key';
  static const _keyBiometricsEnabled = 'biometrics_enabled';

  /// Sets whether biometrics are enabled
  static Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricsEnabled, value: enabled.toString());
  }

  /// Checks if biometrics are enabled
  static Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: _keyBiometricsEnabled);
    return value == 'true';
  }

  /// Sets the application password. 
  /// It stores a SHA-256 hash of the password, not the plain text.
  static Future<void> setAppPassword(String rawPassword) async {
    final hash = HashService.generateSha256(rawPassword);
    await _storage.write(key: _keyAppPasswordHash, value: hash);
  }

  /// Verifies the entered password against the stored hash.
  static Future<bool> verifyPassword(String rawPassword) async {
    final storedHash = await _storage.read(key: _keyAppPasswordHash);
    if (storedHash == null) return false;
    
    final inputHash = HashService.generateSha256(rawPassword);
    return inputHash == storedHash;
  }

  /// Checks if a password has been set up for the app.
  static Future<bool> hasPassword() async {
    final storedHash = await _storage.read(key: _keyAppPasswordHash);
    return storedHash != null && storedHash.isNotEmpty;
  }

  /// Removes the application password
  static Future<void> removePassword() async {
    await _storage.delete(key: _keyAppPasswordHash);
  }

  /// Generates and/or retrieves a strong encryption key for SQLCipher.
  /// Uses cryptographically secure random bytes instead of predictable DateTime.
  static Future<String> getDatabaseEncryptionKey() async {
    var key = await _storage.read(key: _keyDbEncryption);
    if (key == null) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(keyBytes);
      await _storage.write(key: _keyDbEncryption, value: key);
    }
    return key;
  }
}

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'hash_service.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _storageTimeout = Duration(seconds: 4);

  static const _keyAppPasswordHash = 'app_password_hash';
  static const _keyDbEncryption = 'db_encryption_key';
  static const _keyBiometricsEnabled = 'biometrics_enabled';

  /// Clears secure storage on the very first run after installation to prevent
  /// using data (like passwords/FaceID) that persisted in the OS Keychain from a previous install.
  static Future<void> initializeOnFirstRun() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final firstRunFile = File('${docsDir.path}/.first_run_done');
      if (!await firstRunFile.exists()) {
        if (!await _databaseExists()) {
          await _storage.deleteAll();
        }
        await firstRunFile.writeAsString('done');
      }
    } catch (e) {
      // Ignore errors for this setup
    }
  }

  /// Sets whether biometrics are enabled
  static Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricsEnabled, value: enabled.toString());
  }

  /// Checks if biometrics are enabled
  static Future<bool> isBiometricsEnabled() async {
    try {
      final value = await _storage
          .read(key: _keyBiometricsEnabled)
          .timeout(_storageTimeout);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Sets the application password.
  /// It stores a SHA-256 hash of the password, not the plain text.
  static Future<void> setAppPassword(String rawPassword) async {
    if (rawPassword.length < 4) {
      throw ArgumentError.value(
        rawPassword,
        'rawPassword',
        'Password must be at least 4 characters.',
      );
    }
    final hash = HashService.generateSha256(rawPassword);
    await _storage.write(key: _keyAppPasswordHash, value: hash);
  }

  /// Verifies the entered password against the stored hash.
  static Future<bool> verifyPassword(String rawPassword) async {
    final storedHash = await _storage
        .read(key: _keyAppPasswordHash)
        .timeout(_storageTimeout);
    if (storedHash == null) return false;

    final inputHash = HashService.generateSha256(rawPassword);
    return inputHash == storedHash;
  }

  /// Checks if a password has been set up for the app.
  static Future<bool> hasPassword() async {
    final storedHash = await _storage
        .read(key: _keyAppPasswordHash)
        .timeout(_storageTimeout);
    return storedHash != null && storedHash.isNotEmpty;
  }

  /// Removes the application password
  static Future<void> removePassword() async {
    await _storage.delete(key: _keyAppPasswordHash);
    await _storage.delete(key: _keyBiometricsEnabled);
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

  static Future<bool> _databaseExists() async {
    final candidates = <File>[];
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      candidates.add(File(p.join(docsDir.path, 'dexter_app.db')));
    } catch (_) {}
    try {
      final supportDir = await getApplicationSupportDirectory();
      candidates.add(File(p.join(supportDir.path, 'dexter_app.db')));
    } catch (_) {}
    try {
      candidates.add(
        File(
          p.join(
            File(Platform.resolvedExecutable).parent.path,
            'dexter_app.db',
          ),
        ),
      );
    } catch (_) {}

    for (final file in candidates) {
      if (await file.exists()) return true;
    }
    return false;
  }
}

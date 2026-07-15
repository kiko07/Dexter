import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class HashService {
  /// Generates a SHA-256 hash for a given string input.
  /// Used primarily for hashing deduplication keys and file contents.
  static String generateSha256(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hashes an entire file using SHA-256 via streaming to avoid OOM on large files.
  static Future<String> hashFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return '';

    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}

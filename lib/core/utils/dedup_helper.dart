import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import 'arabic_normalizer.dart';

class DedupHelper {
  static const Set<String> metadataKeys = {'_rowIndex', '_sheetName'};

  /// Returns a copy of [data] without import metadata fields.
  static Map<String, dynamic> stripMetadataForDedup(Map<String, dynamic> data) {
    final clean = Map<String, dynamic>.from(data);
    for (final key in metadataKeys) {
      clean.remove(key);
    }
    return clean;
  }

  /// Builds a quoted JSON path segment safe for SQLite json_extract.
  static String quoteJsonPath(String key) {
    final escaped = key
        .replaceAll('\\', '\\\\')
        .replaceAll('"', r'\"')
        .replaceAll("'", "''");
    return '\$."$escaped"';
  }

  /// Normalizes a value for dedup comparison.
  static String normalizeForDedup(String value) {
    var val = arabicNormalize(value);
    // Strip commas from numbers
    val = val.replaceAll(',', '');
    return val;
  }

  /// Normalizes a full map payload for fallback deduplication.
  static String normalizePayloadForDedup(Map<String, dynamic> cleanMap) {
    final data = stripMetadataForDedup(cleanMap);
    final fields =
        data.entries
            .map(
              (entry) => MapEntry(
                entry.key,
                normalizeForDedup(entry.value?.toString() ?? ''),
              ),
            )
            .where((entry) => entry.value.isNotEmpty)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    if (fields.isEmpty) return '';

    // JSON keeps field boundaries intact, unlike a delimiter-joined value
    // list, and including field names prevents swapped columns from being
    // treated as the same record.
    return jsonEncode([
      for (final field in fields) [field.key, field.value],
    ]);
  }

  /// Builds the set of existing dedup keys for a given profile.
  static Future<Set<String>> buildDedupSet(
    AppDatabase db,
    int profileId,
    String? dedupKeyField,
  ) async {
    final Set<String> existingKeys = {};

    if (dedupKeyField != null) {
      final jsonPath = quoteJsonPath(dedupKeyField);
      final rows = await db
          .customSelect(
            "SELECT json_extract(data, '$jsonPath') as val FROM entries WHERE profile_id = ? AND json_extract(data, '$jsonPath') IS NOT NULL",
            variables: [drift.Variable.withInt(profileId)],
          )
          .get();

      for (final row in rows) {
        final val = row.data['val']?.toString();
        if (val != null) {
          existingKeys.add(normalizeForDedup(val));
        }
      }
    } else {
      final rows = await db
          .customSelect(
            'SELECT data FROM entries WHERE profile_id = ?',
            variables: [drift.Variable.withInt(profileId)],
          )
          .get();

      for (final row in rows) {
        try {
          final data = (jsonDecode(row.read<String>('data')) as Map)
              .cast<String, dynamic>();
          final key = normalizePayloadForDedup(data);
          if (key.isNotEmpty) existingKeys.add(key);
        } catch (_) {
          // Ignore malformed legacy rows; they should not prevent imports.
        }
      }
    }

    return existingKeys;
  }
}

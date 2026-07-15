import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';
import 'daos/entries_dao.dart';
import 'daos/profiles_dao.dart';
import 'daos/batches_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/audit_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ImportProfiles, Entries, ImportBatches, AuditLog, AppSettings],
  daos: [EntriesDao, ProfilesDao, BatchesDao, SettingsDao, AuditDao],
)
class AppDatabase extends _$AppDatabase {
  final String? encryptionKey;

  AppDatabase({this.encryptionKey}) : super(_openConnection(encryptionKey));
  AppDatabase.forTesting(super.e) : encryptionKey = null;

  Future<void> clearAllData() async {
    await transaction(() async {
      await customStatement('PRAGMA foreign_keys = OFF;');
      try {
        await delete(entries).go();
        await delete(importBatches).go();
        await delete(importProfiles).go();
        await delete(auditLog).go();
        await delete(appSettings).go();
        await customStatement('DELETE FROM entries_fts;');
        await customStatement(
          "DELETE FROM sqlite_sequence WHERE name IN ('entries','import_batches','import_profiles','audit_log');",
        );
      } finally {
        await customStatement('PRAGMA foreign_keys = ON;');
      }
    });
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Create FTS5 Virtual Table
        await customStatement('''
          CREATE VIRTUAL TABLE entries_fts USING fts5(
            search_payload,
            content='entries',
            content_rowid='id'
          );
        ''');

        // Create Triggers to keep FTS5 up to date
        await customStatement('''
          CREATE TRIGGER after_entry_insert AFTER INSERT ON entries BEGIN
            INSERT INTO entries_fts(rowid, search_payload)
            VALUES (NEW.id, NEW.search_payload);
          END;
        ''');

        await customStatement('''
          CREATE TRIGGER after_entry_update AFTER UPDATE ON entries BEGIN
            DELETE FROM entries_fts WHERE rowid = OLD.id;
            INSERT INTO entries_fts(rowid, search_payload) VALUES (NEW.id, NEW.search_payload);
          END;
        ''');

        // Create indexes for performance on common query patterns
        await customStatement(
          'CREATE INDEX idx_entries_profile ON entries(profile_id);',
        );
        await customStatement(
          'CREATE INDEX idx_entries_batch ON entries(import_batch_id);',
        );

        await customStatement('''
          CREATE TRIGGER after_entry_delete AFTER DELETE ON entries BEGIN
            DELETE FROM entries_fts WHERE rowid = OLD.id;
          END;
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Implement migrations here in future phases
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA journal_mode=WAL;');
        await customStatement('PRAGMA synchronous=NORMAL;');
      },
    );
  }
}

LazyDatabase _openConnection(String? encryptionKey) {
  return LazyDatabase(() async {
    final file = await _databaseFile();
    await _moveLegacyDesktopDatabase(file);
    final effectiveEncryptionKey = await _effectiveEncryptionKeyForDatabase(
      file,
      encryptionKey,
    );

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        if (effectiveEncryptionKey != null &&
            effectiveEncryptionKey.isNotEmpty) {
          final escaped = effectiveEncryptionKey.replaceAll("'", "''");
          db.execute("PRAGMA key = '$escaped';");
          final cipherVersion = db.select('PRAGMA cipher_version;');
          if (cipherVersion.isEmpty) {
            throw StateError('SQLite cipher support is not available.');
          }
          db.select('SELECT count(*) FROM sqlite_master;');
        }
      },
    );
  });
}

Future<File> _databaseFile() async {
  final String dbFolder;
  if (Platform.isAndroid || Platform.isIOS) {
    dbFolder = (await getApplicationDocumentsDirectory()).path;
  } else {
    final supportDir = await getApplicationSupportDirectory();
    await supportDir.create(recursive: true);
    dbFolder = supportDir.path;
  }
  return File(p.join(dbFolder, 'dexter_app.db'));
}

Future<String?> _effectiveEncryptionKeyForDatabase(
  File file,
  String? encryptionKey,
) async {
  if (encryptionKey == null || encryptionKey.isEmpty) return null;
  if (await file.exists() && await _hasPlainSqliteHeader(file)) {
    return null;
  }
  return encryptionKey;
}

Future<bool> _hasPlainSqliteHeader(File file) async {
  const sqliteHeader = 'SQLite format 3\u0000';
  RandomAccessFile? handle;
  try {
    handle = await file.open();
    if (await handle.length() < sqliteHeader.length) return false;
    final bytes = await handle.read(sqliteHeader.length);
    return String.fromCharCodes(bytes) == sqliteHeader;
  } catch (_) {
    return false;
  } finally {
    await handle?.close();
  }
}

Future<void> _moveLegacyDesktopDatabase(File target) async {
  if (Platform.isAndroid || Platform.isIOS) return;
  if (await target.exists()) return;

  final legacy = File(
    p.join(File(Platform.resolvedExecutable).parent.path, 'dexter_app.db'),
  );
  if (!await legacy.exists()) return;

  await target.parent.create(recursive: true);
  await legacy.copy(target.path);
  await legacy.rename('${legacy.path}.migrated.bak');
}

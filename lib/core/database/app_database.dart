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
    await customStatement('PRAGMA foreign_keys = OFF;');
    await delete(entries).go();
    await delete(importBatches).go();
    await delete(importProfiles).go();
    await delete(auditLog).go();
    await delete(appSettings).go();
    // Also clear the FTS5 virtual table to keep it in sync
    await customStatement("DELETE FROM entries_fts;");
    await customStatement('PRAGMA foreign_keys = ON;');
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
        await customStatement('CREATE INDEX idx_entries_profile ON entries(profile_id);');
        await customStatement('CREATE INDEX idx_entries_batch ON entries(import_batch_id);');

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
    String dbFolder;
    if (Platform.isAndroid || Platform.isIOS) {
      dbFolder = (await getApplicationDocumentsDirectory()).path;
    } else {
      dbFolder = File(Platform.resolvedExecutable).parent.path;
    }
    final file = File(p.join(dbFolder, 'dexter_app.db'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file, setup: (db) {
      if (encryptionKey != null && encryptionKey.isNotEmpty) {
        db.execute("PRAGMA key = '$encryptionKey';");
      }
    });
  });
}

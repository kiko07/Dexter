import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dexter/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('EntriesDao can insert and search exact', () async {
    final profileId = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(
        name: 'Test Profile',
        columnMap: '{}',
      )
    );

    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: profileId,
        data: '{"name": "Ali"}',
        searchPayload: 'ali',
      )
    );

    final results = await db.entriesDao.searchEntries(
      query: 'ali',
      matchMode: 'exact',
    );

    expect(results.length, 1);
    expect(results.first.searchPayload, 'ali');
  });

  test('AuditDao can log and retrieve actions', () async {
    await db.auditDao.insertLog(
      AuditLogCompanion.insert(
        action: 'TEST_ACTION',
        description: 'Test description',
      )
    );

    final logs = await db.auditDao.getAllLogs();
    expect(logs.length, 1);
    expect(logs.first.action, 'TEST_ACTION');
  });
}

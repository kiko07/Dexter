import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/core/database/search_criteria.dart';
import 'package:dexter/core/utils/dedup_helper.dart';

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
      ImportProfilesCompanion.insert(name: 'Test Profile', columnMap: '{}'),
    );

    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: profileId,
        data: '{"name": "Ali"}',
        searchPayload: 'ali',
      ),
    );

    final results = await db.entriesDao.searchEntries(
      query: 'ali',
      matchMode: 'exact',
    );

    expect(results.length, 1);
    expect(results.first.searchPayload, 'ali');
  });

  test(
    'exact search matches whole JSON field while contains matches substrings',
    () async {
      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'People', columnMap: '{}'),
      );
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: profileId,
          data: '{"name":"Ali"}',
          searchPayload: 'ali cairo',
        ),
      );

      final exactSubstring = await db.entriesDao.searchEntries(
        query: 'li',
        matchMode: 'exact',
      );
      final containsSubstring = await db.entriesDao.searchEntries(
        query: 'li',
        matchMode: 'contains',
      );
      final exactField = await db.entriesDao.searchEntries(
        query: 'Ali',
        matchMode: 'exact',
      );

      expect(exactSubstring, isEmpty);
      expect(containsSubstring, hasLength(1));
      expect(exactField, hasLength(1));
    },
  );

  test('contains searches treat SQL wildcard characters literally', () async {
    final profileId = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(name: 'Wildcards', columnMap: '{}'),
    );
    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: profileId,
        data: '{"value":"100%_done"}',
        searchPayload: '100%_done',
      ),
    );
    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: profileId,
        data: '{"value":"100 percent done"}',
        searchPayload: '100 percent done',
      ),
    );

    expect(
      await db.entriesDao.searchEntries(query: '%_', matchMode: 'contains'),
      hasLength(1),
    );
    expect(
      await db.entriesDao.searchEntries(
        query: '',
        matchMode: 'contains',
        filters: const [
          EntrySearchFilter(
            fieldName: 'value',
            operator: 'contains',
            value: '%_',
          ),
        ],
      ),
      hasLength(1),
    );
  });

  test(
    'numeric filters reject non-numeric fields and accept separators',
    () async {
      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'Numbers', columnMap: '{}'),
      );
      for (final value in ['abc', '0', '1,000']) {
        await db.entriesDao.insertEntry(
          EntriesCompanion.insert(
            profileId: profileId,
            data: '{"score":"$value"}',
            searchPayload: value,
          ),
        );
      }

      final aboveNegative = await db.entriesDao.searchEntries(
        query: '',
        matchMode: 'contains',
        filters: const [
          EntrySearchFilter(fieldName: 'score', operator: 'gt', value: '-1'),
        ],
      );
      final above999 = await db.entriesDao.searchEntries(
        query: '',
        matchMode: 'contains',
        filters: const [
          EntrySearchFilter(fieldName: 'score', operator: 'gt', value: '999'),
        ],
      );

      expect(aboveNegative.map((entry) => entry.searchPayload), ['0', '1,000']);
      expect(above999.map((entry) => entry.searchPayload), ['1,000']);
    },
  );

  test('dedup sets use stored JSON and support numeric key values', () async {
    final fallbackProfileId = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(name: 'Fallback', columnMap: '{}'),
    );
    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: fallbackProfileId,
        data: '{"name":"Ali Hassan","city":"Cairo","_sheetName":"One"}',
        searchPayload: 'ali hassan cairo',
      ),
    );

    final fallbackKeys = await DedupHelper.buildDedupSet(
      db,
      fallbackProfileId,
      null,
    );
    expect(
      fallbackKeys,
      contains(
        DedupHelper.normalizePayloadForDedup({
          'city': 'Cairo',
          'name': 'Ali Hassan',
          '_sheetName': 'Two',
          '_rowIndex': '99',
        }),
      ),
    );

    final keyedProfileId = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(
        name: 'Keyed',
        columnMap: '{}',
        dedupKeyField: const drift.Value('code'),
      ),
    );
    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: keyedProfileId,
        data: '{"code":123}',
        searchPayload: '123',
      ),
    );

    expect(
      await DedupHelper.buildDedupSet(db, keyedProfileId, 'code'),
      contains('123'),
    );
  });

  test(
    'filter-only and manual-only searches count the same rows they return',
    () async {
      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'Metrics', columnMap: '{}'),
      );
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: profileId,
          data: '{"name":"A","age":"40"}',
          searchPayload: 'a 40',
        ),
      );
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: profileId,
          data: '{"name":"B","age":"20"}',
          searchPayload: 'b 20',
          sourceFile: const drift.Value('file.xlsx'),
        ),
      );

      const filters = [
        EntrySearchFilter(fieldName: 'age', operator: 'gt', value: '30'),
      ];
      final filtered = await db.entriesDao.searchEntries(
        query: '',
        matchMode: 'contains',
        filters: filters,
      );
      final filteredCount = await db.entriesDao.countSearchEntries(
        query: '',
        matchMode: 'contains',
        filters: filters,
      );
      final manualOnly = await db.entriesDao.searchEntries(
        query: '',
        matchMode: 'contains',
        manualOnly: true,
      );

      expect(filtered, hasLength(1));
      expect(filteredCount, 1);
      expect(manualOnly, hasLength(1));
      expect(manualOnly.single.sourceFile, isNull);
    },
  );

  test(
    'advanced filters support text list presence date length and any-field negatives',
    () async {
      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'Advanced', columnMap: '{}'),
      );
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: profileId,
          data:
              '{"name":"Ali","city":"Cairo","note":"","joined":"2024-05-10","tags":"gold premium","score":"88"}',
          searchPayload: 'ali cairo gold premium 88',
        ),
      );
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: profileId,
          data:
              '{"name":"Mona","city":"Alexandria","joined":"2026-01-03","tags":"silver","score":"52"}',
          searchPayload: 'mona alexandria silver 52',
        ),
      );

      Future<List<String>> payloads(EntrySearchFilter filter) async {
        final rows = await db.entriesDao.searchEntries(
          query: '',
          matchMode: 'contains',
          filters: [filter],
        );
        return rows.map((entry) => entry.searchPayload).toList();
      }

      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'city',
            operator: 'startsWith',
            value: 'cai',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'city',
            operator: 'endsWith',
            value: 'ria',
          ),
        ),
        ['mona alexandria silver 52'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'tags',
            operator: 'containsAll',
            value: 'gold premium',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'tags',
            operator: 'containsAny',
            value: 'bronze silver',
          ),
        ),
        ['mona alexandria silver 52'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'name',
            operator: 'inList',
            value: 'Sara, Ali',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'note',
            operator: 'isEmpty',
            value: '',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'note',
            operator: 'isMissing',
            value: '',
          ),
        ),
        ['mona alexandria silver 52'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'joined',
            operator: 'dateBefore',
            value: '2025-01-01',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: 'city',
            operator: 'lengthGt',
            value: '5',
          ),
        ),
        ['mona alexandria silver 52'],
      );
      expect(
        await payloads(
          const EntrySearchFilter(
            fieldName: '__any__',
            operator: 'notContains',
            value: 'silver',
          ),
        ),
        ['ali cairo gold premium 88'],
      );
    },
  );

  test(
    'extended filters cover negative numeric text and relative dates',
    () async {
      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'Extended', columnMap: '{}'),
      );
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      String date(DateTime value) =>
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

      final rows = [
        {
          'data':
              '{"note":"Alpha Beta","score":"50","joined":"${date(today)}"}',
          'payload': 'first',
        },
        {
          'data': '{"note":"Gamma","score":"80","joined":"${date(yesterday)}"}',
          'payload': 'second',
        },
        {'data': '{"note":"alpha beta","score":"unknown"}', 'payload': 'third'},
      ];
      for (final row in rows) {
        await db.entriesDao.insertEntry(
          EntriesCompanion.insert(
            profileId: profileId,
            data: row['data']!,
            searchPayload: row['payload']!,
          ),
        );
      }

      Future<List<String>> matching(EntrySearchFilter filter) async {
        final matches = await db.entriesDao.searchEntries(
          query: '',
          matchMode: 'contains',
          filters: [filter],
          sortBy: 'oldest',
        );
        return matches.map((entry) => entry.searchPayload).toList();
      }

      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'note',
            operator: 'containsNone',
            value: 'alpha beta',
          ),
        ),
        ['second'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'note',
            operator: 'neqCaseSensitive',
            value: 'Alpha Beta',
          ),
        ),
        ['second', 'third'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'score',
            operator: 'notBetween',
            value: '40',
            value2: '60',
          ),
        ),
        ['second'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'score',
            operator: 'isNotNumeric',
            value: '',
          ),
        ),
        ['third'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'note',
            operator: 'lengthEq',
            value: '5',
          ),
        ),
        ['second'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'joined',
            operator: 'dateToday',
            value: '',
          ),
        ),
        ['first'],
      );
      expect(
        await matching(
          const EntrySearchFilter(
            fieldName: 'joined',
            operator: 'dateInLastDays',
            value: '2',
          ),
        ),
        ['first', 'second'],
      );
      expect(
        await matching(
          EntrySearchFilter(
            fieldName: 'joined',
            operator: 'dateNotOn',
            value: date(today),
          ),
        ),
        ['second'],
      );
    },
  );

  test('AuditDao can log and retrieve actions', () async {
    await db.auditDao.insertLog(
      AuditLogCompanion.insert(
        action: 'TEST_ACTION',
        description: 'Test description',
      ),
    );

    final logs = await db.auditDao.getAllLogs();
    expect(logs.length, 1);
    expect(logs.first.action, 'TEST_ACTION');
  });

  test('clearAllData clears relational and full-text data', () async {
    final profileId = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(name: 'Clear', columnMap: '{}'),
    );
    final batchId = await db.batchesDao.insertBatch(
      ImportBatchesCompanion.insert(
        profileId: profileId,
        originalFileName: 'clear.xlsx',
        localFilePath: 'clear.xlsx',
        fileHash: 'hash',
      ),
    );
    await db.entriesDao.insertEntry(
      EntriesCompanion.insert(
        profileId: profileId,
        importBatchId: drift.Value(batchId),
        data: '{"name":"Clear me"}',
        searchPayload: 'clear me',
      ),
    );
    await db.settingsDao.setSetting('theme_mode', 'dark');
    await db.auditDao.insertLog(
      AuditLogCompanion.insert(action: 'TEST', description: 'clear me'),
    );

    await db.clearAllData();

    expect(await db.entriesDao.getAllEntries(), isEmpty);
    expect(await db.batchesDao.getAllBatches(), isEmpty);
    expect(await db.profilesDao.getAllProfiles(), isEmpty);
    expect(await db.settingsDao.getAllSettings(), isEmpty);
    expect(await db.auditDao.getAllLogs(), isEmpty);
    expect(
      await db.entriesDao.searchEntries(
        query: 'clear',
        matchMode: 'startsWith',
      ),
      isEmpty,
    );
  });
}

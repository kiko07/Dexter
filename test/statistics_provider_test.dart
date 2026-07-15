import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/features/search/search_provider.dart';
import 'package:dexter/features/statistics/statistics_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('statistics aggregate totals ranges sources and profiles', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final subscription = container.listen(statisticsProvider, (_, _) {});
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await db.close();
    });

    final firstProfile = await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(name: 'People', columnMap: '{}'),
    );
    await db.profilesDao.insertProfile(
      ImportProfilesCompanion.insert(name: 'Empty', columnMap: '{}'),
    );
    final batchId = await db.batchesDao.insertBatch(
      ImportBatchesCompanion.insert(
        profileId: firstProfile,
        originalFileName: 'people.xlsx',
        localFilePath: 'people.xlsx',
        fileHash: 'hash',
      ),
    );

    final now = DateTime.now();
    final entries =
        <({String? source, int? batch, DateTime created, String payload})>[
          (source: null, batch: null, created: now, payload: 'manual recent'),
          (
            source: 'people.xlsx',
            batch: batchId,
            created: now.subtract(const Duration(days: 1)),
            payload: 'imported recent',
          ),
          (
            source: null,
            batch: null,
            created: now.subtract(const Duration(days: 45)),
            payload: 'manual old',
          ),
        ];
    for (final entry in entries) {
      await db.entriesDao.insertEntry(
        EntriesCompanion.insert(
          profileId: firstProfile,
          importBatchId: drift.Value(entry.batch),
          sourceFile: drift.Value(entry.source),
          createdAt: drift.Value(entry.created),
          updatedAt: drift.Value(entry.created),
          data: '{"value":"${entry.payload}"}',
          searchPayload: entry.payload,
        ),
      );
    }

    final notifier = container.read(statisticsProvider.notifier);
    await notifier.refresh();
    var state = container.read(statisticsProvider);

    expect(state.error, isNull);
    expect(state.snapshot.totalRecords, 3);
    expect(state.snapshot.manualRecords, 2);
    expect(state.snapshot.indexedFiles, 1);
    expect(state.snapshot.profiles, 2);
    expect(state.snapshot.timeline, hasLength(30));
    expect(state.snapshot.recordsInRange, 2);
    expect(state.snapshot.bySource.map((value) => value.count), [1, 1]);
    expect(state.snapshot.byProfile.single.count, 2);

    await notifier.setRange(StatisticsRange.allTime);
    state = container.read(statisticsProvider);
    expect(state.snapshot.recordsInRange, 3);
    expect(state.snapshot.timeline, isNotEmpty);
  });
}

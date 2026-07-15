import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/features/search/search_provider.dart';
import 'package:dexter/features/settings/duplicate_scanner_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'duplicate cleanup is normalized, atomic, and updates batch counts',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      final subscription = container.listen(
        duplicateScannerProvider,
        (_, _) {},
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await db.close();
      });

      final profileId = await db.profilesDao.insertProfile(
        ImportProfilesCompanion.insert(name: 'Duplicates', columnMap: '{}'),
      );
      final batchId = await db.batchesDao.insertBatch(
        ImportBatchesCompanion.insert(
          profileId: profileId,
          originalFileName: 'duplicates.xlsx',
          localFilePath: 'duplicates.xlsx',
          fileHash: 'hash',
          rowCount: const drift.Value(2),
        ),
      );
      for (final sheet in ['One', 'Two']) {
        await db.entriesDao.insertEntry(
          EntriesCompanion.insert(
            profileId: profileId,
            importBatchId: drift.Value(batchId),
            data: '{"name":"Ali Hassan","city":"Cairo","_sheetName":"$sheet"}',
            searchPayload: 'ali hassan cairo',
          ),
        );
      }

      final notifier = container.read(duplicateScannerProvider.notifier);
      await notifier.scanForDuplicates();
      final group = container
          .read(duplicateScannerProvider)
          .duplicateGroups
          .single;
      expect(group.entries, hasLength(2));

      await notifier.deleteEntry(group.entries.last.id);

      expect(await db.entriesDao.getAllEntries(), hasLength(1));
      expect((await db.batchesDao.getBatch(batchId)).rowCount, 1);
      expect(container.read(duplicateScannerProvider).duplicateGroups, isEmpty);
      expect(await db.auditDao.getAllLogs(), hasLength(1));
    },
  );
}

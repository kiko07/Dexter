import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'batches_dao.g.dart';

@DriftAccessor(tables: [ImportBatches])
class BatchesDao extends DatabaseAccessor<AppDatabase> with _$BatchesDaoMixin {
  BatchesDao(super.db);

  Future<List<ImportBatch>> getAllBatches() => select(importBatches).get();

  Future<ImportBatch> getBatch(int id) => (select(importBatches)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertBatch(ImportBatchesCompanion batch) => into(importBatches).insert(batch);

  Future<bool> updateBatch(ImportBatch batch) => update(importBatches).replace(batch);

  Future<int> deleteBatch(int id) => (delete(importBatches)..where((t) => t.id.equals(id))).go();
}

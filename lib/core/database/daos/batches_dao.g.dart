// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batches_dao.dart';

// ignore_for_file: type=lint
mixin _$BatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportProfilesTable get importProfiles => attachedDatabase.importProfiles;
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  BatchesDaoManager get managers => BatchesDaoManager(this);
}

class BatchesDaoManager {
  final _$BatchesDaoMixin _db;
  BatchesDaoManager(this._db);
  $$ImportProfilesTableTableManager get importProfiles =>
      $$ImportProfilesTableTableManager(
        _db.attachedDatabase,
        _db.importProfiles,
      );
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db.attachedDatabase, _db.importBatches);
}

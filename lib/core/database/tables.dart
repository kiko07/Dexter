import 'package:drift/drift.dart';

// Tables definition

class ImportProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get columnMap => text()(); // JSON string
  IntColumn get referenceRowIndex => integer().withDefault(const Constant(0))();
  TextColumn get dedupKeyField => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(ImportProfiles, #id)();
  TextColumn get data => text()(); // JSON string
  TextColumn get searchPayload => text()(); // concatenated string for FTS5
  TextColumn get sourceFile => text().nullable()();
  IntColumn get importBatchId => integer().nullable().references(ImportBatches, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ImportBatch')
class ImportBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(ImportProfiles, #id)();
  TextColumn get originalFileName => text()();
  TextColumn get localFilePath => text()();
  TextColumn get fileHash => text()(); // SHA-256
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  BoolColumn get isWatched => boolean().withDefault(const Constant(false))();
}

class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()(); // INSERT/UPDATE/DELETE/IMPORT/EXPORT
  IntColumn get entryId => integer().nullable()();
  TextColumn get description => text()();
  DateTimeColumn get performedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

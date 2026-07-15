import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'audit_dao.g.dart';

@DriftAccessor(tables: [AuditLog])
class AuditDao extends DatabaseAccessor<AppDatabase> with _$AuditDaoMixin {
  AuditDao(super.db);

  Future<List<AuditLogData>> getAllLogs() => (select(
    auditLog,
  )..orderBy([(t) => OrderingTerm.desc(t.performedAt)])).get();

  Future<int> insertLog(AuditLogCompanion log) => into(auditLog).insert(log);

  Future<int> clearLogs() => delete(auditLog).go();
}

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [ImportProfiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase> with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  Future<List<ImportProfile>> getAllProfiles() => select(importProfiles).get();

  Future<ImportProfile> getProfile(int id) => (select(importProfiles)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertProfile(ImportProfilesCompanion profile) => into(importProfiles).insert(profile);

  Future<bool> updateProfile(ImportProfile profile) => update(importProfiles).replace(profile);

  Future<int> deleteProfile(int id) => (delete(importProfiles)..where((t) => t.id.equals(id))).go();
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profiles_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportProfilesTable get importProfiles => attachedDatabase.importProfiles;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$ImportProfilesTableTableManager get importProfiles =>
      $$ImportProfilesTableTableManager(
        _db.attachedDatabase,
        _db.importProfiles,
      );
}

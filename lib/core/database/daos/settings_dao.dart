import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<List<AppSetting>> getAllSettings() => select(appSettings).get();

  Future<AppSetting?> getSetting(String key) =>
      (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();

  Future<void> setSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSetting(key: key, value: value));

  Future<int> deleteSetting(String key) =>
      (delete(appSettings)..where((t) => t.key.equals(key))).go();
}

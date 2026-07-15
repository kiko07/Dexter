import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/features/search/search_provider.dart';
import 'package:dexter/features/settings/settings_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auto-lock preference supports immediate delays and never', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsProvider.overrideWith(_TestSettingsNotifier.new),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    await container.read(settingsProvider.future);
    final notifier = container.read(settingsProvider.notifier);

    for (final value in <int?>[0, 5, null, 1]) {
      await notifier.setAutoLockMinutes(value);
      expect(container.read(settingsProvider).value!.autoLockMinutes, value);
    }
    expect((await db.settingsDao.getSetting('auto_lock_minutes'))!.value, '1');
  });
}

class _TestSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettingsState> build() async => AppSettingsState();
}

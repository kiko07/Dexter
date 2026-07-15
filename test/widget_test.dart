import 'package:drift/native.dart';
import 'package:dexter/app.dart';
import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/features/auth/auth_provider.dart';
import 'package:dexter/features/home/home_screen.dart';
import 'package:dexter/features/search/search_provider.dart';
import 'package:dexter/features/settings/settings_provider.dart';
import 'package:dexter/features/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DexterApp loads the home shell when no password is set', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 720);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          authProvider.overrideWith(_TestAuthNotifier.new),
          settingsProvider.overrideWith(_TestSettingsNotifier.new),
        ],
        child: const DexterApp(),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(HomeScreen).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(StatisticsScreen).evaluate().isNotEmpty) break;
    }
    expect(find.byType(StatisticsScreen), findsOneWidget);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: AuthStatus.noPasswordSet);
}

class _TestSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettingsState> build() async => AppSettingsState();
}

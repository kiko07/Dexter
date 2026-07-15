import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dexter/core/l10n/generated/app_localizations.dart';

import 'package:dexter/core/theme/app_theme.dart';

import 'features/home/home_screen.dart';
import 'features/auth/lock_screen.dart';
import 'features/auth/auth_provider.dart';
import 'features/settings/settings_provider.dart';

class DexterApp extends ConsumerStatefulWidget {
  const DexterApp({super.key});

  @override
  ConsumerState<DexterApp> createState() => _DexterAppState();
}

class _DexterAppState extends ConsumerState<DexterApp>
    with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final backgroundDuration = DateTime.now().difference(_backgroundTime!);
        final settingsState = ref.read(settingsProvider);
        final autoLockMinutes = settingsState.hasValue
            ? settingsState.value!.autoLockMinutes
            : 1;
        if (autoLockMinutes != null &&
            backgroundDuration >= Duration(minutes: autoLockMinutes)) {
          final authState = ref.read(authProvider);
          if (authState.status == AuthStatus.authenticated) {
            ref.read(authProvider.notifier).lock();
          }
        }
      }
      _backgroundTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    final authState = ref.watch(authProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.settingsLoadError(err.toString()),
              ),
            ),
          ),
        ),
      ),
      data: (settings) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Dexter',
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
          themeMode: settings.themeMode,
          home: _buildHomeBasedOnAuth(authState.status),
        );
      },
    );
  }

  Widget _buildHomeBasedOnAuth(AuthStatus status) {
    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
      case AuthStatus.storageError:
        return const LockScreen();
      case AuthStatus.noPasswordSet:
      case AuthStatus.authenticated:
        return const HomeScreen();
    }
  }
}

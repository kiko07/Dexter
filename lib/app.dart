import 'dart:async';
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

class _DexterAppState extends ConsumerState<DexterApp> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  int _currentAutoLockMinutes = 5;
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _resetInactivityTimer([int? minutes]) {
    if (minutes != null) {
      _currentAutoLockMinutes = minutes;
    }
    
    _inactivityTimer?.cancel();
    
    if (_currentAutoLockMinutes > 0) {
      _inactivityTimer = Timer(Duration(minutes: _currentAutoLockMinutes), () {
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.authenticated) {
          ref.read(authProvider.notifier).lock();
        }
      });
    }
  }

  void _handleUserInteraction([_]) {
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      if (_currentAutoLockMinutes == 0) {
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.authenticated) {
          ref.read(authProvider.notifier).lock();
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null && _currentAutoLockMinutes > 0) {
        final backgroundDuration = DateTime.now().difference(_backgroundTime!);
        if (backgroundDuration.inMinutes >= _currentAutoLockMinutes) {
          final authState = ref.read(authProvider);
          if (authState.status == AuthStatus.authenticated) {
            ref.read(authProvider.notifier).lock();
          }
        }
      }
      _backgroundTime = null;
      _resetInactivityTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (err, stack) => MaterialApp(home: Scaffold(body: Center(child: Text('Error loading settings: $err')))),
      data: (settings) {
        // Update timer if settings changed (e.g. from 5 to 1 min)
        if (settings.autoLockMinutes != _currentAutoLockMinutes) {
          // Microtask to avoid state modification during build
          Future.microtask(() => _resetInactivityTimer(settings.autoLockMinutes));
        }

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handleUserInteraction,
          onPointerMove: _handleUserInteraction,
          onPointerUp: _handleUserInteraction,
          child: MaterialApp(
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
          ),
        );
      },
    );
  }

  Widget _buildHomeBasedOnAuth(AuthStatus status) {
    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return const LockScreen();
      case AuthStatus.noPasswordSet:
      case AuthStatus.authenticated:
        return const HomeScreen();
    }
  }
}


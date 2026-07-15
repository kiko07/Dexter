import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/secure_storage_service.dart';
import '../search/search_provider.dart'; // for databaseProvider

import 'package:local_auth/local_auth.dart';

const _authProbeTimeout = Duration(seconds: 3);
const _authPromptTimeout = Duration(seconds: 30);
const _unsetSetting = Object();

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool autoScanImportedFiles;
  final bool autoScanWatchedFolders;
  final List<String> watchedFolders;
  final bool biometricsEnabled;
  final List<BiometricType> availableBiometrics;
  final int? autoLockMinutes;

  AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('ar'),
    this.autoScanImportedFiles = true,
    this.autoScanWatchedFolders = false,
    this.watchedFolders = const [],
    this.biometricsEnabled = false,
    this.availableBiometrics = const [],
    this.autoLockMinutes = 1,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? autoScanImportedFiles,
    bool? autoScanWatchedFolders,
    List<String>? watchedFolders,
    bool? biometricsEnabled,
    List<BiometricType>? availableBiometrics,
    Object? autoLockMinutes = _unsetSetting,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoScanImportedFiles:
          autoScanImportedFiles ?? this.autoScanImportedFiles,
      autoScanWatchedFolders:
          autoScanWatchedFolders ?? this.autoScanWatchedFolders,
      watchedFolders: watchedFolders ?? this.watchedFolders,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      autoLockMinutes: identical(autoLockMinutes, _unsetSetting)
          ? this.autoLockMinutes
          : autoLockMinutes as int?,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettingsState> {
  @override
  Future<AppSettingsState> build() async {
    final db = ref.read(databaseProvider);

    final themeStr = await db.settingsDao.getSetting('theme_mode');
    final localeStr = await db.settingsDao.getSetting('locale');
    final autoScanImportedFilesStr = await db.settingsDao.getSetting(
      'auto_scan_imported_files',
    );
    final autoScanWatchedFoldersStr = await db.settingsDao.getSetting(
      'auto_scan_watched_folders',
    );
    final watchedFoldersStr = await db.settingsDao.getSetting(
      'watched_folders',
    );
    final autoLockStr = await db.settingsDao.getSetting('auto_lock_minutes');

    ThemeMode themeMode = ThemeMode.system;
    if (themeStr != null) {
      if (themeStr.value == 'light') themeMode = ThemeMode.light;
      if (themeStr.value == 'dark') themeMode = ThemeMode.dark;
    }

    Locale locale = const Locale('ar');
    if (localeStr != null && localeStr.value == 'en') {
      locale = const Locale('en');
    }

    bool autoScanImportedFiles = true;
    if (autoScanImportedFilesStr != null) {
      autoScanImportedFiles = autoScanImportedFilesStr.value == 'true';
    }

    bool autoScanWatchedFolders = false;
    if (autoScanWatchedFoldersStr != null) {
      autoScanWatchedFolders = autoScanWatchedFoldersStr.value == 'true';
    }

    List<String> watchedFolders = [];
    if (watchedFoldersStr != null && watchedFoldersStr.value.isNotEmpty) {
      try {
        final decoded = jsonDecode(watchedFoldersStr.value) as List;
        watchedFolders = decoded.cast<String>();
      } catch (e) {
        // Fallback or error handling
      }
    }

    int? autoLockMinutes = 1;
    if (autoLockStr?.value == 'never') {
      autoLockMinutes = null;
    } else if (autoLockStr != null) {
      final parsed = int.tryParse(autoLockStr.value);
      if (parsed == 0 || parsed == 1 || parsed == 5) {
        autoLockMinutes = parsed;
      }
    }

    final biometricsEnabled = await SecureStorageService.isBiometricsEnabled();

    List<BiometricType> availableBiometrics = [];
    try {
      final auth = LocalAuthentication();
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics
          .timeout(_authProbeTimeout, onTimeout: () => false);
      if (canAuthenticateWithBiometrics) {
        availableBiometrics = await auth.getAvailableBiometrics().timeout(
          _authProbeTimeout,
          onTimeout: () => const <BiometricType>[],
        );
      }
    } catch (e) {
      // Ignore
    }

    return AppSettingsState(
      themeMode: themeMode,
      locale: locale,
      autoScanImportedFiles: autoScanImportedFiles,
      autoScanWatchedFolders: autoScanWatchedFolders,
      watchedFolders: watchedFolders,
      biometricsEnabled: biometricsEnabled,
      availableBiometrics: availableBiometrics,
      autoLockMinutes: autoLockMinutes,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final db = ref.read(databaseProvider);
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';

    await db.settingsDao.setSetting('theme_mode', modeStr);

    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(themeMode: mode));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting('locale', locale.languageCode);

    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(locale: locale));
    }
  }

  Future<void> setAutoScanImportedFiles(bool value) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting(
      'auto_scan_imported_files',
      value.toString(),
    );

    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoScanImportedFiles: value));
    }
  }

  Future<void> setAutoScanWatchedFolders(bool value) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting(
      'auto_scan_watched_folders',
      value.toString(),
    );

    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoScanWatchedFolders: value));
    }
  }

  Future<void> setBiometricsEnabled(
    bool value, {
    required String localizedReason,
  }) async {
    if (value) {
      final auth = LocalAuthentication();
      try {
        final canAuthenticate =
            await auth.canCheckBiometrics.timeout(
              _authProbeTimeout,
              onTimeout: () => false,
            ) ||
            await auth.isDeviceSupported().timeout(
              _authProbeTimeout,
              onTimeout: () => false,
            );
        if (canAuthenticate) {
          final didAuthenticate = await auth
              .authenticate(
                localizedReason: localizedReason,
                biometricOnly: true,
              )
              .timeout(_authPromptTimeout, onTimeout: () => false);
          if (!didAuthenticate) return; // Cancelled or failed
        }
      } catch (e) {
        return; // Error during auth
      }
    }

    await SecureStorageService.setBiometricsEnabled(value);

    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(biometricsEnabled: value));
    }
  }

  Future<void> setAutoLockMinutes(int? minutes) async {
    if (minutes != null && minutes != 0 && minutes != 1 && minutes != 5) {
      throw ArgumentError.value(minutes, 'minutes', 'Unsupported duration.');
    }
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting(
      'auto_lock_minutes',
      minutes?.toString() ?? 'never',
    );
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoLockMinutes: minutes));
    }
  }

  Future<void> addWatchedFolder(String path) async {
    if (!state.hasValue) return;

    final currentFolders = List<String>.from(state.value!.watchedFolders);
    if (!currentFolders.contains(path)) {
      currentFolders.add(path);

      final db = ref.read(databaseProvider);
      await db.settingsDao.setSetting(
        'watched_folders',
        jsonEncode(currentFolders),
      );

      state = AsyncData(state.value!.copyWith(watchedFolders: currentFolders));
    }
  }

  Future<void> removeWatchedFolder(String path) async {
    if (!state.hasValue) return;

    final currentFolders = List<String>.from(state.value!.watchedFolders);
    if (currentFolders.contains(path)) {
      currentFolders.remove(path);

      final db = ref.read(databaseProvider);
      await db.settingsDao.setSetting(
        'watched_folders',
        jsonEncode(currentFolders),
      );

      state = AsyncData(state.value!.copyWith(watchedFolders: currentFolders));
    }
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettingsState>(() {
      return SettingsNotifier();
    });

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/secure_storage_service.dart';
import '../search/search_provider.dart'; // for databaseProvider

import 'package:local_auth/local_auth.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final int autoLockMinutes; // 0 for immediate, -1 for never
  final bool autoScanImportedFiles;
  final bool autoScanWatchedFolders;
  final List<String> watchedFolders;
  final bool biometricsEnabled;
  final List<BiometricType> availableBiometrics; 

  AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('ar'),
    this.autoLockMinutes = 5,
    this.autoScanImportedFiles = true,
    this.autoScanWatchedFolders = false,
    this.watchedFolders = const [],
    this.biometricsEnabled = false,
    this.availableBiometrics = const [],
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    int? autoLockMinutes,
    bool? autoScanImportedFiles,
    bool? autoScanWatchedFolders,
    List<String>? watchedFolders,
    bool? biometricsEnabled,
    List<BiometricType>? availableBiometrics,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      autoScanImportedFiles: autoScanImportedFiles ?? this.autoScanImportedFiles,
      autoScanWatchedFolders: autoScanWatchedFolders ?? this.autoScanWatchedFolders,
      watchedFolders: watchedFolders ?? this.watchedFolders,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettingsState> {
  @override
  Future<AppSettingsState> build() async {
    final db = ref.read(databaseProvider);
    
    final themeStr = await db.settingsDao.getSetting('theme_mode');
    final localeStr = await db.settingsDao.getSetting('locale');
    final autoLockStr = await db.settingsDao.getSetting('auto_lock_minutes');
    final autoScanImportedFilesStr = await db.settingsDao.getSetting('auto_scan_imported_files');
    final autoScanWatchedFoldersStr = await db.settingsDao.getSetting('auto_scan_watched_folders');
    final watchedFoldersStr = await db.settingsDao.getSetting('watched_folders');

    ThemeMode themeMode = ThemeMode.system;
    if (themeStr != null) {
      if (themeStr.value == 'light') themeMode = ThemeMode.light;
      if (themeStr.value == 'dark') themeMode = ThemeMode.dark;
    }

    Locale locale = const Locale('ar');
    if (localeStr != null && localeStr.value == 'en') {
      locale = const Locale('en');
    }

    int autoLockMinutes = 5; // Default 5 minutes
    if (autoLockStr != null) {
      autoLockMinutes = int.tryParse(autoLockStr.value) ?? 5;
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

    final biometricsEnabled = await SecureStorageService.isBiometricsEnabled();
    
    List<BiometricType> availableBiometrics = [];
    try {
      final auth = LocalAuthentication();
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      if (canAuthenticateWithBiometrics) {
        availableBiometrics = await auth.getAvailableBiometrics();
      }
    } catch (e) {
      // Ignore
    }

    return AppSettingsState(
      themeMode: themeMode,
      locale: locale,
      autoLockMinutes: autoLockMinutes,
      autoScanImportedFiles: autoScanImportedFiles,
      autoScanWatchedFolders: autoScanWatchedFolders,
      watchedFolders: watchedFolders,
      biometricsEnabled: biometricsEnabled,
      availableBiometrics: availableBiometrics,
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

  Future<void> setAutoLockMinutes(int minutes) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting('auto_lock_minutes', minutes.toString());
    
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoLockMinutes: minutes));
    }
  }

  Future<void> setAutoScanImportedFiles(bool value) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting('auto_scan_imported_files', value.toString());
    
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoScanImportedFiles: value));
    }
  }

  Future<void> setAutoScanWatchedFolders(bool value) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setSetting('auto_scan_watched_folders', value.toString());
    
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(autoScanWatchedFolders: value));
    }
  }

  Future<void> setBiometricsEnabled(bool value) async {
    if (value) {
      final auth = LocalAuthentication();
      try {
        final canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
        if (canAuthenticate) {
          final didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to enable biometrics',
            biometricOnly: true,
          );
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

  Future<void> addWatchedFolder(String path) async {
    if (!state.hasValue) return;
    
    final currentFolders = List<String>.from(state.value!.watchedFolders);
    if (!currentFolders.contains(path)) {
      currentFolders.add(path);
      
      final db = ref.read(databaseProvider);
      await db.settingsDao.setSetting('watched_folders', jsonEncode(currentFolders));
      
      state = AsyncData(state.value!.copyWith(watchedFolders: currentFolders));
    }
  }

  Future<void> removeWatchedFolder(String path) async {
    if (!state.hasValue) return;
    
    final currentFolders = List<String>.from(state.value!.watchedFolders);
    if (currentFolders.contains(path)) {
      currentFolders.remove(path);
      
      final db = ref.read(databaseProvider);
      await db.settingsDao.setSetting('watched_folders', jsonEncode(currentFolders));
      
      state = AsyncData(state.value!.copyWith(watchedFolders: currentFolders));
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettingsState>(() {
  return SettingsNotifier();
});

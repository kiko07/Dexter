import 'dart:io' show Platform;
import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../core/utils/secure_storage_service.dart';
import '../search/search_provider.dart'; // for databaseProvider
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:local_auth/local_auth.dart';
import 'settings_provider.dart';
import 'manage_files_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider).value;
    final authState = ref.watch(authProvider);
    final hasPassword = authState.status != AuthStatus.noPasswordSet;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: settingsState == null 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _SettingsSection(
                title: AppLocalizations.of(context)!.appearanceAndLanguage, // Appearance & Language
                children: [
                  _SettingsTile(
                    icon: Icons.color_lens_rounded,
                    iconColor: Colors.purple,
                    title: AppLocalizations.of(context)!.themeSettings,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: settingsState.themeMode,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            ref.read(settingsProvider.notifier).setThemeMode(newValue);
                          }
                        },
                        items: [
                          DropdownMenuItem(value: ThemeMode.system, child: Text(AppLocalizations.of(context)!.system)),
                          DropdownMenuItem(value: ThemeMode.light, child: Text(AppLocalizations.of(context)!.light)),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text(AppLocalizations.of(context)!.dark)),
                        ],
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    iconColor: Colors.blue,
                    title: AppLocalizations.of(context)!.languageSettings,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: settingsState.locale.languageCode,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            ref.read(settingsProvider.notifier).setLocale(Locale(newValue));
                          }
                        },
                        items: [
                          DropdownMenuItem(value: 'ar', child: Text(AppLocalizations.of(context)!.arabic)),
                          DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              _SettingsSection(
                title: AppLocalizations.of(context)!.security, // Security
                children: [

                  if (settingsState.availableBiometrics.isNotEmpty) ...[
                    _SettingsTile(
                      icon: settingsState.availableBiometrics.contains(BiometricType.face) 
                          ? Icons.face_rounded 
                          : Icons.fingerprint_rounded,
                      iconColor: Colors.green,
                      title: settingsState.availableBiometrics.contains(BiometricType.face) 
                          ? 'Face ID' 
                          : 'Fingerprint',
                      subtitle: settingsState.availableBiometrics.contains(BiometricType.face) 
                          ? 'Use Face ID to unlock' 
                          : 'Use Fingerprint to unlock',
                      trailing: Switch(
                        value: settingsState.biometricsEnabled,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          ref.read(settingsProvider.notifier).setBiometricsEnabled(value);
                        },
                      ),
                    ),
                  ],
                  _buildDivider(),
                  if (!hasPassword)
                    _SettingsTile(
                      icon: Icons.password,
                      iconColor: Colors.blue,
                      title: AppLocalizations.of(context)!.setupNewPassword,
                      onTap: () => _showCreatePasswordDialog(context, ref),
                      showArrow: true,
                    )
                  else ...[
                    _SettingsTile(
                      icon: Icons.lock_reset_rounded,
                      iconColor: Colors.amber,
                      title: AppLocalizations.of(context)!.resetPassword,
                      subtitle: AppLocalizations.of(context)!.changeCurrentAppPassword,
                      onTap: () => _showChangePasswordDialog(context, ref),
                      showArrow: true,
                    ),
                    _buildDivider(),
                    _SettingsTile(
                      icon: Icons.no_encryption_rounded,
                      iconColor: Colors.redAccent,
                      title: AppLocalizations.of(context)!.removePassword,
                      subtitle: AppLocalizations.of(context)!.removePasswordSubtitle,
                      onTap: () => _showRemovePasswordDialog(context, ref),
                      showArrow: true,
                    ),
                    _buildDivider(),
                    _SettingsTile(
                      icon: Icons.exit_to_app_rounded,
                      iconColor: Colors.grey.shade700,
                      title: AppLocalizations.of(context)!.lockAppNow,
                      onTap: () => ref.read(authProvider.notifier).lock(),
                      showArrow: true,
                    ),
                  ],
                ],
              ),

              if (!Platform.isAndroid && !Platform.isIOS)
                _SettingsSection(
                  title: AppLocalizations.of(context)!.dataAndSync, // Data & Sync
                  children: [
                    _SettingsTile(
                      icon: Icons.sync_rounded,
                      iconColor: Colors.teal,
                      title: AppLocalizations.of(context)!.autoUpdateImportedFiles,
                      subtitle: AppLocalizations.of(context)!.checkForUpdatesOnStartup,
                      trailing: Switch(
                        value: settingsState.autoScanImportedFiles,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          ref.read(settingsProvider.notifier).setAutoScanImportedFiles(value);
                        },
                      ),
                    ),
                    _buildDivider(),
                    _SettingsTile(
                      icon: Icons.folder_special_rounded,
                      iconColor: Colors.indigo,
                      title: AppLocalizations.of(context)!.scanWatchedFolders,
                      subtitle: AppLocalizations.of(context)!.autoSearchNewFilesInFolders,
                      trailing: Switch(
                        value: settingsState.autoScanWatchedFolders,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          ref.read(settingsProvider.notifier).setAutoScanWatchedFolders(value);
                        },
                      ),
                    ),
                    if (settingsState.autoScanWatchedFolders) ...[
                      _buildDivider(),
                      _SettingsTile(
                        icon: Icons.create_new_folder_rounded,
                        iconColor: Colors.lightBlue,
                        title: AppLocalizations.of(context)!.addFolderToWatch,
                        onTap: () async {
                          final dir = await file_picker.FilePicker.getDirectoryPath();
                          if (dir != null) {
                            ref.read(settingsProvider.notifier).addWatchedFolder(dir);
                          }
                        },
                        showArrow: true,
                      ),
                      ...settingsState.watchedFolders.map((folder) => Column(
                        children: [
                          _buildDivider(),
                          _SettingsTile(
                            icon: Icons.folder_rounded,
                            iconColor: Colors.blueGrey,
                            title: folder,
                            titleDirection: TextDirection.ltr,
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                              onPressed: () {
                                ref.read(settingsProvider.notifier).removeWatchedFolder(folder);
                              },
                            ),
                          ),
                        ],
                      )),
                    ],
                  ],
                ),

              _SettingsSection(
                title: AppLocalizations.of(context)!.advancedManagement, // Advanced
                children: [
                  _SettingsTile(
                    icon: Icons.source_rounded,
                    iconColor: Colors.deepPurple,
                    title: AppLocalizations.of(context)!.manageIndexedFiles,
                    subtitle: 'View and delete specific file records',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageFilesScreen())),
                    showArrow: true,
                  ),
                  _buildDivider(),
                  _SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: Colors.red,
                    title: AppLocalizations.of(context)!.clearAllData,
                    subtitle: AppLocalizations.of(context)!.allDataWillBeDeletedForever,
                    titleColor: Colors.red,
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 64, endIndent: 16);
  }

  void _showCreatePasswordDialog(BuildContext context, WidgetRef ref) {
    final newController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)!.setupNewPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newPassword,
                  prefixIcon: const Icon(Icons.key),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newController.text.isEmpty) return;
                await ref.read(authProvider.notifier).setPassword(newController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    ).whenComplete(() {
      newController.dispose();
    });
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    String? errorText;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(context)!.resetPassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.currentPassword,
                      errorText: errorText,
                      prefixIcon: const Icon(Icons.password),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.newPassword,
                      prefixIcon: const Icon(Icons.key),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (currentController.text.isEmpty || newController.text.isEmpty) return;
                    
                    final isValid = await SecureStorageService.verifyPassword(currentController.text);
                    if (!isValid) {
                      setDialogState(() {
                        errorText = AppLocalizations.of(context)!.currentPasswordIncorrect;
                      });
                      return;
                    }
                    
                    await ref.read(authProvider.notifier).setPassword(newController.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.passwordChangedSuccessfully),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      currentController.dispose();
      newController.dispose();
    });
  }

  void _showRemovePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    String? errorText;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(context)!.removePassword),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.confirmRemovePassword),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.currentPassword,
                      errorText: errorText,
                      prefixIcon: const Icon(Icons.password),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (currentController.text.isEmpty) return;
                    
                    final isValid = await SecureStorageService.verifyPassword(currentController.text);
                    if (!isValid) {
                      setDialogState(() {
                        errorText = AppLocalizations.of(context)!.currentPasswordIncorrect;
                      });
                      return;
                    }
                    
                    await ref.read(authProvider.notifier).resetApp();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.passwordRemovedSuccessfully),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.remove, style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      currentController.dispose();
    });
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text(AppLocalizations.of(context)!.warningClearAllData, style: const TextStyle(color: Colors.red))),
            ],
          ),
          content: Text(AppLocalizations.of(context)!.confirmClearAllDataText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                final db = ref.read(databaseProvider);
                await db.clearAllData();
                await ref.read(authProvider.notifier).resetApp();
              },
              child: Text(AppLocalizations.of(context)!.confirmClear, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _SettingsSection({required this.title, required this.children});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? titleColor;
  final TextDirection? titleDirection;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showArrow = false,
    this.titleColor,
    this.titleDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                      ),
                      textDirection: titleDirection,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              ?trailing,
              if (showArrow) 
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}


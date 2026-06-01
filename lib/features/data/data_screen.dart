import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dexter/core/l10n/generated/app_localizations.dart';

import '../import/import_wizard/import_wizard_screen.dart';
import '../import/background_scanner_service.dart';
import '../home/history_screen.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BackgroundScannerState>(backgroundScannerProvider, (previous, next) {
      if (previous?.isScanning == true && !next.isScanning) {
        if (next.lastMessage != null) {
          String displayMessage = next.lastMessage!;
          bool isError = false;
          if (displayMessage.startsWith('autoUpdateSuccess:')) {
            final countStr = displayMessage.replaceFirst('autoUpdateSuccess:', '');
            displayMessage = AppLocalizations.of(context)!.autoUpdateSuccess(int.tryParse(countStr) ?? 0);
          } else if (displayMessage.startsWith('autoUpdateError:')) {
            final errorMsg = displayMessage.replaceFirst('autoUpdateError:', '');
            displayMessage = AppLocalizations.of(context)!.autoUpdateError(errorMsg);
            isError = true;
          } else if (displayMessage.contains('Error') || displayMessage.contains('خطأ')) {
            isError = true;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: isError ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    });

    final isScanning = ref.watch(backgroundScannerProvider).isScanning;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Text(
                    AppLocalizations.of(context)!.data,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _DataActionCard(
                        icon: Icons.upload_file_rounded,
                        title: AppLocalizations.of(context)!.importData,
                        subtitle: AppLocalizations.of(context)!.importDataSubtitle,
                        color: theme.colorScheme.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ImportWizardScreen()),
                          );
                        },
                      ),
                      if (!Platform.isAndroid && !Platform.isIOS)
                        _DataActionCard(
                          icon: Icons.sync_rounded,
                          title: AppLocalizations.of(context)!.updateData,
                          subtitle: AppLocalizations.of(context)!.updateDataSubtitle,
                          color: Colors.deepPurple,
                          onTap: () {
                            ref.read(backgroundScannerProvider.notifier).scanNow(isManual: true);
                          },
                        ),
                      _DataActionCard(
                        icon: Icons.history_rounded,
                        title: AppLocalizations.of(context)!.importHistory,
                        subtitle: AppLocalizations.of(context)!.showAllData,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 120), // Space for floating nav bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isScanning)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              AppLocalizations.of(context)!.scanningWait,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.pleaseWaitAndDoNotClose,
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DataActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DataActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

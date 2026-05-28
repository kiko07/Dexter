import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:dexter/core/l10n/generated/app_localizations.dart';

import '../import/import_wizard/import_wizard_screen.dart';
import '../export/export_provider.dart';
import '../import/background_scanner_service.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExportState>(exportProvider, (previous, next) {
      if (previous?.isExporting == true && !next.isExporting) {
        if (next.message != null) {
          String displayMessage = next.message!;
          if (displayMessage.startsWith('allDataExportedSuccess:')) {
            displayMessage = AppLocalizations.of(context)!.allDataExportedSuccess(displayMessage.replaceFirst('allDataExportedSuccess:', ''));
          } else if (displayMessage.startsWith('dataExportedSuccess:')) {
            displayMessage = AppLocalizations.of(context)!.dataExportedSuccess(displayMessage.replaceFirst('dataExportedSuccess:', ''));
          } else if (displayMessage == 'noDataToExport') {
            displayMessage = AppLocalizations.of(context)!.noDataToExport;
          } else if (displayMessage == 'failedToCreateFile') {
            displayMessage = AppLocalizations.of(context)!.failedToCreateFile;
          } else if (displayMessage == 'failedToSaveCheckPermissions') {
            displayMessage = AppLocalizations.of(context)!.failedToSaveCheckPermissions;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: next.isError ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    });

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

    final isExporting = ref.watch(exportProvider).isExporting;
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
                        icon: Icons.download_rounded,
                        title: AppLocalizations.of(context)!.exportData,
                        subtitle: AppLocalizations.of(context)!.exportDataSubtitle,
                        color: Colors.teal,
                        onTap: () => _showExportDialog(context, ref),
                      ),
                      const SizedBox(height: 120), // Space for floating nav bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExporting || isScanning)
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
                              isExporting ? AppLocalizations.of(context)!.exportingWait : AppLocalizations.of(context)!.scanningWait,
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

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return const _ExportBottomSheet();
      },
    );
  }
}

class _ExportBottomSheet extends ConsumerStatefulWidget {
  const _ExportBottomSheet();

  @override
  ConsumerState<_ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends ConsumerState<_ExportBottomSheet> {
  int _selectedOption = 0; // 0: All, 1: 24h, 2: 7days, 3: Custom
  DateTime? _customStart;
  DateTime? _customEnd;

  Widget _buildOption(String title, int value, ThemeData theme) {
    final isSelected = _selectedOption == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.exportData,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.chooseTimeRangeForExport,
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          _buildOption(AppLocalizations.of(context)!.allData, 0, theme),
          _buildOption(AppLocalizations.of(context)!.last24Hours, 1, theme),
          _buildOption(AppLocalizations.of(context)!.last7Days, 2, theme),
          _buildOption(AppLocalizations.of(context)!.customPeriod, 3, theme),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _selectedOption == 3
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  primary: theme.colorScheme.primary,
                                  surface: theme.colorScheme.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (range != null) {
                          setState(() {
                            _customStart = range.start;
                            _customEnd = range.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
                          });
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(_customStart == null
                          ? AppLocalizations.of(context)!.chooseDates
                          : '${_customStart!.year}-${_customStart!.month}-${_customStart!.day} - ${_customEnd!.year}-${_customEnd!.month}-${_customEnd!.day}'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              DateTime? start;
              DateTime? end;
              final now = DateTime.now();

              if (_selectedOption == 1) {
                start = now.subtract(const Duration(hours: 24));
                end = now;
              } else if (_selectedOption == 2) {
                start = now.subtract(const Duration(days: 7));
                end = now;
              } else if (_selectedOption == 3) {
                start = _customStart;
                end = _customEnd;
                if (start == null || end == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectTimeRangeFirst)),
                  );
                  return;
                }
              }

              Navigator.pop(context); // Close bottom sheet

              final destDir = await FilePicker.getDirectoryPath();
              if (destDir != null) {
                final destPath = p.join(destDir, 'export_${now.millisecondsSinceEpoch}.xlsx');
                ref.read(exportProvider.notifier).exportAllDataByDateRange(destPath, start, end);
              }
            },
            child: Text(AppLocalizations.of(context)!.exportNow, style: const TextStyle(fontSize: 16)),
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

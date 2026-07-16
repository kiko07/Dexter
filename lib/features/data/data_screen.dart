import 'dart:io' show File, Platform;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/excel_service.dart';
import '../import/import_wizard/import_wizard_screen.dart';
import '../import/background_scanner_service.dart';
import '../home/history_screen.dart';
import '../search/search_provider.dart';

enum _ExportRange { all, last24h, last7d, custom }

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<BackgroundScannerState>(backgroundScannerProvider, (
      previous,
      next,
    ) {
      if (previous?.isScanning == true && !next.isScanning) {
        if (next.lastMessage != null) {
          String displayMessage = next.lastMessage!;
          bool isError = false;
          if (displayMessage.startsWith('autoUpdateSuccess:')) {
            final countStr = displayMessage.replaceFirst(
              'autoUpdateSuccess:',
              '',
            );
            displayMessage = AppLocalizations.of(
              context,
            )!.autoUpdateSuccess(int.tryParse(countStr) ?? 0);
          } else if (displayMessage.startsWith('autoUpdateError:')) {
            final errorMsg = displayMessage.replaceFirst(
              'autoUpdateError:',
              '',
            );
            displayMessage = AppLocalizations.of(
              context,
            )!.autoUpdateError(errorMsg);
            isError = true;
          } else if (displayMessage.contains('Error') ||
              displayMessage.contains('خطأ')) {
            isError = true;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: isError ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final actions = <Widget>[
                  _DataActionCard(
                    icon: Icons.upload_file_rounded,
                    title: AppLocalizations.of(context)!.importData,
                    subtitle: AppLocalizations.of(context)!.importDataSubtitle,
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImportWizardScreen(),
                        ),
                      );
                    },
                  ),
                  _DataActionCard(
                    icon: Icons.download_rounded,
                    title: AppLocalizations.of(context)!.exportData,
                    subtitle: AppLocalizations.of(context)!.exportDataSubtitle,
                    color: Colors.blueGrey,
                    onTap: _isExporting ? () {} : () => _exportData(context),
                  ),
                  if (!Platform.isAndroid && !Platform.isIOS)
                    _DataActionCard(
                      icon: Icons.sync_rounded,
                      title: AppLocalizations.of(context)!.updateData,
                      subtitle: AppLocalizations.of(
                        context,
                      )!.updateDataSubtitle,
                      color: Colors.deepPurple,
                      onTap: () {
                        ref
                            .read(backgroundScannerProvider.notifier)
                            .scanNow(isManual: true);
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
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ];
                final contentWidth = math.min(constraints.maxWidth, 1040.0);
                final columns = contentWidth >= 760 ? 2 : 1;
                const spacing = 16.0;
                final cardWidth = columns == 2
                    ? (contentWidth - spacing) / 2
                    : contentWidth;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final action in actions)
                            SizedBox(width: cardWidth, child: action),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isScanning || _isExporting)
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              _isExporting
                                  ? AppLocalizations.of(context)!.exportingWait
                                  : AppLocalizations.of(context)!.scanningWait,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.pleaseWaitAndDoNotClose,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
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

  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final range = await showDialog<_ExportRange>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.exportData),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _ExportRange.all),
            child: Text(l10n.allData),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _ExportRange.last24h),
            child: Text(l10n.last24Hours),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _ExportRange.last7d),
            child: Text(l10n.last7Days),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _ExportRange.custom),
            child: Text(l10n.customPeriod),
          ),
        ],
      ),
    );
    if (range == null || !context.mounted) return;

    DateTime? start;
    DateTime? end;
    final now = DateTime.now();
    switch (range) {
      case _ExportRange.all:
        break;
      case _ExportRange.last24h:
        start = now.subtract(const Duration(hours: 24));
        break;
      case _ExportRange.last7d:
        start = now.subtract(const Duration(days: 7));
        break;
      case _ExportRange.custom:
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(now.year + 1),
        );
        if (picked == null) return;
        start = picked.start;
        end = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
        break;
    }

    setState(() => _isExporting = true);
    File? tempFile;
    try {
      final db = ref.read(databaseProvider);
      final entries = await db.entriesDao.getEntriesByDateRange(start, end);
      if (entries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noDataToExport)));
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'dexter_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      tempFile = await ExcelService.exportEntriesToXlsx(
        entries: entries,
        outputPath: p.join(tempDir.path, fileName),
      );

      if (Platform.isLinux) {
        final savedPath = await file_picker.FilePicker.saveFile(
          dialogTitle: l10n.exportData,
          fileName: fileName,
          type: file_picker.FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: Uint8List.fromList(await tempFile.readAsBytes()),
        );
        if (savedPath != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dataExportedSuccess(savedPath))),
          );
        }
      } else {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(tempFile.path)], subject: l10n.exportData),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.exportReady)));
        }
      }

      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'EXPORT',
          description: 'Exported ${entries.length} entries',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred(e.toString()))),
        );
      }
    } finally {
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Temporary-file cleanup must not leave the screen permanently busy.
      }
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

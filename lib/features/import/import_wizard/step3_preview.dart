import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/excel_service.dart';
import '../import_wizard_provider.dart';

class Step3Preview extends ConsumerStatefulWidget {
  const Step3Preview({super.key});

  @override
  ConsumerState<Step3Preview> createState() => _Step3PreviewState();
}

class _Step3PreviewState extends ConsumerState<Step3Preview> {
  String? _signature;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);
    final signature =
        '${state.filePaths.join('|')}|${state.selectedColumns}|${state.referenceRowIndex}|${state.selectedSheets.join('|')}';
    if (_signature != signature) {
      _signature = signature;
      Future.microtask(() => _loadPreview(state, signature));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.dataPreview,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.dataWillBeImportedAsFollows,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildPreviewBody(context, state, theme)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                notifier.goToStep(ImportWizardStep.columnSelector);
              },
              child: Text(AppLocalizations.of(context)!.previous),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: !_isLoading && _error == null && _rows.isNotEmpty
                  ? () => notifier.startImport()
                  : null,
              child: Text(
                AppLocalizations.of(context)!.looksCorrectStartImport,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewBody(
    BuildContext context,
    ImportWizardState state,
    ThemeData theme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.errorOccurred(_error!)),
      );
    }
    if (_rows.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noResults));
    }

    final headers = state.selectedColumns.values.toList();
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: headers
                .map((header) => DataColumn(label: Text(header)))
                .toList(),
            rows: _rows
                .map(
                  (row) => DataRow(
                    cells: headers
                        .map(
                          (header) =>
                              DataCell(Text(row[header]?.toString() ?? '')),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _loadPreview(ImportWizardState state, String signature) async {
    if (state.filePaths.isEmpty || state.selectedColumns.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allSheets = await ExcelService.parseAllSheets(
        filePath: state.filePaths.first,
        columnMap: state.selectedColumns,
        referenceRowIndex: state.referenceRowIndex,
      );
      final rows = <Map<String, dynamic>>[];
      for (final entry in allSheets.entries) {
        if (!state.selectedSheets.contains(entry.key)) {
          continue;
        }
        rows.addAll(entry.value.take(5 - rows.length));
        if (rows.length >= 5) break;
      }
      if (!mounted || _signature != signature) return;
      setState(() {
        _rows = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || _signature != signature) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}

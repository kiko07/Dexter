import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../import_wizard_provider.dart';

class Step2ColumnSelector extends ConsumerWidget {
  const Step2ColumnSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.selectColumns, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Auto import switch
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: SwitchListTile(
            title: Text(AppLocalizations.of(context)!.importAllFieldsAuto, style: const TextStyle(fontWeight: FontWeight.bold)),
            activeThumbColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            value: state.importAllFields,
            onChanged: notifier.setImportAllFields,
          ),
        ),
        
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.chooseColumns, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Dedup dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.dedupKeyField,
              hint: Text(AppLocalizations.of(context)!.none),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_circle, color: theme.colorScheme.primary),
              items: state.selectedColumns.values.map((header) {
                return DropdownMenuItem(
                  value: header,
                  child: Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: notifier.setDedupKey,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Columns list
        Expanded(
          child: ListView.builder(
            itemCount: state.availableHeaders.length,
            itemBuilder: (context, index) {
              final header = state.availableHeaders[index];
              if (header.isEmpty) return const SizedBox.shrink();
              
              final colKey = index.toString();
              final displayLetter = index < 26 
                  ? String.fromCharCode(65 + index) 
                  : 'Col${index + 1}';
              final isSelected = state.selectedColumns.containsKey(colKey);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.colorScheme.onSurface.withValues(alpha: 0.05)
                  ),
                ),
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          displayLetter, 
                          style: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(header, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                    ],
                  ),
                  value: isSelected,
                  activeColor: theme.colorScheme.primary,
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: state.importAllFields ? null : (val) {
                    notifier.toggleColumn(colKey, header);
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                notifier.goToStep(ImportWizardStep.referenceRow);
              },
              child: Text(AppLocalizations.of(context)!.previous),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: state.selectedColumns.isNotEmpty
                  ? () => notifier.goToPreview()
                  : null,
              child: Text(AppLocalizations.of(context)!.next, style: const TextStyle(fontSize: 16)),
            ),
          ],
        )
      ],
    );
  }
}

import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../import_wizard_provider.dart';

class Step3Preview extends ConsumerWidget {
  const Step3Preview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.dataPreview, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.dataWillBeImportedAsFollows, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 16),
        // Simulated Preview Card
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary.withValues(alpha: 0.1), theme.colorScheme.secondary.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.sampleData, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              // Data
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: state.selectedColumns.values.toList().asMap().entries.map((e) {
                    final isLast = e.key == state.selectedColumns.length - 1;
                    final header = e.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              header, 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '...', 
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
            ),
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
                notifier.goToStep(ImportWizardStep.columnSelector);
              },
              child: Text(AppLocalizations.of(context)!.previous),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => notifier.startImport(),
              child: Text(AppLocalizations.of(context)!.looksCorrectStartImport, style: const TextStyle(fontSize: 16)), // Looks correct - Start Import
            ),
          ],
        )
      ],
    );
  }
}

import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../import_wizard_provider.dart';

class ImportSummaryScreen extends ConsumerWidget {
  const ImportSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.importComplete,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            children: [
              _buildStatRow(
                AppLocalizations.of(context)!.totalRecords,
                '${state.totalRows}',
                Icons.list_alt,
                theme.colorScheme.primary,
                theme,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              _buildStatRow(
                AppLocalizations.of(context)!.importedRecords,
                '${state.processedRows}',
                Icons.check_circle_outline,
                Colors.green,
                theme,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              _buildStatRow(
                AppLocalizations.of(context)!.skippedDuplicates,
                '${state.skippedRows}',
                Icons.skip_next_rounded,
                Colors.orange,
                theme,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              _buildStatRow(
                AppLocalizations.of(context)!.recordsWithError,
                '${state.errorRows}',
                Icons.error_outline_rounded,
                Colors.red,
                theme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              notifier.reset(); // Back to start
            },
            child: Text(
              AppLocalizations.of(context)!.finish,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

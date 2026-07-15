import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.importHistory,
        ), // Import History
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.batches.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noImportHistory))
          : ListView.builder(
              itemCount: state.batches.length,
              itemBuilder: (context, index) {
                final batch = state.batches[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(batch.originalFileName),
                    subtitle: Text(
                      AppLocalizations.of(context)!.recordCountAndDate(
                        batch.rowCount,
                        batch.importedAt.toString().split(".")[0],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.undo, color: Colors.red),
                      onPressed: () => _confirmUndo(context, notifier, batch),
                      tooltip: AppLocalizations.of(context)!.undoImport,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmUndo(
    BuildContext context,
    HistoryNotifier notifier,
    ImportBatch batch,
  ) {
    // Capture the ScaffoldMessenger before showing the dialog to avoid
    // using the dialog's context after it's popped
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.confirmUndo),
          content: Text(
            AppLocalizations.of(
              dialogContext,
            )!.confirmDeleteImportBatch(batch.originalFileName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.undoBatch(batch);
                Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.undoImportSuccess)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                AppLocalizations.of(context)!.confirmDelete,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

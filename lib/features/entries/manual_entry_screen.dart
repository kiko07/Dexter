import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manual_entry_provider.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _hasUnsavedData(ManualEntryState state) {
    return state.formData.values.any((value) => value.trim().isNotEmpty);
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.discardChangesTitle),
        content: Text(AppLocalizations.of(context)!.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manualEntryProvider);
    final notifier = ref.read(manualEntryProvider.notifier);
    final theme = Theme.of(context);

    if (state.activeProfile == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    size: 36,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.setupProfileFirst,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Attempt to decode the column mapping from the profile
    Map<String, dynamic> columnMapping = {};
    try {
      columnMapping = jsonDecode(state.activeProfile!.columnMap);
    } catch (_) {}

    final headerFields = columnMapping.values.cast<String>().toList();

    return PopScope(
      canPop: !_hasUnsavedData(state),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: state.isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.error != null)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    state.error == 'noActiveProfile'
                                        ? AppLocalizations.of(
                                            context,
                                          )!.setupProfileFirst
                                        : AppLocalizations.of(
                                            context,
                                          )!.errorOccurred(state.error!),
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              if (state.duplicateEntryFound != null)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.duplicateEntryWarning,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.recordNumber(
                                          state.duplicateEntryFound!.id,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      FilledButton.tonal(
                                        onPressed: () {
                                          notifier.saveEntry(
                                            ignoreDuplicate: true,
                                          );
                                        },
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.saveAnyway,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ...headerFields.map((field) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    key: ValueKey(
                                      '${state.formVersion}-$field',
                                    ),
                                    initialValue: state.formData[field] ?? '',
                                    decoration: InputDecoration(
                                      labelText: field,
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? AppLocalizations.of(
                                            context,
                                          )!.fieldRequired
                                        : null,
                                    onChanged: (value) {
                                      notifier.updateField(field, value);
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final success = await notifier.saveEntry();
                                  if (success && context.mounted) {
                                    _formKey.currentState?.reset();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.recordSavedSuccessfully,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.save_outlined),
                                label: Text(
                                  AppLocalizations.of(context)!.saveRecord,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

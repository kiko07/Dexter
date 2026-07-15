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

    if (state.activeProfile == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.setupProfileFirst),
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.manualEntry)),
        body: state.isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.error != null)
                        Container(
                          color: Colors.red.shade100,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            state.error == 'noActiveProfile'
                                ? AppLocalizations.of(
                                    context,
                                  )!.setupProfileFirst
                                : AppLocalizations.of(
                                    context,
                                  )!.errorOccurred(state.error!),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (state.duplicateEntryFound != null)
                        Container(
                          color: Colors.orange.shade100,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.duplicateEntryWarning,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.recordNumber(state.duplicateEntryFound!.id),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  notifier.saveEntry(ignoreDuplicate: true);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.saveAnyway,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...headerFields.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            key: ValueKey('${state.formVersion}-$field'),
                            initialValue: state.formData[field] ?? '',
                            decoration: InputDecoration(labelText: field),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? AppLocalizations.of(context)!.fieldRequired
                                : null,
                            onChanged: (val) {
                              notifier.updateField(field, val);
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
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
                        icon: const Icon(Icons.save),
                        label: Text(AppLocalizations.of(context)!.saveRecord),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

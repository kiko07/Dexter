import 'package:dexter/core/l10n/generated/app_localizations.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'export_provider.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exportProvider);
    final notifier = ref.read(exportProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exportData),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                AppLocalizations.of(context)!.exportDataDescription,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.filterExportOptional,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                 notifier.setQuery(val);
              },
            ),
            const SizedBox(height: 32),
            if (state.isExporting)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    notifier.exportDataToShare();
                  } else {
                    final destPath = await FilePicker.saveFile(
                      dialogTitle: 'Please select an output file:',
                      fileName: 'export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
                      allowedExtensions: ['xlsx'],
                      type: FileType.custom,
                    );
                    if (destPath != null) {
                      notifier.exportData(destPath);
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: Text(AppLocalizations.of(context)!.exportAllAsExcel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 32),
            if (state.message != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: state.isError ? Colors.red.shade100 : Colors.green.shade100,
                child: Text(
                  state.message!,
                  style: TextStyle(
                    color: state.isError ? Colors.red.shade900 : Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


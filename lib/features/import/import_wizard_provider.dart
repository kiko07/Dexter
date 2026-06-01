import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/excel_service.dart';
import '../../core/utils/hash_service.dart';
import '../../core/database/app_database.dart';
import '../search/search_provider.dart'; // For databaseProvider
import '../home/history_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;
import '../../core/utils/arabic_normalizer.dart';

enum ImportWizardStep {
  referenceRow,
  columnSelector,
  preview,
  progress,
  summary
}

class ImportWizardState {
  final List<String> filePaths;
  final ImportWizardStep currentStep;
  final int referenceRowIndex;
  final List<String> availableHeaders;
  final Map<String, String> selectedColumns; // Excel column -> DB Header Name
  final String? dedupKeyField;
  final bool importAllFields;
  final bool isProcessing;
  final String? error;
  
  // Progress state
  final int totalRows;
  final int processedRows;
  final int skippedRows;
  final int errorRows;

  ImportWizardState({
    this.filePaths = const [],
    this.currentStep = ImportWizardStep.referenceRow,
    this.referenceRowIndex = 0,
    this.availableHeaders = const [],
    this.selectedColumns = const {},
    this.dedupKeyField,
    this.importAllFields = true,
    this.isProcessing = false,
    this.error,
    this.totalRows = 0,
    this.processedRows = 0,
    this.skippedRows = 0,
    this.errorRows = 0,
  });

  ImportWizardState copyWith({
    List<String>? filePaths,
    ImportWizardStep? currentStep,
    int? referenceRowIndex,
    List<String>? availableHeaders,
    Map<String, String>? selectedColumns,
    String? dedupKeyField,
    bool clearDedupKeyField = false,
    bool? importAllFields,
    bool? isProcessing,
    String? error,
    int? totalRows,
    int? processedRows,
    int? skippedRows,
    int? errorRows,
  }) {
    return ImportWizardState(
      filePaths: filePaths ?? this.filePaths,
      currentStep: currentStep ?? this.currentStep,
      referenceRowIndex: referenceRowIndex ?? this.referenceRowIndex,
      availableHeaders: availableHeaders ?? this.availableHeaders,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      dedupKeyField: clearDedupKeyField ? null : (dedupKeyField ?? this.dedupKeyField),
      importAllFields: importAllFields ?? this.importAllFields,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      totalRows: totalRows ?? this.totalRows,
      processedRows: processedRows ?? this.processedRows,
      skippedRows: skippedRows ?? this.skippedRows,
      errorRows: errorRows ?? this.errorRows,
    );
  }
}

class ImportWizardNotifier extends Notifier<ImportWizardState> {
  @override
  ImportWizardState build() {
    return ImportWizardState();
  }

  void setFilePaths(List<String> paths) {
    state = state.copyWith(filePaths: paths, currentStep: ImportWizardStep.referenceRow);
  }

  void setReferenceRow(int index) {
    state = state.copyWith(referenceRowIndex: index);
  }

  Future<void> loadHeaders() async {
    if (state.filePaths.isEmpty) return;
    
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final headers = await ExcelService.readHeaders(state.filePaths.first, state.referenceRowIndex);
      
      // Auto-map all columns if importAllFields is true
      Map<String, String> columnMap = {};
      for (int i = 0; i < headers.length; i++) {
        // Use integer string keys for unlimited column support
        String colKey = i.toString();
        if (headers[i].isNotEmpty) {
          columnMap[colKey] = headers[i];
        }
      }

      state = state.copyWith(
        availableHeaders: headers,
        selectedColumns: columnMap,
        isProcessing: false,
        currentStep: ImportWizardStep.columnSelector,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }
  
  void setImportAllFields(bool value) {
    state = state.copyWith(importAllFields: value);
  }

  void toggleColumn(String excelLetter, String headerName) {
    if (state.importAllFields) return; // Cannot manually toggle if 'import all' is true
    
    final currentMap = Map<String, String>.from(state.selectedColumns);
    if (currentMap.containsKey(excelLetter)) {
      currentMap.remove(excelLetter);
    } else {
      currentMap[excelLetter] = headerName;
    }
    state = state.copyWith(selectedColumns: currentMap);
  }

  void setDedupKey(String? keyField) {
    if (keyField == null) {
      state = state.copyWith(clearDedupKeyField: true);
    } else {
      state = state.copyWith(dedupKeyField: keyField);
    }
  }

  void goToPreview() {
    state = state.copyWith(currentStep: ImportWizardStep.preview);
  }

  /// Navigate to a specific step without reloading data
  void goToStep(ImportWizardStep step) {
    state = state.copyWith(currentStep: step);
  }

  Future<void> startImport() async {
    if (state.filePaths.isEmpty) return;
    
    state = state.copyWith(
      currentStep: ImportWizardStep.progress,
      isProcessing: true,
      processedRows: 0,
      skippedRows: 0,
      errorRows: 0,
    );

    try {
      final db = ref.read(databaseProvider);
      int totalAdded = 0;
      int totalSkipped = 0;
      
      for (final filePath in state.filePaths) {
        // Find existing profile or create new
        final profileName = p.basenameWithoutExtension(filePath);
        final existingProfiles = await db.profilesDao.getAllProfiles();
        int profileId;
        String? actualDedupKey = state.dedupKeyField;
        final matchingProfiles = existingProfiles.where((p) => p.name == profileName).toList();
        
        if (matchingProfiles.isNotEmpty) {
          profileId = matchingProfiles.first.id;
          actualDedupKey ??= matchingProfiles.first.dedupKeyField;
        } else {
          profileId = await db.profilesDao.insertProfile(
            ImportProfilesCompanion.insert(
              name: profileName,
              columnMap: jsonEncode(state.selectedColumns),
              referenceRowIndex: drift.Value(state.referenceRowIndex),
              dedupKeyField: drift.Value(state.dedupKeyField),
            )
          );
        }

        // Fetch existing keys to deduplicate efficiently without loading full entries or decoding JSON
        final Set<String> existingKeys = {};
        
        if (actualDedupKey != null) {
          // Use SQLite json_extract to get just the dedup values directly
          final rows = await db.customSelect(
            "SELECT json_extract(data, '\$.\"$actualDedupKey\"') as val FROM entries WHERE json_extract(data, '\$.\"$actualDedupKey\"') IS NOT NULL"
          ).get();
          
          for (final row in rows) {
            final val = row.read<String?>('val')?.trim();
            if (val != null && val.isNotEmpty) {
              existingKeys.add(arabicNormalize(val));
            }
          }
        } else {
          // Fallback: fetch only the search_payload column
          final rows = await db.customSelect(
            "SELECT search_payload as val FROM entries WHERE search_payload IS NOT NULL"
          ).get();
          
          for (final row in rows) {
            final val = row.read<String?>('val')?.trim();
            if (val != null && val.isNotEmpty) {
              existingKeys.add(val); // search_payload is already normalized
            }
          }
        }

        // Create Batch
        final fileHash = await HashService.hashFile(filePath);
        final batchId = await db.batchesDao.insertBatch(
          ImportBatchesCompanion.insert(
            profileId: profileId,
            originalFileName: p.basename(filePath),
            localFilePath: filePath,
            fileHash: fileHash,
          )
        );

        // Parse Data
        final parsedData = await ExcelService.parseData(
          filePath: filePath,
          columnMap: state.selectedColumns,
          referenceRowIndex: state.referenceRowIndex,
        );

        // Convert to Drift entries & Deduplicate
        final entriesList = <EntriesCompanion>[];
        int skippedInBatch = 0;

        for (final map in parsedData) {
          final payload = map.values.map((v) => arabicNormalize(v?.toString() ?? '')).join(' ');
          
          String dedupVal = '';
          if (actualDedupKey != null) {
            final val = map[actualDedupKey]?.toString().trim();
            if (val != null && val.isNotEmpty) {
              dedupVal = arabicNormalize(val);
            }
          } else {
            dedupVal = payload;
          }

          if (dedupVal.isNotEmpty) {
            if (existingKeys.contains(dedupVal)) {
              skippedInBatch++;
              totalSkipped++;
              continue;
            }
            existingKeys.add(dedupVal); // prevent duplicate in the same file
          }
          
          entriesList.add(EntriesCompanion.insert(
            profileId: profileId,
            importBatchId: drift.Value(batchId),
            data: jsonEncode(map),
            searchPayload: payload,
            sourceFile: drift.Value(p.basename(filePath)),
          ));
        }

        // Insert Audit Log
        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'IMPORT',
            description: 'Imported batch $batchId with ${entriesList.length} entries (Skipped $skippedInBatch duplicates) from ${p.basename(filePath)}',
          )
        );

        // Bulk Insert
        if (entriesList.isNotEmpty) {
          await db.entriesDao.insertEntriesBulk(entriesList);
        }

        // Update Batch Row Count
        final batch = await db.batchesDao.getBatch(batchId);
        await db.batchesDao.updateBatch(batch.copyWith(rowCount: entriesList.length));
        
        totalAdded += entriesList.length;
      }

      state = state.copyWith(
        currentStep: ImportWizardStep.summary,
        isProcessing: false,
        totalRows: totalAdded + totalSkipped,
        processedRows: totalAdded,
        skippedRows: totalSkipped,
      );
      
      // Refresh history data
      ref.invalidate(historyProvider);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = ImportWizardState();
  }
}

final importWizardProvider = NotifierProvider<ImportWizardNotifier, ImportWizardState>(() {
  return ImportWizardNotifier();
});

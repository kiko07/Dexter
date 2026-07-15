import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/excel_service.dart';
import '../../core/utils/hash_service.dart';
import '../../core/database/app_database.dart';
import '../search/search_provider.dart'; // For databaseProvider
import '../home/history_provider.dart';
import '../statistics/statistics_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;
import '../../core/utils/arabic_normalizer.dart';
import '../../core/utils/dedup_helper.dart';

enum ImportWizardStep {
  referenceRow,
  columnSelector,
  preview,
  progress,
  summary,
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

  final List<String> availableSheets;
  final List<String> selectedSheets;

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
    this.availableSheets = const [],
    this.selectedSheets = const [],
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
    List<String>? availableSheets,
    List<String>? selectedSheets,
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
      dedupKeyField: clearDedupKeyField
          ? null
          : (dedupKeyField ?? this.dedupKeyField),
      importAllFields: importAllFields ?? this.importAllFields,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      availableSheets: availableSheets ?? this.availableSheets,
      selectedSheets: selectedSheets ?? this.selectedSheets,
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

  Future<void> setFilePaths(List<String> paths) async {
    state = state.copyWith(
      filePaths: paths,
      currentStep: ImportWizardStep.referenceRow,
      availableSheets: const [],
      selectedSheets: const [],
      error: null,
    );
    if (paths.isNotEmpty) {
      try {
        final sheets = await ExcelService.getSheetNames(paths.first);
        state = state.copyWith(availableSheets: sheets, selectedSheets: sheets);
      } catch (e) {
        state = state.copyWith(error: e.toString());
        rethrow;
      }
    }
  }

  void setReferenceRow(int index) {
    state = state.copyWith(referenceRowIndex: index);
  }

  Future<void> loadHeaders() async {
    if (state.filePaths.isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final sheets = await ExcelService.getSheetNames(state.filePaths.first);
      final headers = await ExcelService.readHeaders(
        state.filePaths.first,
        state.referenceRowIndex,
        sheetName: state.selectedSheets.isNotEmpty
            ? state.selectedSheets.first
            : (sheets.isNotEmpty ? sheets.first : null),
      );

      final columnMap = ExcelService.buildColumnMap(headers);
      final selectedSheets = state.selectedSheets
          .where(sheets.contains)
          .toList();

      state = state.copyWith(
        availableHeaders: headers,
        selectedColumns: columnMap,
        availableSheets: sheets,
        selectedSheets: selectedSheets,
        isProcessing: false,
        currentStep: ImportWizardStep.columnSelector,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void toggleSheet(String sheetName) {
    final current = List<String>.from(state.selectedSheets);
    if (current.contains(sheetName)) {
      current.remove(sheetName);
    } else {
      current.add(sheetName);
    }
    state = state.copyWith(selectedSheets: current);
  }

  void setImportAllFields(bool value) {
    state = state.copyWith(importAllFields: value);
  }

  void toggleColumn(String excelLetter, String headerName) {
    if (state.importAllFields) {
      return; // Cannot manually toggle if 'import all' is true
    }

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
    if (state.selectedSheets.isEmpty) {
      state = state.copyWith(error: 'No sheets selected.');
      return;
    }

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
        final matchingProfiles = existingProfiles
            .where((p) => p.name == profileName)
            .toList();

        if (matchingProfiles.isNotEmpty) {
          final existingProfile = matchingProfiles.first;
          profileId = existingProfile.id;
          actualDedupKey ??= existingProfile.dedupKeyField;

          final updatedProfile = existingProfile.copyWith(
            columnMap: jsonEncode(state.selectedColumns),
            referenceRowIndex: state.referenceRowIndex,
            dedupKeyField: drift.Value(actualDedupKey),
          );
          await db.profilesDao.updateProfile(updatedProfile);
        } else {
          profileId = await db.profilesDao.insertProfile(
            ImportProfilesCompanion.insert(
              name: profileName,
              columnMap: jsonEncode(state.selectedColumns),
              referenceRowIndex: drift.Value(state.referenceRowIndex),
              dedupKeyField: drift.Value(state.dedupKeyField),
            ),
          );
        }

        // Fetch existing keys to deduplicate efficiently scoped to the profile
        final existingKeys = await DedupHelper.buildDedupSet(
          db,
          profileId,
          actualDedupKey,
        );

        // Create Batch
        final fileHash = await HashService.hashFile(filePath);
        final batchId = await db.batchesDao.insertBatch(
          ImportBatchesCompanion.insert(
            profileId: profileId,
            originalFileName: p.basename(filePath),
            localFilePath: filePath,
            fileHash: fileHash,
          ),
        );

        // Parse Data from all sheets and merge them into parsedData list
        final List<Map<String, dynamic>> parsedData = [];
        final allSheetsData = await ExcelService.parseAllSheets(
          filePath: filePath,
          columnMap: state.selectedColumns,
          referenceRowIndex: state.referenceRowIndex,
        );

        for (final entry in allSheetsData.entries) {
          final sheetName = entry.key;
          // Filter if sheet is selected by user (only applies to first selected file where UI is configured)
          // For other files, we import all sheets.
          final shouldApplySheetSelection = filePath == state.filePaths.first;
          if (shouldApplySheetSelection &&
              !state.selectedSheets.contains(sheetName)) {
            continue;
          }
          for (final row in entry.value) {
            final rowWithSheet = Map<String, dynamic>.from(row);
            rowWithSheet['_sheetName'] = sheetName;
            parsedData.add(rowWithSheet);
          }
        }

        // Convert to Drift entries & Deduplicate
        final entriesList = <EntriesCompanion>[];
        int skippedInBatch = 0;

        for (final map in parsedData) {
          // Keep source metadata in stored data, but exclude it from search and
          // dedup payloads.
          final cleanMap = Map<String, dynamic>.from(map);

          final payloadMap = DedupHelper.stripMetadataForDedup(cleanMap);
          final payload = payloadMap.values
              .map((v) => arabicNormalize(v?.toString() ?? ''))
              .join(' ');

          String dedupVal = '';
          if (actualDedupKey != null) {
            final val = cleanMap[actualDedupKey]?.toString();
            if (val != null && val.trim().isNotEmpty) {
              dedupVal = DedupHelper.normalizeForDedup(val);
            }
          } else {
            dedupVal = DedupHelper.normalizePayloadForDedup(cleanMap);
          }

          if (dedupVal.isNotEmpty) {
            if (existingKeys.contains(dedupVal)) {
              skippedInBatch++;
              totalSkipped++;
              continue;
            }
            existingKeys.add(dedupVal); // prevent duplicate in the same file
          }

          entriesList.add(
            EntriesCompanion.insert(
              profileId: profileId,
              importBatchId: drift.Value(batchId),
              data: jsonEncode(cleanMap), // Contains _sheetName if present
              searchPayload: payload,
              sourceFile: drift.Value(p.basename(filePath)),
            ),
          );
        }

        // Insert Audit Log
        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'IMPORT',
            description:
                'Imported batch $batchId with ${entriesList.length} entries (Skipped $skippedInBatch duplicates) from ${p.basename(filePath)}',
          ),
        );

        // Bulk Insert
        if (entriesList.isNotEmpty) {
          await db.entriesDao.insertEntriesBulk(entriesList);
        }

        // Update Batch Row Count
        final batch = await db.batchesDao.getBatch(batchId);
        await db.batchesDao.updateBatch(
          batch.copyWith(rowCount: entriesList.length),
        );

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
      ref.invalidate(statisticsProvider);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void reset() {
    state = ImportWizardState();
  }
}

final importWizardProvider =
    NotifierProvider<ImportWizardNotifier, ImportWizardState>(() {
      return ImportWizardNotifier();
    });

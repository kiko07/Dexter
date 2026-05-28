import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/utils/excel_service.dart';
import '../../core/utils/folder_scanner.dart';
import '../../core/utils/hash_service.dart';
import '../../core/utils/arabic_normalizer.dart';
import '../search/search_provider.dart';
import '../settings/settings_provider.dart';

class BackgroundScannerState {
  final bool isScanning;
  final String? lastMessage;

  BackgroundScannerState({this.isScanning = false, this.lastMessage});
}

class BackgroundScannerNotifier extends Notifier<BackgroundScannerState> {
  @override
  BackgroundScannerState build() {
    return BackgroundScannerState();
  }

  Future<void> scanNow({bool isManual = false}) async {
    if (state.isScanning) return;
    
    final settings = ref.read(settingsProvider).value;
    if (settings == null) return;
    
    // If not manual, and both settings are false, just return
    if (!isManual && !settings.autoScanImportedFiles && !settings.autoScanWatchedFolders) {
      return;
    }

    state = BackgroundScannerState(isScanning: true);
    final db = ref.read(databaseProvider);
    int totalNewRows = 0;

    try {
      // 1. Fetch existing keys globally once to deduplicate across all files
      final Set<String> existingKeys = {};
      final allEntries = await db.entriesDao.getAllEntries();

      // We pre-populate existingKeys with searchPayload as a fallback.
      // For specific dedupKeys, we will extract them inside the loop.
      for (final entry in allEntries) {
        existingKeys.add(entry.searchPayload);
      }

      // 2. Scan existing imported files for updates
      if (isManual || settings.autoScanImportedFiles) {
        final batches = await db.batchesDao.getAllBatches();
        for (final batch in batches) {
          final file = File(batch.localFilePath);
          if (!await file.exists()) continue;

          final newHash = await HashService.hashFile(batch.localFilePath);
          if (newHash != batch.fileHash) {
            // File changed! Re-import
            final profile = await db.profilesDao.getProfile(batch.profileId);
            final columnMap = (jsonDecode(profile.columnMap) as Map).cast<String, String>();
            
            // Re-populate existingKeys with this profile's specific dedup key if it exists
            if (profile.dedupKeyField != null) {
              for (final entry in allEntries) {
                try {
                  final map = jsonDecode(entry.data) as Map<String, dynamic>;
                  final val = map[profile.dedupKeyField]?.toString().trim();
                  if (val != null && val.isNotEmpty) {
                    existingKeys.add(arabicNormalize(val));
                  }
                } catch (_) {}
              }
            }

            final parsedData = await ExcelService.parseData(
              filePath: batch.localFilePath,
              columnMap: columnMap,
              referenceRowIndex: profile.referenceRowIndex,
            );

            final entriesList = <EntriesCompanion>[];
            for (final map in parsedData) {
              final payload = map.values.map((v) => arabicNormalize(v?.toString() ?? '')).join(' ');
              String dedupVal = '';
              if (profile.dedupKeyField != null) {
                final val = map[profile.dedupKeyField]?.toString().trim();
                if (val != null && val.isNotEmpty) {
                  dedupVal = arabicNormalize(val);
                }
              } else {
                dedupVal = payload;
              }

              if (dedupVal.isNotEmpty) {
                if (existingKeys.contains(dedupVal)) continue; // Skip duplicate
                existingKeys.add(dedupVal);
              }
              
              entriesList.add(EntriesCompanion.insert(
                profileId: profile.id,
                importBatchId: drift.Value(batch.id),
                data: jsonEncode(map),
                searchPayload: payload,
                sourceFile: drift.Value(p.basename(batch.localFilePath)),
              ));
            }

            if (entriesList.isNotEmpty) {
              await db.entriesDao.insertEntriesBulk(entriesList);
              totalNewRows += entriesList.length;
              
              await db.batchesDao.updateBatch(
                batch.copyWith(
                  fileHash: newHash,
                  rowCount: batch.rowCount + entriesList.length,
                )
              );

              await db.auditDao.insertLog(AuditLogCompanion.insert(
                action: 'AUTO_SCAN',
                description: 'Auto-updated ${entriesList.length} new rows from ${batch.originalFileName}',
              ));
            }
          }
        }
      }

      // 3. Scan Watched Folders for NEW files
      if (isManual || settings.autoScanWatchedFolders) {
        final existingBatchPaths = (await db.batchesDao.getAllBatches()).map((b) => b.localFilePath).toSet();
        
        for (final folderPath in settings.watchedFolders) {
          final dir = Directory(folderPath);
          if (!await dir.exists()) continue;

          final files = await FolderScanner.scanForExcelFiles(folderPath);
          for (final file in files) {
            if (!existingBatchPaths.contains(file.path)) {
              // This is a new file!
              final headers = await ExcelService.readHeaders(file.path, 0); // Assume row 0
              if (headers.isEmpty) continue;
              
              Map<String, String> columnMap = {};
              for (int i = 0; i < headers.length; i++) {
                if (headers[i].isNotEmpty) {
                  columnMap[i.toString()] = headers[i];
                }
              }

              // Create profile
              final profileName = p.basenameWithoutExtension(file.path);
              int profileId;
              
              final existingProfiles = await db.profilesDao.getAllProfiles();
              final matchingProfiles = existingProfiles.where((p) => p.name == profileName).toList();
              if (matchingProfiles.isNotEmpty) {
                profileId = matchingProfiles.first.id;
              } else {
                profileId = await db.profilesDao.insertProfile(
                  ImportProfilesCompanion.insert(
                    name: profileName,
                    columnMap: jsonEncode(columnMap),
                    referenceRowIndex: const drift.Value(0),
                    dedupKeyField: const drift.Value(null),
                  )
                );
              }

              // Create batch
              final fileHash = await HashService.hashFile(file.path);
              final batchId = await db.batchesDao.insertBatch(
                ImportBatchesCompanion.insert(
                  profileId: profileId,
                  originalFileName: p.basename(file.path),
                  localFilePath: file.path,
                  fileHash: fileHash,
                )
              );

              // Parse data
              final parsedData = await ExcelService.parseData(
                filePath: file.path,
                columnMap: columnMap,
                referenceRowIndex: 0,
              );

              final entriesList = <EntriesCompanion>[];
              for (final map in parsedData) {
                final payload = map.values.map((v) => arabicNormalize(v?.toString() ?? '')).join(' ');
                
                if (payload.isNotEmpty) {
                  if (existingKeys.contains(payload)) continue; // Exact duplicate
                  existingKeys.add(payload);
                }
                
                entriesList.add(EntriesCompanion.insert(
                  profileId: profileId,
                  importBatchId: drift.Value(batchId),
                  data: jsonEncode(map),
                  searchPayload: payload,
                  sourceFile: drift.Value(p.basename(file.path)),
                ));
              }

              if (entriesList.isNotEmpty) {
                await db.entriesDao.insertEntriesBulk(entriesList);
                totalNewRows += entriesList.length;
                
                final batch = await db.batchesDao.getBatch(batchId);
                await db.batchesDao.updateBatch(batch.copyWith(rowCount: entriesList.length));

                await db.auditDao.insertLog(AuditLogCompanion.insert(
                  action: 'AUTO_SCAN_NEW',
                  description: 'Auto-indexed new file ${p.basename(file.path)} with ${entriesList.length} rows',
                ));
              }
            }
          }
        }
      }

      state = BackgroundScannerState(isScanning: false, lastMessage: 'autoUpdateSuccess:$totalNewRows');
    } catch (e) {
      debugPrint('Auto Scan Error: $e');
      state = BackgroundScannerState(isScanning: false, lastMessage: 'autoUpdateError:$e');
    }
  }
}

final backgroundScannerProvider = NotifierProvider<BackgroundScannerNotifier, BackgroundScannerState>(() {
  return BackgroundScannerNotifier();
});

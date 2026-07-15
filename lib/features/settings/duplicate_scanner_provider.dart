import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/dedup_helper.dart';
import '../search/search_provider.dart'; // for databaseProvider
import '../statistics/statistics_provider.dart';

class DuplicateGroup {
  final String dedupKey;
  final String fieldName; // Column header name or the __payload__ sentinel.
  final List<Entry> entries;

  DuplicateGroup({
    required this.dedupKey,
    required this.fieldName,
    required this.entries,
  });
}

class DuplicateScanState {
  final bool isScanning;
  final List<DuplicateGroup> duplicateGroups;
  final int totalDuplicates;
  final String? error;

  DuplicateScanState({
    this.isScanning = false,
    this.duplicateGroups = const [],
    this.totalDuplicates = 0,
    this.error,
  });

  DuplicateScanState copyWith({
    bool? isScanning,
    List<DuplicateGroup>? duplicateGroups,
    int? totalDuplicates,
    String? error,
  }) {
    return DuplicateScanState(
      isScanning: isScanning ?? this.isScanning,
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      totalDuplicates: totalDuplicates ?? this.totalDuplicates,
      error: error,
    );
  }
}

class DuplicateScannerNotifier extends Notifier<DuplicateScanState> {
  @override
  DuplicateScanState build() {
    return DuplicateScanState();
  }

  Future<void> scanForDuplicates() async {
    state = state.copyWith(isScanning: true, error: null, duplicateGroups: []);
    final db = ref.read(databaseProvider);

    try {
      final profiles = await db.profilesDao.getAllProfiles();
      final List<DuplicateGroup> allGroups = [];
      int totalDuplicatesCount = 0;

      for (final profile in profiles) {
        final dedupKey = profile.dedupKeyField;
        final groupedEntries = <String, List<Entry>>{};
        final entries = await db.entriesDao.getEntriesByProfile(profile.id);

        for (final entry in entries) {
          try {
            final data = (jsonDecode(entry.data) as Map)
                .cast<String, dynamic>();
            final String key;
            if (dedupKey != null && dedupKey.isNotEmpty) {
              final value = data[dedupKey]?.toString();
              key = value == null ? '' : DedupHelper.normalizeForDedup(value);
            } else {
              key = DedupHelper.normalizePayloadForDedup(data);
            }
            if (key.isNotEmpty) {
              groupedEntries.putIfAbsent(key, () => []).add(entry);
            }
          } catch (_) {
            // Ignore malformed legacy rows and continue scanning valid data.
          }
        }

        for (final group in groupedEntries.entries) {
          if (group.value.length <= 1) continue;
          allGroups.add(
            DuplicateGroup(
              dedupKey: group.key,
              fieldName: dedupKey?.isNotEmpty == true
                  ? dedupKey!
                  : '__payload__',
              entries: group.value,
            ),
          );
          totalDuplicatesCount += group.value.length - 1;
        }
      }

      state = state.copyWith(
        isScanning: false,
        duplicateGroups: allGroups,
        totalDuplicates: totalDuplicatesCount,
      );
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }

  Future<void> deleteEntry(int entryId) async {
    final db = ref.read(databaseProvider);
    final entry = state.duplicateGroups
        .expand((group) => group.entries)
        .where((entry) => entry.id == entryId)
        .firstOrNull;

    await db.transaction(() async {
      await db.entriesDao.deleteEntry(entryId);
      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'DELETE',
          description: 'Deleted duplicate entry ID: $entryId',
          entryId: drift.Value(entryId),
        ),
      );
      await _decrementBatchCounts(
        db,
        entry?.importBatchId == null ? const {} : {entry!.importBatchId!: 1},
      );
    });

    // Remove from UI list
    final updatedGroups = <DuplicateGroup>[];

    for (final group in state.duplicateGroups) {
      final remaining = group.entries.where((e) => e.id != entryId).toList();
      if (remaining.length > 1) {
        updatedGroups.add(
          DuplicateGroup(
            dedupKey: group.dedupKey,
            fieldName: group.fieldName,
            entries: remaining,
          ),
        );
      }
    }

    state = state.copyWith(
      duplicateGroups: updatedGroups,
      totalDuplicates: _countRedundantEntries(updatedGroups),
    );
    ref.invalidate(statisticsProvider);
  }

  Future<void> keepOneDeleteRest(DuplicateGroup group) async {
    if (group.entries.length <= 1) return;

    // Keep the first entry, delete the rest
    final toDelete = group.entries.sublist(1);
    final db = ref.read(databaseProvider);
    final deletionsByBatch = <int, int>{};
    for (final entry in toDelete) {
      final batchId = entry.importBatchId;
      if (batchId != null) {
        deletionsByBatch.update(
          batchId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    await db.transaction(() async {
      for (final entry in toDelete) {
        await db.entriesDao.deleteEntry(entry.id);
        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'DELETE',
            description:
                'Deleted duplicate entry ID: ${entry.id} via bulk clean',
            entryId: drift.Value(entry.id),
          ),
        );
      }
      await _decrementBatchCounts(db, deletionsByBatch);
    });

    // Remove from UI list
    final updatedGroups = state.duplicateGroups
        .where((g) => !identical(g, group))
        .toList();

    state = state.copyWith(
      duplicateGroups: updatedGroups,
      totalDuplicates: _countRedundantEntries(updatedGroups),
    );
    ref.invalidate(statisticsProvider);
  }

  int _countRedundantEntries(List<DuplicateGroup> groups) {
    return groups.fold<int>(
      0,
      (sum, group) => sum + (group.entries.length - 1),
    );
  }

  Future<void> _decrementBatchCounts(
    AppDatabase db,
    Map<int, int> deletionsByBatch,
  ) async {
    for (final deletion in deletionsByBatch.entries) {
      final batch = await db.batchesDao.getBatch(deletion.key);
      final remaining = batch.rowCount - deletion.value;
      await db.batchesDao.updateBatch(
        batch.copyWith(rowCount: remaining < 0 ? 0 : remaining),
      );
    }
  }
}

final duplicateScannerProvider =
    NotifierProvider.autoDispose<DuplicateScannerNotifier, DuplicateScanState>(
      () {
        return DuplicateScannerNotifier();
      },
    );

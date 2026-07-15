import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../search/search_provider.dart'; // For databaseProvider
import '../statistics/statistics_provider.dart';

class HistoryState {
  final List<ImportBatch> batches;
  final bool isLoading;

  HistoryState({this.batches = const [], this.isLoading = false});

  HistoryState copyWith({List<ImportBatch>? batches, bool? isLoading}) {
    return HistoryState(
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    // Need to use Future.microtask or similar to call loadHistory,
    // but simple loadHistory here is fine if not awaiting, though it's better to run async.
    Future.microtask(() => loadHistory());
    return HistoryState();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final db = ref.read(databaseProvider);
    try {
      final allBatches = await db.batchesDao.getAllBatches();
      allBatches.sort((a, b) => b.importedAt.compareTo(a.importedAt));
      state = state.copyWith(batches: allBatches, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> undoBatch(ImportBatch batch) async {
    final db = ref.read(databaseProvider);

    await db.transaction(() async {
      await db.entriesDao.deleteEntriesByBatch(batch.id);
      await db.batchesDao.deleteBatch(batch.id);
      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'ROLLBACK',
          description:
              'Rolled back import batch ${batch.id} (${batch.originalFileName})',
        ),
      );
    });

    // Refresh
    ref.invalidate(statisticsProvider);
    await loadHistory();
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});

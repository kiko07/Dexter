import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../search/search_provider.dart';

enum StatisticsRange { last7Days, last30Days, allTime }

class TimelinePoint {
  final DateTime periodStart;
  final int count;

  const TimelinePoint({required this.periodStart, required this.count});
}

class CategoryStatistic {
  final String? label;
  final int count;

  const CategoryStatistic({required this.label, required this.count});
}

class StatisticsSnapshot {
  final int totalRecords;
  final int manualRecords;
  final int indexedFiles;
  final int profiles;
  final List<TimelinePoint> timeline;
  final List<CategoryStatistic> bySource;
  final List<CategoryStatistic> byProfile;

  const StatisticsSnapshot({
    this.totalRecords = 0,
    this.manualRecords = 0,
    this.indexedFiles = 0,
    this.profiles = 0,
    this.timeline = const [],
    this.bySource = const [],
    this.byProfile = const [],
  });

  int get recordsInRange => timeline.fold(0, (sum, point) => sum + point.count);
}

class StatisticsState {
  final StatisticsRange range;
  final StatisticsSnapshot snapshot;
  final bool isLoading;
  final String? error;

  const StatisticsState({
    this.range = StatisticsRange.last30Days,
    this.snapshot = const StatisticsSnapshot(),
    this.isLoading = false,
    this.error,
  });

  StatisticsState copyWith({
    StatisticsRange? range,
    StatisticsSnapshot? snapshot,
    bool? isLoading,
    String? error,
  }) {
    return StatisticsState(
      range: range ?? this.range,
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StatisticsNotifier extends Notifier<StatisticsState> {
  int _generation = 0;

  @override
  StatisticsState build() {
    Future.microtask(refresh);
    return const StatisticsState();
  }

  Future<void> setRange(StatisticsRange range) async {
    if (range == state.range) return;
    state = state.copyWith(range: range);
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    final range = state.range;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _loadSnapshot(ref.read(databaseProvider), range);
      if (generation != _generation) return;
      state = state.copyWith(snapshot: snapshot, isLoading: false, error: null);
    } catch (error) {
      if (generation != _generation) return;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}

final statisticsProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(
      StatisticsNotifier.new,
    );

Future<StatisticsSnapshot> _loadSnapshot(
  AppDatabase db,
  StatisticsRange range,
) async {
  final results = await Future.wait<Object>([
    _loadTotals(db),
    _loadTimeline(db, range),
    _loadCategoryStats(db, range, byProfile: false),
    _loadCategoryStats(db, range, byProfile: true),
  ]);
  final totals = results[0] as _StatisticsTotals;

  return StatisticsSnapshot(
    totalRecords: totals.totalRecords,
    manualRecords: totals.manualRecords,
    indexedFiles: totals.indexedFiles,
    profiles: totals.profiles,
    timeline: results[1] as List<TimelinePoint>,
    bySource: results[2] as List<CategoryStatistic>,
    byProfile: results[3] as List<CategoryStatistic>,
  );
}

Future<_StatisticsTotals> _loadTotals(AppDatabase db) async {
  final row = await db
      .customSelect(
        '''
      SELECT
        (SELECT COUNT(*) FROM entries) AS total_records,
        (SELECT COUNT(*) FROM entries WHERE source_file IS NULL) AS manual_records,
        (SELECT COUNT(DISTINCT local_file_path) FROM import_batches) AS indexed_files,
        (SELECT COUNT(*) FROM import_profiles) AS profiles
    ''',
        readsFrom: {db.entries, db.importBatches, db.importProfiles},
      )
      .getSingle();

  return _StatisticsTotals(
    totalRecords: row.read<int>('total_records'),
    manualRecords: row.read<int>('manual_records'),
    indexedFiles: row.read<int>('indexed_files'),
    profiles: row.read<int>('profiles'),
  );
}

Future<List<TimelinePoint>> _loadTimeline(
  AppDatabase db,
  StatisticsRange range,
) async {
  final cutoff = _cutoffFor(range);
  final variables = <Variable>[];
  final where = cutoff == null ? '' : 'WHERE created_at >= ?';
  if (cutoff != null) {
    variables.add(Variable.withInt(cutoff.millisecondsSinceEpoch ~/ 1000));
  }
  final periodExpression = range == StatisticsRange.allTime
      ? "strftime('%Y-%m-01', created_at, 'unixepoch', 'localtime')"
      : "strftime('%Y-%m-%d', created_at, 'unixepoch', 'localtime')";

  final rows = await db
      .customSelect(
        '''
      SELECT $periodExpression AS period, COUNT(*) AS count
      FROM entries
      $where
      GROUP BY period
      ORDER BY period
    ''',
        variables: variables,
        readsFrom: {db.entries},
      )
      .get();
  final counts = <DateTime, int>{};
  for (final row in rows) {
    final period = DateTime.tryParse(row.read<String>('period'));
    if (period != null) counts[period] = row.read<int>('count');
  }

  return _fillTimeline(counts, range);
}

Future<List<CategoryStatistic>> _loadCategoryStats(
  AppDatabase db,
  StatisticsRange range, {
  required bool byProfile,
}) async {
  final cutoff = _cutoffFor(range);
  final variables = <Variable>[];
  final where = cutoff == null ? '' : 'WHERE e.created_at >= ?';
  if (cutoff != null) {
    variables.add(Variable.withInt(cutoff.millisecondsSinceEpoch ~/ 1000));
  }

  final rows = await db
      .customSelect(
        byProfile
            ? '''
            SELECT p.name AS label, COUNT(*) AS count
            FROM entries e
            INNER JOIN import_profiles p ON p.id = e.profile_id
            $where
            GROUP BY p.id, p.name
            ORDER BY count DESC, p.name
            LIMIT 8
          '''
            : '''
            SELECT e.source_file AS label, COUNT(*) AS count
            FROM entries e
            $where
            GROUP BY e.source_file
            ORDER BY count DESC, e.source_file
            LIMIT 8
          ''',
        variables: variables,
        readsFrom: {db.entries, if (byProfile) db.importProfiles},
      )
      .get();

  return [
    for (final row in rows)
      CategoryStatistic(
        label: row.data['label']?.toString(),
        count: row.read<int>('count'),
      ),
  ];
}

DateTime? _cutoffFor(StatisticsRange range) {
  if (range == StatisticsRange.allTime) return null;
  final days = range == StatisticsRange.last7Days ? 7 : 30;
  final today = _startOfDay(DateTime.now());
  return today.subtract(Duration(days: days - 1));
}

List<TimelinePoint> _fillTimeline(
  Map<DateTime, int> counts,
  StatisticsRange range,
) {
  if (range != StatisticsRange.allTime) {
    final days = range == StatisticsRange.last7Days ? 7 : 30;
    final today = _startOfDay(DateTime.now());
    return [
      for (var offset = days - 1; offset >= 0; offset--)
        TimelinePoint(
          periodStart: today.subtract(Duration(days: offset)),
          count: counts[today.subtract(Duration(days: offset))] ?? 0,
        ),
    ];
  }

  if (counts.isEmpty) return const [];
  var month = DateTime(counts.keys.first.year, counts.keys.first.month);
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final points = <TimelinePoint>[];
  while (!month.isAfter(currentMonth)) {
    points.add(TimelinePoint(periodStart: month, count: counts[month] ?? 0));
    month = DateTime(month.year, month.month + 1);
  }
  return points;
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

class _StatisticsTotals {
  final int totalRecords;
  final int manualRecords;
  final int indexedFiles;
  final int profiles;

  const _StatisticsTotals({
    required this.totalRecords,
    required this.manualRecords,
    required this.indexedFiles,
    required this.profiles,
  });
}

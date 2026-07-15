import 'package:drift/drift.dart';

import '../app_database.dart';
import '../search_criteria.dart';
import '../tables.dart';
import '../../utils/dedup_helper.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [Entries])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<List<Entry>> getAllEntries() => select(entries).get();

  Future<List<Entry>> getEntriesByProfile(int profileId) =>
      (select(entries)..where((t) => t.profileId.equals(profileId))).get();

  Future<Entry> getEntry(int id) =>
      (select(entries)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertEntry(EntriesCompanion entry) =>
      into(entries).insert(entry);

  Future<void> insertEntriesBulk(List<EntriesCompanion> entriesList) async {
    await batch((batch) {
      batch.insertAll(entries, entriesList);
    });
  }

  Future<bool> updateEntry(Entry entry) =>
      update(entries).replace(entry.copyWith(updatedAt: DateTime.now()));

  Future<int> deleteEntry(int id) =>
      (delete(entries)..where((t) => t.id.equals(id))).go();

  Future<int> deleteEntriesByBatch(int batchId) {
    return (delete(
      entries,
    )..where((t) => t.importBatchId.equals(batchId))).go();
  }

  Future<List<Entry>> searchEntries({
    required String query,
    required String matchMode,
    String sortBy = 'newest',
    int? limit,
    int? offset,
    int? profileId,
    List<String>? sourceFiles,
    bool manualOnly = false,
    List<EntrySearchFilter> filters = const [],
  }) async {
    final criteria = EntrySearchCriteria(
      query: query,
      matchMode: matchMode,
      sortBy: sortBy,
      limit: limit,
      offset: offset,
      profileId: profileId,
      sourceFiles: sourceFiles,
      manualOnly: manualOnly,
      filters: filters,
    );
    final built = _buildSearchSql(criteria, countOnly: false);
    if (built == null) return [];

    final result = await customSelect(
      built.sql,
      variables: built.variables,
      readsFrom: {entries},
    ).get();

    return result.map((row) => entries.map(row.data)).toList();
  }

  Future<List<Entry>> getEntriesByDateRange(DateTime? start, DateTime? end) {
    final s = select(entries);
    if (start != null) {
      s.where((t) => t.createdAt.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      s.where((t) => t.createdAt.isSmallerOrEqualValue(end));
    }
    s.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return s.get();
  }

  Future<int> countSearchEntries({
    required String query,
    required String matchMode,
    int? profileId,
    List<String>? sourceFiles,
    bool manualOnly = false,
    List<EntrySearchFilter> filters = const [],
  }) async {
    final criteria = EntrySearchCriteria(
      query: query,
      matchMode: matchMode,
      profileId: profileId,
      sourceFiles: sourceFiles,
      manualOnly: manualOnly,
      filters: filters,
    );
    final built = _buildSearchSql(criteria, countOnly: true);
    if (built == null) return 0;

    final result = await customSelect(
      built.sql,
      variables: built.variables,
      readsFrom: {entries},
    ).getSingle();
    return result.read<int>('c');
  }

  Future<List<String>> getDistinctSourceFiles() async {
    final result = await customSelect(
      "SELECT DISTINCT source_file FROM entries WHERE source_file IS NOT NULL ORDER BY source_file",
    ).get();
    return result.map((r) => r.read<String>('source_file')).toList();
  }

  Future<List<String>> getAvailableFieldNames() async {
    final result = await customSelect(
      "SELECT DISTINCT jk.key FROM entries, json_each(entries.data) AS jk WHERE jk.key NOT LIKE '\\_%' ESCAPE '\\' ORDER BY jk.key",
    ).get();
    return result.map((r) => r.read<String>('key')).toList();
  }

  _BuiltSearch? _buildSearchSql(
    EntrySearchCriteria criteria, {
    required bool countOnly,
  }) {
    final variables = <Variable>[];
    final where = <String>[];
    final query = criteria.query.trim();
    var from = 'FROM entries e';

    if (criteria.profileId != null) {
      where.add('e.profile_id = ?');
      variables.add(Variable.withInt(criteria.profileId!));
    }

    if (criteria.manualOnly) {
      where.add('e.source_file IS NULL');
    } else if (criteria.sourceFiles != null &&
        criteria.sourceFiles!.isNotEmpty) {
      where.add(
        'e.source_file IN (${List.filled(criteria.sourceFiles!.length, '?').join(',')})',
      );
      variables.addAll(criteria.sourceFiles!.map(Variable.withString));
    }

    if (query.isNotEmpty) {
      switch (criteria.matchMode) {
        case 'exact':
          where.add('''
            EXISTS (
              SELECT 1 FROM json_each(e.data) field
              WHERE field.key NOT LIKE '\\_%' ESCAPE '\\'
              AND lower(CAST(field.value AS TEXT)) = lower(?)
            )
          ''');
          variables.add(Variable.withString(query));
          break;
        case 'startsWith':
          final sanitizedQuery = query
              .replaceAll(RegExp(r'["\*\(\)\+\-\^]'), '')
              .trim();
          if (sanitizedQuery.isEmpty) return null;
          from = '''
            FROM entries e
            INNER JOIN entries_fts fts ON fts.rowid = e.id
          ''';
          where.add('entries_fts MATCH ?');
          variables.add(Variable.withString('"$sanitizedQuery"*'));
          break;
        case 'fuzzy':
          break;
        case 'contains':
        default:
          where.add("lower(e.search_payload) LIKE lower(?) ESCAPE '\\'");
          variables.add(Variable.withString(_containsPattern(query)));
          break;
      }
    }

    for (final filter in criteria.filters) {
      final condition = _filterCondition(filter, variables);
      if (condition != null) {
        where.add(condition);
      }
    }

    final buffer = StringBuffer();
    buffer.write(countOnly ? 'SELECT COUNT(*) as c ' : 'SELECT e.* ');
    buffer.write(from);
    if (where.isNotEmpty) {
      buffer.write(' WHERE ${where.join(' AND ')}');
    }

    if (!countOnly) {
      buffer.write(_orderBy(criteria.sortBy));
      if (criteria.limit != null) {
        buffer.write(' LIMIT ?');
        variables.add(Variable.withInt(criteria.limit!));
        if (criteria.offset != null) {
          buffer.write(' OFFSET ?');
          variables.add(Variable.withInt(criteria.offset!));
        }
      }
    }

    return _BuiltSearch(buffer.toString(), variables);
  }

  String _orderBy(String sortBy) {
    switch (sortBy) {
      case 'oldest':
        return ' ORDER BY e.created_at ASC';
      case 'alphabetical_asc':
        return ' ORDER BY e.search_payload ASC';
      case 'alphabetical_desc':
        return ' ORDER BY e.search_payload DESC';
      case 'newest':
      default:
        return ' ORDER BY e.created_at DESC';
    }
  }

  String? _filterCondition(EntrySearchFilter filter, List<Variable> variables) {
    if (!_allowsEmptyValue(filter.operator) && filter.value.trim().isEmpty) {
      return null;
    }

    final target = _filterTarget(filter.fieldName);

    if (target.isAnyField) {
      if (filter.operator == 'isMissing') {
        return '''
          NOT EXISTS (
            SELECT 1 FROM json_each(e.data) field
            WHERE field.key NOT LIKE '\\_%' ESCAPE '\\'
          )
        ''';
      }

      final negativeOperator = _positiveAnyFieldOperator(filter.operator);
      final effectiveFilter = negativeOperator == null
          ? filter
          : EntrySearchFilter(
              fieldName: filter.fieldName,
              operator: negativeOperator,
              value: filter.value,
              value2: filter.value2,
            );
      final clause = _conditionForTarget(effectiveFilter, target, variables);
      if (clause == null) return null;

      final existsClause =
          '''
        EXISTS (
          SELECT 1 FROM json_each(e.data) field
          WHERE field.key NOT LIKE '\\_%' ESCAPE '\\'
          AND $clause
        )
      ''';
      return negativeOperator == null ? existsClause : 'NOT ($existsClause)';
    }

    return _conditionForTarget(filter, target, variables);
  }

  _FilterTarget _filterTarget(String fieldName) {
    switch (fieldName) {
      case '__id__':
        return const _FilterTarget(
          valueExpression: 'e.id',
          presentExpression: '1 = 1',
          missingExpression: '0 = 1',
        );
      case '__profileId__':
        return const _FilterTarget(
          valueExpression: 'e.profile_id',
          presentExpression: '1 = 1',
          missingExpression: '0 = 1',
        );
      case '__sourceFile__':
        return const _FilterTarget(
          valueExpression: 'e.source_file',
          presentExpression: 'e.source_file IS NOT NULL',
          missingExpression: 'e.source_file IS NULL',
        );
      case '__importBatchId__':
        return const _FilterTarget(
          valueExpression: 'e.import_batch_id',
          presentExpression: 'e.import_batch_id IS NOT NULL',
          missingExpression: 'e.import_batch_id IS NULL',
        );
      case '__createdAt__':
        return const _FilterTarget(
          valueExpression: 'e.created_at',
          presentExpression: '1 = 1',
          missingExpression: '0 = 1',
          storesDateTime: true,
        );
      case '__updatedAt__':
        return const _FilterTarget(
          valueExpression: 'e.updated_at',
          presentExpression: '1 = 1',
          missingExpression: '0 = 1',
          storesDateTime: true,
        );
      case '__any__':
        return const _FilterTarget(
          valueExpression: 'field.value',
          presentExpression: '1 = 1',
          missingExpression: '0 = 1',
          isAnyField: true,
        );
      default:
        final jsonPath = DedupHelper.quoteJsonPath(fieldName);
        return _FilterTarget(
          valueExpression: "json_extract(e.data, '$jsonPath')",
          presentExpression: "json_type(e.data, '$jsonPath') IS NOT NULL",
          missingExpression: "json_type(e.data, '$jsonPath') IS NULL",
        );
    }
  }

  String? _conditionForTarget(
    EntrySearchFilter filter,
    _FilterTarget target,
    List<Variable> variables,
  ) {
    final expression = target.valueExpression;
    final textExpression = 'CAST($expression AS TEXT)';
    final value = filter.value.trim();

    switch (filter.operator) {
      case 'isPresent':
        return target.presentExpression;
      case 'isMissing':
        return target.missingExpression;
      case 'isEmpty':
        return '${target.presentExpression} AND '
            '($expression IS NULL OR length(trim($textExpression)) = 0)';
      case 'isNotEmpty':
        return '${target.presentExpression} AND '
            '$expression IS NOT NULL AND length(trim($textExpression)) > 0';
      case 'notContains':
        variables.add(Variable.withString(_containsPattern(value)));
        return "$expression IS NOT NULL AND lower($textExpression) NOT LIKE lower(?) ESCAPE '\\'";
      case 'containsCaseSensitive':
        variables.add(Variable.withString(value));
        return '$expression IS NOT NULL AND instr($textExpression, ?) > 0';
      case 'eqCaseSensitive':
        variables.add(Variable.withString(value));
        return '$expression IS NOT NULL AND $textExpression = ?';
      case 'neqCaseSensitive':
        variables.add(Variable.withString(value));
        return '$expression IS NOT NULL AND $textExpression != ?';
      case 'startsWith':
        variables.add(Variable.withString('${_escapeLike(value)}%'));
        return "$expression IS NOT NULL AND lower($textExpression) LIKE lower(?) ESCAPE '\\'";
      case 'notStartsWith':
        variables.add(Variable.withString('${_escapeLike(value)}%'));
        return "$expression IS NOT NULL AND lower($textExpression) NOT LIKE lower(?) ESCAPE '\\'";
      case 'endsWith':
        variables.add(Variable.withString('%${_escapeLike(value)}'));
        return "$expression IS NOT NULL AND lower($textExpression) LIKE lower(?) ESCAPE '\\'";
      case 'notEndsWith':
        variables.add(Variable.withString('%${_escapeLike(value)}'));
        return "$expression IS NOT NULL AND lower($textExpression) NOT LIKE lower(?) ESCAPE '\\'";
      case 'containsAll':
        final terms = _splitTerms(value);
        if (terms.isEmpty) return null;
        final clauses = terms
            .map((term) {
              variables.add(Variable.withString(_containsPattern(term)));
              return "lower($textExpression) LIKE lower(?) ESCAPE '\\'";
            })
            .join(' AND ');
        return '$expression IS NOT NULL AND ($clauses)';
      case 'containsAny':
        final terms = _splitTerms(value);
        if (terms.isEmpty) return null;
        final clauses = terms
            .map((term) {
              variables.add(Variable.withString(_containsPattern(term)));
              return "lower($textExpression) LIKE lower(?) ESCAPE '\\'";
            })
            .join(' OR ');
        return '$expression IS NOT NULL AND ($clauses)';
      case 'containsNone':
        final terms = _splitTerms(value);
        if (terms.isEmpty) return null;
        final clauses = terms
            .map((term) {
              variables.add(Variable.withString(_containsPattern(term)));
              return "lower($textExpression) NOT LIKE lower(?) ESCAPE '\\'";
            })
            .join(' AND ');
        return '$expression IS NOT NULL AND ($clauses)';
      case 'inList':
        final values = _splitList(value);
        if (values.isEmpty) return null;
        variables.addAll(values.map((v) => Variable.withString(v)));
        return '$expression IS NOT NULL AND lower($textExpression) IN '
            '(${List.filled(values.length, '?').join(',')})';
      case 'notInList':
        final values = _splitList(value);
        if (values.isEmpty) return null;
        variables.addAll(values.map((v) => Variable.withString(v)));
        return '$expression IS NOT NULL AND lower($textExpression) NOT IN '
            '(${List.filled(values.length, '?').join(',')})';
      case 'eq':
        variables.add(Variable.withString(value));
        return '$expression IS NOT NULL AND lower($textExpression) = lower(?)';
      case 'neq':
        variables.add(Variable.withString(value));
        return '$expression IS NOT NULL AND lower($textExpression) != lower(?)';
      case 'gt':
        return _numericComparison(expression, value, '>', variables);
      case 'lt':
        return _numericComparison(expression, value, '<', variables);
      case 'gte':
        return _numericComparison(expression, value, '>=', variables);
      case 'lte':
        return _numericComparison(expression, value, '<=', variables);
      case 'between':
        return _numericBetween(
          expression,
          value,
          filter.value2?.trim() ?? '',
          variables,
        );
      case 'notBetween':
        return _numericBetween(
          expression,
          value,
          filter.value2?.trim() ?? '',
          variables,
          negate: true,
        );
      case 'isNumeric':
        return _numericSqlGuard(expression);
      case 'isNotNumeric':
        return '$expression IS NOT NULL AND NOT '
            '(${_numericTypeSqlGuard(expression)})';
      case 'dateBefore':
        return _dateComparison(target, value, '<', variables);
      case 'dateAfter':
        return _dateComparison(target, value, '>', variables);
      case 'dateOn':
        return _dateOn(target, value, variables);
      case 'dateNotOn':
        return _dateNotOn(target, value, variables);
      case 'dateBetween':
        return _dateBetween(
          target,
          value,
          filter.value2?.trim() ?? '',
          variables,
        );
      case 'dateToday':
        return _dateOn(target, _dateOnly(DateTime.now()), variables);
      case 'dateInLastDays':
        return _dateInLastDays(target, value, variables);
      case 'lengthEq':
        return _lengthComparison(expression, value, '=', variables);
      case 'lengthGt':
        return _lengthComparison(expression, value, '>', variables);
      case 'lengthLt':
        return _lengthComparison(expression, value, '<', variables);
      case 'lengthBetween':
        return _lengthBetween(
          expression,
          value,
          filter.value2?.trim() ?? '',
          variables,
        );
      case 'contains':
      default:
        variables.add(Variable.withString(_containsPattern(value)));
        return "$expression IS NOT NULL AND lower($textExpression) LIKE lower(?) ESCAPE '\\'";
    }
  }
}

class _BuiltSearch {
  final String sql;
  final List<Variable> variables;

  _BuiltSearch(this.sql, this.variables);
}

class _FilterTarget {
  final String valueExpression;
  final String presentExpression;
  final String missingExpression;
  final bool isAnyField;
  final bool storesDateTime;

  const _FilterTarget({
    required this.valueExpression,
    required this.presentExpression,
    required this.missingExpression,
    this.isAnyField = false,
    this.storesDateTime = false,
  });
}

bool _allowsEmptyValue(String operator) {
  return const {
    'isPresent',
    'isMissing',
    'isEmpty',
    'isNotEmpty',
    'isNumeric',
    'isNotNumeric',
    'dateToday',
  }.contains(operator);
}

String? _positiveAnyFieldOperator(String operator) {
  switch (operator) {
    case 'notContains':
      return 'contains';
    case 'notStartsWith':
      return 'startsWith';
    case 'notEndsWith':
      return 'endsWith';
    case 'neq':
      return 'eq';
    case 'notInList':
      return 'inList';
    case 'containsNone':
      return 'containsAny';
    case 'neqCaseSensitive':
      return 'eqCaseSensitive';
    case 'notBetween':
      return 'between';
    case 'isNotNumeric':
      return 'isNumeric';
    case 'dateNotOn':
      return 'dateOn';
    default:
      return null;
  }
}

List<String> _splitTerms(String value) {
  return value
      .split(RegExp(r'\s+'))
      .map((term) => term.trim())
      .where((term) => term.isNotEmpty)
      .toList();
}

List<String> _splitList(String value) {
  return value
      .split(RegExp(r'[,;\n]'))
      .map((term) => term.trim().toLowerCase())
      .where((term) => term.isNotEmpty)
      .toSet()
      .toList();
}

String _numericComparison(
  String expression,
  String value,
  String operator,
  List<Variable> variables,
) {
  final parsed = _parseNumber(value);
  if (parsed == null) return '0 = 1';
  variables.add(Variable.withReal(parsed));
  final numericExpression = _numericSqlExpression(expression);
  return '${_numericSqlGuard(expression)} AND '
      'CAST($numericExpression AS REAL) $operator ?';
}

String _numericBetween(
  String expression,
  String firstValue,
  String secondValue,
  List<Variable> variables, {
  bool negate = false,
}) {
  final first = _parseNumber(firstValue);
  final second = _parseNumber(secondValue);
  if (first == null || second == null) return '0 = 1';
  final min = first < second ? first : second;
  final max = first > second ? first : second;
  variables
    ..add(Variable.withReal(min))
    ..add(Variable.withReal(max));
  final numericExpression = _numericSqlExpression(expression);
  return '${_numericSqlGuard(expression)} AND '
      'CAST($numericExpression AS REAL) ${negate ? 'NOT ' : ''}BETWEEN ? AND ?';
}

String _escapeLike(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}

String _containsPattern(String value) => '%${_escapeLike(value)}%';

String _numericSqlExpression(String expression) {
  return "replace(trim(CAST($expression AS TEXT)), ',', '')";
}

String _numericSqlGuard(String expression) {
  return '$expression IS NOT NULL AND ${_numericTypeSqlGuard(expression)}';
}

String _numericTypeSqlGuard(String expression) {
  final normalized = _numericSqlExpression(expression);
  return 'json_type('
      "CASE WHEN json_valid($normalized) THEN $normalized ELSE 'null' END"
      ") IN ('integer', 'real')";
}

String _lengthComparison(
  String expression,
  String value,
  String operator,
  List<Variable> variables,
) {
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) return '0 = 1';
  variables.add(Variable.withInt(parsed));
  return '$expression IS NOT NULL AND length(CAST($expression AS TEXT)) $operator ?';
}

String _lengthBetween(
  String expression,
  String firstValue,
  String secondValue,
  List<Variable> variables,
) {
  final first = int.tryParse(firstValue);
  final second = int.tryParse(secondValue);
  if (first == null || second == null || first < 0 || second < 0) {
    return '0 = 1';
  }
  final min = first < second ? first : second;
  final max = first > second ? first : second;
  variables
    ..add(Variable.withInt(min))
    ..add(Variable.withInt(max));
  return '$expression IS NOT NULL AND length(CAST($expression AS TEXT)) BETWEEN ? AND ?';
}

String _dateComparison(
  _FilterTarget target,
  String value,
  String operator,
  List<Variable> variables,
) {
  final date = _parseDate(value);
  if (date == null) return '0 = 1';

  if (target.storesDateTime) {
    final boundary = operator == '<'
        ? _startOfDay(date)
        : _startOfDay(date).add(const Duration(days: 1));
    final systemOperator = operator == '<' ? '<' : '>=';
    variables.add(Variable<DateTime>(boundary));
    return '${target.valueExpression} $systemOperator ?';
  }

  variables.add(Variable.withString(_dateOnly(date)));
  return '${target.valueExpression} IS NOT NULL AND '
      "date(CAST(${target.valueExpression} AS TEXT)) $operator date(?)";
}

String _dateOn(_FilterTarget target, String value, List<Variable> variables) {
  final date = _parseDate(value);
  if (date == null) return '0 = 1';

  if (target.storesDateTime) {
    final start = _startOfDay(date);
    final end = start.add(const Duration(days: 1));
    variables
      ..add(Variable<DateTime>(start))
      ..add(Variable<DateTime>(end));
    return '${target.valueExpression} >= ? AND ${target.valueExpression} < ?';
  }

  variables.add(Variable.withString(_dateOnly(date)));
  return '${target.valueExpression} IS NOT NULL AND '
      "date(CAST(${target.valueExpression} AS TEXT)) = date(?)";
}

String _dateNotOn(
  _FilterTarget target,
  String value,
  List<Variable> variables,
) {
  final date = _parseDate(value);
  if (date == null) return '0 = 1';

  if (target.storesDateTime) {
    final start = _startOfDay(date);
    final end = start.add(const Duration(days: 1));
    variables
      ..add(Variable<DateTime>(start))
      ..add(Variable<DateTime>(end));
    return '(${target.valueExpression} < ? OR ${target.valueExpression} >= ?)';
  }

  variables.add(Variable.withString(_dateOnly(date)));
  return '${target.valueExpression} IS NOT NULL AND '
      "date(CAST(${target.valueExpression} AS TEXT)) != date(?)";
}

String _dateInLastDays(
  _FilterTarget target,
  String value,
  List<Variable> variables,
) {
  final days = int.tryParse(value);
  if (days == null || days <= 0 || days > 365000) return '0 = 1';

  final today = _startOfDay(DateTime.now());
  final start = today.subtract(Duration(days: days - 1));
  final end = today.add(const Duration(days: 1));
  if (target.storesDateTime) {
    variables
      ..add(Variable<DateTime>(start))
      ..add(Variable<DateTime>(end));
    return '${target.valueExpression} >= ? AND ${target.valueExpression} < ?';
  }

  variables
    ..add(Variable.withString(_dateOnly(start)))
    ..add(Variable.withString(_dateOnly(today)));
  return '${target.valueExpression} IS NOT NULL AND '
      "date(CAST(${target.valueExpression} AS TEXT)) BETWEEN date(?) AND date(?)";
}

String _dateBetween(
  _FilterTarget target,
  String firstValue,
  String secondValue,
  List<Variable> variables,
) {
  final first = _parseDate(firstValue);
  final second = _parseDate(secondValue);
  if (first == null || second == null) return '0 = 1';
  final min = first.isBefore(second) ? first : second;
  final max = first.isAfter(second) ? first : second;

  if (target.storesDateTime) {
    final start = _startOfDay(min);
    final end = _startOfDay(max).add(const Duration(days: 1));
    variables
      ..add(Variable<DateTime>(start))
      ..add(Variable<DateTime>(end));
    return '${target.valueExpression} >= ? AND ${target.valueExpression} < ?';
  }

  variables
    ..add(Variable.withString(_dateOnly(min)))
    ..add(Variable.withString(_dateOnly(max)));
  return '${target.valueExpression} IS NOT NULL AND '
      "date(CAST(${target.valueExpression} AS TEXT)) BETWEEN date(?) AND date(?)";
}

double? _parseNumber(String value) {
  final parsed = double.tryParse(value.replaceAll(',', '').trim());
  return parsed?.isFinite == true ? parsed : null;
}

DateTime? _parseDate(String value) {
  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return null;
  return _startOfDay(parsed);
}

DateTime _startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

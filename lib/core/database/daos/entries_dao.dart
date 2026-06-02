import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [Entries])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<List<Entry>> getAllEntries() => select(entries).get();
  
  Future<List<Entry>> getEntriesByProfile(int profileId) => 
      (select(entries)..where((t) => t.profileId.equals(profileId))).get();

  Future<Entry> getEntry(int id) => (select(entries)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertEntry(EntriesCompanion entry) => into(entries).insert(entry);

  /// Inserts a large number of entries efficiently using a database transaction.
  Future<void> insertEntriesBulk(List<EntriesCompanion> entriesList) async {
    await batch((batch) {
      batch.insertAll(entries, entriesList);
    });
  }

  Future<bool> updateEntry(Entry entry) => update(entries).replace(entry.copyWith(updatedAt: DateTime.now()));

  Future<int> deleteEntry(int id) => (delete(entries)..where((t) => t.id.equals(id))).go();

  /// Deletes all entries associated with a specific batch ID (useful for rollbacks)
  Future<int> deleteEntriesByBatch(int batchId) {
    return (delete(entries)..where((t) => t.importBatchId.equals(batchId))).go();
  }

  /// Search logic combining FTS5 and regular queries
  Future<List<Entry>> searchEntries({
    required String query,
    required String matchMode, // 'exact', 'contains', 'startsWith', 'fuzzy'
    String sortBy = 'newest',
    int? limit,
    int? offset,
    int? profileId,
  }) async {
    SimpleSelectStatement<$EntriesTable, Entry> baseSelect() {
      final s = select(entries);
      if (profileId != null) {
        s.where((t) => t.profileId.equals(profileId));
      }
      return s;
    }

    void applySorting(SimpleSelectStatement<$EntriesTable, Entry> s) {
      if (sortBy == 'newest') {
        s.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
      } else if (sortBy == 'oldest') {
        s.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]);
      } else if (sortBy == 'alphabetical_asc') {
        s.orderBy([(t) => OrderingTerm(expression: t.searchPayload, mode: OrderingMode.asc)]);
      } else if (sortBy == 'alphabetical_desc') {
        s.orderBy([(t) => OrderingTerm(expression: t.searchPayload, mode: OrderingMode.desc)]);
      }
    }

    if (query.isEmpty) {
      final s = baseSelect();
      applySorting(s);
      if (limit != null) s.limit(limit, offset: offset);
      return s.get();
    }

    if (matchMode == 'exact') {
      final s = baseSelect()..where((t) => t.searchPayload.like('%$query%'));
      applySorting(s);
      if (limit != null) s.limit(limit, offset: offset);
      return s.get();
    } else if (matchMode == 'startsWith' || matchMode == 'contains' || matchMode == 'fuzzy') {
      // Use FTS5 MATCH for startsWith, contains, and fuzzy pre-filter
      String ftsQuery = '''
        SELECT e.* FROM entries e
        INNER JOIN entries_fts fts ON fts.rowid = e.id
        WHERE entries_fts MATCH ?
      ''';
      
      List<Variable> vars = [];
      
      // Escape double quotes to prevent FTS5 syntax errors
      final sanitizedQuery = query.replaceAll('"', '""');
      // startsWith uses prefix-only matching, contains/fuzzy uses phrase + prefix
      final matchTerm = matchMode == 'startsWith'
          ? '"$sanitizedQuery"*'
          : '"$sanitizedQuery"*';
      vars.add(Variable.withString(matchTerm));
      
      if (profileId != null) {
         ftsQuery += ' AND e.profile_id = ?';
         vars.add(Variable.withInt(profileId));
      }

      if (sortBy == 'newest') {
        ftsQuery += ' ORDER BY e.created_at DESC';
      } else if (sortBy == 'oldest') {
        ftsQuery += ' ORDER BY e.created_at ASC';
      } else if (sortBy == 'alphabetical_asc') {
        ftsQuery += ' ORDER BY e.search_payload ASC';
      } else if (sortBy == 'alphabetical_desc') {
        ftsQuery += ' ORDER BY e.search_payload DESC';
      }
      
      if (limit != null) {
         ftsQuery += ' LIMIT ?';
         vars.add(Variable.withInt(limit));
         if (offset != null) {
           ftsQuery += ' OFFSET ?';
           vars.add(Variable.withInt(offset));
         }
      }

      final result = await customSelect(
        ftsQuery,
        variables: vars,
        readsFrom: {entries},
      ).get();

      return result.map((row) => entries.map(row.data)).toList();
    }
    
    return [];
  }

  Future<List<Entry>> getEntriesByDateRange(DateTime? start, DateTime? end) {
    final s = select(entries);
    if (start != null) {
      s.where((t) => t.createdAt.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      s.where((t) => t.createdAt.isSmallerOrEqualValue(end));
    }
    s.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return s.get();
  }

  Future<int> countSearchEntries({
    required String query,
    required String matchMode, // 'exact', 'contains', 'startsWith', 'fuzzy'
    int? profileId,
  }) async {
    if (query.isEmpty) {
      final s = select(entries);
      if (profileId != null) {
        s.where((t) => t.profileId.equals(profileId));
      }
      final result = await s.get();
      return result.length;
    }

    if (matchMode == 'exact') {
      final s = select(entries)..where((t) => t.searchPayload.like('%$query%'));
      if (profileId != null) {
        s.where((t) => t.profileId.equals(profileId));
      }
      final result = await s.get();
      return result.length;
    } else {
      String ftsQuery = '''
        SELECT COUNT(*) as c FROM entries e
        INNER JOIN entries_fts fts ON fts.rowid = e.id
        WHERE entries_fts MATCH ?
      ''';
      
      List<Variable> vars = [];
      final sanitizedQuery = query.replaceAll('"', '""');
      final matchTerm = matchMode == 'startsWith' ? '"$sanitizedQuery"*' : '"$sanitizedQuery"*';
      vars.add(Variable.withString(matchTerm));
      
      if (profileId != null) {
         ftsQuery += ' AND e.profile_id = ?';
         vars.add(Variable.withInt(profileId));
      }

      final result = await customSelect(ftsQuery, variables: vars).getSingle();
      return result.read<int>('c');
    }
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../core/utils/arabic_normalizer.dart';

// Assuming we have a global provider for the database
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider not initialized');
});

class SearchState {
  final String query;
  final String matchMode; // 'exact', 'contains', 'startsWith', 'fuzzy'
  final String sortBy; // 'newest', 'oldest'
  final bool showAll;
  final bool isSearching;
  final List<Entry> results;
  final int offset;
  final bool hasMore;

  SearchState({
    this.query = '',
    this.matchMode = 'contains',
    this.sortBy = 'newest',
    this.showAll = false,
    this.isSearching = false,
    this.results = const [],
    this.offset = 0,
    this.hasMore = true,
  });

  SearchState copyWith({
    String? query,
    String? matchMode,
    String? sortBy,
    bool? showAll,
    bool? isSearching,
    List<Entry>? results,
    int? offset,
    bool? hasMore,
  }) {
    return SearchState(
      query: query ?? this.query,
      matchMode: matchMode ?? this.matchMode,
      sortBy: sortBy ?? this.sortBy,
      showAll: showAll ?? this.showAll,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const int _pageSize = 50;
  Timer? _debounceTimer;

  @override
  SearchState build() {
    // Cancel debounce timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return SearchState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, offset: 0, hasMore: true, results: [], showAll: false);
    // Debounce search to avoid firing on every keystroke
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void setMatchMode(String mode) {
    state = state.copyWith(matchMode: mode, offset: 0, hasMore: true, results: []);
    _performSearch();
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy, offset: 0, hasMore: true, results: []);
    _performSearch();
  }

  void setShowAll(bool showAll) {
    state = state.copyWith(showAll: showAll, query: '', offset: 0, hasMore: true, results: []);
    if (showAll) {
      _performSearch();
    }
  }

  Future<void> loadMore() async {
    if (state.isSearching || !state.hasMore || (state.query.isEmpty && !state.showAll)) return;
    await _performSearch();
  }

  Future<void> _performSearch() async {
    if (state.query.isEmpty && !state.showAll) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    // Capture the query at search start to detect stale results
    final searchQuery = state.query;
    state = state.copyWith(isSearching: true);
    
    final db = ref.read(databaseProvider);
    final normalizedQuery = arabicNormalize(searchQuery);

    try {
      var newResults = await db.entriesDao.searchEntries(
        query: normalizedQuery,
        matchMode: state.matchMode,
        sortBy: state.sortBy,
        limit: _pageSize,
        offset: state.offset,
      );

      // Check if query changed while we were searching (discard stale results)
      if (state.query != searchQuery) return;

      // Track the raw DB result count for pagination (before fuzzy filtering)
      final rawResultCount = newResults.length;

      // Apply Levenshtein fuzzy ranking post-filter if mode is 'fuzzy'
      if (state.matchMode == 'fuzzy' && newResults.isNotEmpty) {
        newResults = fuzzyFilterAndSort<Entry>(
          newResults,
          normalizedQuery,
          (entry) => entry.searchPayload,
        );
      }

      state = state.copyWith(
        results: [...state.results, ...newResults],
        isSearching: false,
        // Use raw count for pagination: if DB returned a full page, there may be more
        hasMore: rawResultCount == _pageSize,
        offset: state.offset + _pageSize,
      );
    } catch (e) {
      // Only update if query hasn't changed
      if (state.query == searchQuery) {
        state = state.copyWith(results: state.results, isSearching: false);
      }
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

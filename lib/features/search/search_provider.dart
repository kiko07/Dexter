import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/search_criteria.dart';
import '../../core/utils/arabic_normalizer.dart';
import '../../core/utils/fuzzy_search.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider not initialized');
});

class AdvancedFilter extends EntrySearchFilter {
  const AdvancedFilter({
    required super.fieldName,
    required super.operator,
    required super.value,
    super.value2,
  });
}

class SearchState {
  final String query;
  final String matchMode;
  final String sortBy;
  final bool showAll;
  final bool isSearching;
  final List<Entry> results;
  final int offset;
  final bool hasMore;
  final int totalCount;
  final List<AdvancedFilter> advancedFilters;
  final List<String> availableSourceFiles;
  final Set<String> selectedSourceFiles;
  final bool manualOnly;

  const SearchState({
    this.query = '',
    this.matchMode = 'contains',
    this.sortBy = 'newest',
    this.showAll = false,
    this.isSearching = false,
    this.results = const [],
    this.offset = 0,
    this.hasMore = true,
    this.totalCount = 0,
    this.advancedFilters = const [],
    this.availableSourceFiles = const [],
    this.selectedSourceFiles = const {},
    this.manualOnly = false,
  });

  bool get hasSearchCriteria =>
      query.isNotEmpty ||
      showAll ||
      advancedFilters.isNotEmpty ||
      selectedSourceFiles.isNotEmpty ||
      manualOnly;

  SearchState copyWith({
    String? query,
    String? matchMode,
    String? sortBy,
    bool? showAll,
    bool? isSearching,
    List<Entry>? results,
    int? offset,
    bool? hasMore,
    int? totalCount,
    List<AdvancedFilter>? advancedFilters,
    List<String>? availableSourceFiles,
    Set<String>? selectedSourceFiles,
    bool? manualOnly,
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
      totalCount: totalCount ?? this.totalCount,
      advancedFilters: advancedFilters ?? this.advancedFilters,
      availableSourceFiles: availableSourceFiles ?? this.availableSourceFiles,
      selectedSourceFiles: selectedSourceFiles ?? this.selectedSourceFiles,
      manualOnly: manualOnly ?? this.manualOnly,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const int _pageSize = 50;
  Timer? _debounceTimer;
  int _searchGeneration = 0;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    Future.microtask(() => loadAvailableSourceFiles());
    return const SearchState();
  }

  Future<void> loadAvailableSourceFiles() async {
    final db = ref.read(databaseProvider);
    try {
      final files = await db.entriesDao.getDistinctSourceFiles();
      state = state.copyWith(availableSourceFiles: files);
    } catch (_) {}
  }

  void setQuery(String query) {
    state = state.copyWith(
      query: query,
      offset: 0,
      hasMore: true,
      results: [],
      showAll: false,
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _performSearch);
  }

  void setMatchMode(String mode) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      matchMode: mode,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void setSortBy(String sortBy) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      sortBy: sortBy,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void setShowAll(bool showAll) {
    state = state.copyWith(
      showAll: showAll,
      query: '',
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void addFilter(AdvancedFilter filter) {
    state = state.copyWith(
      advancedFilters: [...state.advancedFilters, filter],
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void removeFilter(int index) {
    final updated = List<AdvancedFilter>.from(state.advancedFilters);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
    }
    state = state.copyWith(
      advancedFilters: updated,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void clearFilters() {
    state = state.copyWith(
      advancedFilters: const [],
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void toggleSourceFile(String fileName) {
    final current = Set<String>.from(state.selectedSourceFiles);
    if (current.contains(fileName)) {
      current.remove(fileName);
    } else {
      current.add(fileName);
    }
    state = state.copyWith(
      selectedSourceFiles: current,
      manualOnly: false,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void selectAllFiles() {
    state = state.copyWith(
      selectedSourceFiles: state.availableSourceFiles.toSet(),
      manualOnly: false,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void clearFileSelection() {
    state = state.copyWith(
      selectedSourceFiles: const {},
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  void setManualOnly(bool value) {
    state = state.copyWith(
      manualOnly: value,
      selectedSourceFiles: value ? const {} : state.selectedSourceFiles,
      offset: 0,
      hasMore: true,
      results: [],
    );
    _performSearch();
  }

  Future<void> loadMore() async {
    if (state.isSearching || !state.hasMore || !state.hasSearchCriteria) {
      return;
    }
    await _performSearch();
  }

  Future<void> _performSearch() async {
    if (!state.hasSearchCriteria) {
      _searchGeneration++;
      state = state.copyWith(
        results: [],
        isSearching: false,
        hasMore: false,
        offset: 0,
        totalCount: 0,
      );
      return;
    }

    final generation = ++_searchGeneration;
    final searchQuery = state.query;
    final normalizedQuery = arabicNormalize(searchQuery);
    final searchOffset = state.offset;
    final filters = List<AdvancedFilter>.from(state.advancedFilters);
    final selectedFiles = Set<String>.from(state.selectedSourceFiles);
    final manualOnly = state.manualOnly;
    final matchMode = state.matchMode;
    final sortBy = state.sortBy;

    state = state.copyWith(isSearching: true);

    final db = ref.read(databaseProvider);
    final sourceFilesFilter = selectedFiles.isEmpty
        ? null
        : selectedFiles.toList();

    try {
      int newTotalCount;
      List<Entry> newResults;
      bool hasMore;

      if (matchMode == 'fuzzy' && normalizedQuery.isNotEmpty) {
        final candidates = await db.entriesDao.searchEntries(
          query: normalizedQuery,
          matchMode: matchMode,
          sortBy: sortBy,
          sourceFiles: sourceFilesFilter,
          manualOnly: manualOnly,
          filters: filters,
        );
        final filtered = fuzzyFilterAndSort<Entry>(
          candidates,
          normalizedQuery,
          (entry) => entry.searchPayload,
        );
        newTotalCount = filtered.length;
        newResults = filtered.skip(searchOffset).take(_pageSize).toList();
        hasMore = searchOffset + newResults.length < filtered.length;
      } else {
        newTotalCount = searchOffset == 0
            ? await db.entriesDao.countSearchEntries(
                query: normalizedQuery,
                matchMode: matchMode,
                sourceFiles: sourceFilesFilter,
                manualOnly: manualOnly,
                filters: filters,
              )
            : state.totalCount;
        newResults = await db.entriesDao.searchEntries(
          query: normalizedQuery,
          matchMode: matchMode,
          sortBy: sortBy,
          limit: _pageSize,
          offset: searchOffset,
          sourceFiles: sourceFilesFilter,
          manualOnly: manualOnly,
          filters: filters,
        );
        hasMore = searchOffset + newResults.length < newTotalCount;
      }

      if (generation != _searchGeneration) return;

      state = state.copyWith(
        results: searchOffset == 0
            ? newResults
            : [...state.results, ...newResults],
        isSearching: false,
        hasMore: hasMore,
        offset: searchOffset + newResults.length,
        totalCount: newTotalCount,
      );
    } catch (_) {
      if (generation == _searchGeneration) {
        state = state.copyWith(results: state.results, isSearching: false);
      }
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

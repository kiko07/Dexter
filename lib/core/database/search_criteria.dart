class EntrySearchFilter {
  final String fieldName;
  final String operator;
  final String value;
  final String? value2;

  const EntrySearchFilter({
    required this.fieldName,
    required this.operator,
    required this.value,
    this.value2,
  });
}

class EntrySearchCriteria {
  final String query;
  final String matchMode;
  final String sortBy;
  final int? limit;
  final int? offset;
  final int? profileId;
  final List<String>? sourceFiles;
  final bool manualOnly;
  final List<EntrySearchFilter> filters;

  const EntrySearchCriteria({
    required this.query,
    required this.matchMode,
    this.sortBy = 'newest',
    this.limit,
    this.offset,
    this.profileId,
    this.sourceFiles,
    this.manualOnly = false,
    this.filters = const [],
  });
}

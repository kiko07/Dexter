import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_screen.dart';
import 'search_provider.dart';
import 'result_card.dart';
import '../../core/widgets/about_dialog_helper.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody(SearchState state, ThemeData theme) {
    if (state.isSearching && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasSearchCriteria) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.pleaseEnterDataToSearch,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noResults,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      itemCount: state.results.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.results.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ResultCard(entry: state.results[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.searchTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline),
                          color: theme.colorScheme.primary,
                          onPressed: () => showAppAboutDialog(context),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          color: theme.colorScheme.primary,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchForRecord,
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                  ),
                  onChanged: (val) => notifier.setQuery(val),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _matchModeOptions.map((option) {
                    final selected = state.matchMode == option.value;
                    final color = selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.65);
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: ChoiceChip(
                        selected: selected,
                        avatar: Icon(option.icon, size: 16, color: color),
                        label: Text(_matchModeLabel(l10n, option.value)),
                        onSelected: (_) => notifier.setMatchMode(option.value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Advanced Filters & File Scope Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  // File Scope Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () =>
                          _showFileScopeBottomSheet(context, state, notifier),
                      icon: const Icon(Icons.file_copy_rounded, size: 18),
                      label: Text(
                        state.selectedSourceFiles.isEmpty
                            ? AppLocalizations.of(context)!.allFiles
                            : AppLocalizations.of(context)!.selectedFiles(
                                state.selectedSourceFiles.length,
                              ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Advanced Filters Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showAdvancedFiltersBottomSheet(
                        context,
                        ref,
                        state,
                        notifier,
                      ),
                      icon: Badge(
                        isLabelVisible: state.advancedFilters.isNotEmpty,
                        label: Text(state.advancedFilters.length.toString()),
                        child: const Icon(Icons.filter_alt_rounded, size: 18),
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.advancedFilters,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Advanced Filters active chips
            if (state.advancedFilters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...List.generate(state.advancedFilters.length, (index) {
                      final filter = state.advancedFilters[index];
                      return InputChip(
                        label: Text(
                          _formatFilterSummary(context, filter),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => notifier.removeFilter(index),
                        deleteIconColor: theme.colorScheme.error,
                      );
                    }),
                    ActionChip(
                      label: Text(
                        l10n.clear,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => notifier.clearFilters(),
                      avatar: const Icon(Icons.clear_all_rounded, size: 16),
                    ),
                  ],
                ),
              ),

            // Display Toggle and Sorting Options
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => notifier.setShowAll(!state.showAll),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        backgroundColor: state.showAll
                            ? theme.colorScheme.error.withValues(alpha: 0.1)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.showAll
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                            color: state.showAll
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              state.showAll ? l10n.hideData : l10n.showAllData,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: state.showAll
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PopupMenuButton<String>(
                      onSelected: (String result) {
                        notifier.setSortBy(result);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'newest',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: state.sortBy == 'newest'
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.sortNewest,
                                    style: TextStyle(
                                      fontWeight: state.sortBy == 'newest'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'oldest',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: state.sortBy == 'oldest'
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.sortOldest,
                                    style: TextStyle(
                                      fontWeight: state.sortBy == 'oldest'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'alphabetical_asc',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: state.sortBy == 'alphabetical_asc'
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.sortAlphabeticalAsc,
                                    style: TextStyle(
                                      fontWeight:
                                          state.sortBy == 'alphabetical_asc'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'alphabetical_desc',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: state.sortBy == 'alphabetical_desc'
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.sortAlphabeticalDesc,
                                    style: TextStyle(
                                      fontWeight:
                                          state.sortBy == 'alphabetical_desc'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sort,
                              size: 20,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.filtersAndSorting,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results Count
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.totalRecords}: ${state.results.length} / ${state.totalCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Results List
            Expanded(child: _buildBody(state, theme)),
          ],
        ),
      ),
    );
  }

  String _formatFilterSummary(BuildContext context, AdvancedFilter filter) {
    final l10n = AppLocalizations.of(context)!;
    final fieldLabel = _fieldLabel(l10n, filter.fieldName);
    final operator = _operatorByValue(filter.operator);
    final chipLabel = _operatorChipLabel(l10n, filter.operator);

    if (!operator.requiresValue) {
      return '$fieldLabel $chipLabel';
    }

    if (operator.requiresSecondValue) {
      return '$fieldLabel $chipLabel ${filter.value} - ${filter.value2 ?? ''}';
    }

    return '$fieldLabel $chipLabel ${filter.value}';
  }

  String _fieldLabel(AppLocalizations l10n, String fieldName) {
    return _systemFieldLabel(l10n, fieldName) ?? fieldName;
  }

  void _showFileScopeBottomSheet(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final s = ref.watch(searchProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.fileScope,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => notifier.selectAllFiles(),
                              child: Text(
                                AppLocalizations.of(context)!.selectAll,
                              ),
                            ),
                            TextButton(
                              onPressed: () => notifier.clearFileSelection(),
                              child: Text(AppLocalizations.of(context)!.clear),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.manualEntriesOnly,
                      ),
                      value: s.manualOnly,
                      onChanged: (value) =>
                          notifier.setManualOnly(value ?? false),
                      activeColor: theme.colorScheme.primary,
                    ),
                    if (s.availableSourceFiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.noIndexedSourceFilesFound,
                          ),
                        ),
                      )
                    else
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: s.availableSourceFiles.length,
                          itemBuilder: (context, idx) {
                            final fileName = s.availableSourceFiles[idx];
                            final isSelected = s.selectedSourceFiles.contains(
                              fileName,
                            );
                            return CheckboxListTile(
                              title: Text(fileName),
                              value: isSelected,
                              onChanged: (_) =>
                                  notifier.toggleSourceFile(fileName),
                              activeColor: theme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAdvancedFiltersBottomSheet(
    BuildContext context,
    WidgetRef ref,
    SearchState state,
    SearchNotifier notifier,
  ) {
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: db.entriesDao.getAvailableFieldNames(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final fields = snapshot.data!;
            return _AdvancedFilterSheetBody(
              fields: fields,
              onAddFilter: (filter) {
                notifier.addFilter(filter);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class _AdvancedFilterSheetBody extends StatefulWidget {
  final List<String> fields;
  final ValueChanged<AdvancedFilter> onAddFilter;

  const _AdvancedFilterSheetBody({
    required this.fields,
    required this.onAddFilter,
  });

  @override
  State<_AdvancedFilterSheetBody> createState() =>
      _AdvancedFilterSheetBodyState();
}

class _AdvancedFilterSheetBodyState extends State<_AdvancedFilterSheetBody> {
  String _selectedField = '__any__';
  String _selectedOperator = 'contains';
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _value2Controller = TextEditingController();
  String? _validationError;

  _FilterOperatorOption get _selectedOperatorOption =>
      _operatorByValue(_selectedOperator);

  List<_FieldOption> get _fieldOptions => [
    ..._systemFieldOptions,
    ...widget.fields.map((field) => _FieldOption(field, field)),
  ];

  @override
  void dispose() {
    _valueController.dispose();
    _value2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate =
        DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _dateInput(picked);
    }
  }

  TextInputType _keyboardTypeFor(_FilterOperatorOption operator) {
    switch (operator.inputKind) {
      case _FilterInputKind.number:
        return const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        );
      case _FilterInputKind.integer:
        return TextInputType.number;
      case _FilterInputKind.date:
      case _FilterInputKind.text:
        return TextInputType.text;
    }
  }

  Widget _buildValueField(
    TextEditingController controller,
    String label, {
    String? helperText,
  }) {
    final operator = _selectedOperatorOption;
    final isDate = operator.inputKind == _FilterInputKind.date;

    return TextField(
      controller: controller,
      keyboardType: _keyboardTypeFor(operator),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixIcon: isDate
            ? IconButton(
                tooltip: AppLocalizations.of(context)!.pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: () => _pickDate(controller),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addFilter() {
    final operator = _selectedOperatorOption;
    final value = _valueController.text.trim();
    final value2 = _value2Controller.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (operator.requiresValue &&
        (value.isEmpty || (operator.requiresSecondValue && value2.isEmpty))) {
      setState(() => _validationError = l10n.fieldRequired);
      return;
    }
    if (operator.requiresValue &&
        (!_isValidFilterValue(operator, value) ||
            (operator.requiresSecondValue &&
                !_isValidFilterValue(operator, value2)))) {
      setState(() => _validationError = l10n.invalidFilterValue);
      return;
    }

    widget.onAddFilter(
      AdvancedFilter(
        fieldName: _selectedField,
        operator: _selectedOperator,
        value: operator.requiresValue ? value : '',
        value2: operator.requiresSecondValue ? value2 : null,
      ),
    );
  }

  bool _isValidFilterValue(_FilterOperatorOption operator, String value) {
    switch (operator.inputKind) {
      case _FilterInputKind.text:
        return true;
      case _FilterInputKind.number:
        final parsed = double.tryParse(value.replaceAll(',', '').trim());
        return parsed?.isFinite == true;
      case _FilterInputKind.integer:
        final parsed = int.tryParse(value);
        if (parsed == null) return false;
        return operator.value == 'dateInLastDays' ? parsed > 0 : parsed >= 0;
      case _FilterInputKind.date:
        return DateTime.tryParse(value) != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final operator = _selectedOperatorOption;
    final fieldOptions = _fieldOptions;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.addFilter,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Field Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.field,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: fieldOptions
                  .map(
                    (field) => DropdownMenuItem(
                      value: field.value,
                      child: Text(
                        _systemFieldLabel(l10n, field.value) ?? field.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedField = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Operator Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedOperator,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.operator,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _filterOperatorOptions
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.value,
                      child: Text(
                        _operatorLabel(l10n, item.value),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedOperator = val;
                    _value2Controller.clear();
                    _validationError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Comparison Value input(s)
            if (operator.requiresValue)
              if (operator.requiresSecondValue)
                Row(
                  children: [
                    Expanded(
                      child: _buildValueField(
                        _valueController,
                        _operatorValueLabel(l10n, operator.value),
                        helperText: _operatorHelperText(l10n, operator.value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildValueField(
                        _value2Controller,
                        _operatorSecondValueLabel(l10n, operator.value),
                      ),
                    ),
                  ],
                )
              else
                _buildValueField(
                  _valueController,
                  _operatorValueLabel(l10n, operator.value),
                  helperText: _operatorHelperText(l10n, operator.value),
                ),
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _addFilter,
              child: Text(AppLocalizations.of(context)!.addFilter),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldOption {
  final String value;
  final String label;

  const _FieldOption(this.value, this.label);
}

class _MatchModeOption {
  final String value;
  final IconData icon;

  const _MatchModeOption({required this.value, required this.icon});
}

enum _FilterInputKind { text, number, integer, date }

class _FilterOperatorOption {
  final String value;
  final bool requiresValue;
  final bool requiresSecondValue;
  final _FilterInputKind inputKind;

  const _FilterOperatorOption({
    required this.value,
    this.requiresValue = true,
    this.requiresSecondValue = false,
    this.inputKind = _FilterInputKind.text,
  });
}

const _matchModeOptions = [
  _MatchModeOption(value: 'contains', icon: Icons.manage_search_rounded),
  _MatchModeOption(value: 'exact', icon: Icons.center_focus_strong_rounded),
  _MatchModeOption(
    value: 'startsWith',
    icon: Icons.keyboard_double_arrow_right_rounded,
  ),
  _MatchModeOption(value: 'fuzzy', icon: Icons.blur_on_rounded),
];

const _systemFieldOptions = [
  _FieldOption('__any__', '__any__'),
  _FieldOption('__id__', '__id__'),
  _FieldOption('__profileId__', '__profileId__'),
  _FieldOption('__sourceFile__', '__sourceFile__'),
  _FieldOption('__importBatchId__', '__importBatchId__'),
  _FieldOption('__createdAt__', '__createdAt__'),
  _FieldOption('__updatedAt__', '__updatedAt__'),
];

const _filterOperatorOptions = [
  _FilterOperatorOption(value: 'contains'),
  _FilterOperatorOption(value: 'notContains'),
  _FilterOperatorOption(value: 'startsWith'),
  _FilterOperatorOption(value: 'notStartsWith'),
  _FilterOperatorOption(value: 'endsWith'),
  _FilterOperatorOption(value: 'notEndsWith'),
  _FilterOperatorOption(value: 'containsAll'),
  _FilterOperatorOption(value: 'containsAny'),
  _FilterOperatorOption(value: 'containsNone'),
  _FilterOperatorOption(value: 'containsCaseSensitive'),
  _FilterOperatorOption(value: 'eq'),
  _FilterOperatorOption(value: 'neq'),
  _FilterOperatorOption(value: 'eqCaseSensitive'),
  _FilterOperatorOption(value: 'neqCaseSensitive'),
  _FilterOperatorOption(value: 'inList'),
  _FilterOperatorOption(value: 'notInList'),
  _FilterOperatorOption(value: 'gt', inputKind: _FilterInputKind.number),
  _FilterOperatorOption(value: 'lt', inputKind: _FilterInputKind.number),
  _FilterOperatorOption(value: 'gte', inputKind: _FilterInputKind.number),
  _FilterOperatorOption(value: 'lte', inputKind: _FilterInputKind.number),
  _FilterOperatorOption(
    value: 'between',
    requiresSecondValue: true,
    inputKind: _FilterInputKind.number,
  ),
  _FilterOperatorOption(
    value: 'notBetween',
    requiresSecondValue: true,
    inputKind: _FilterInputKind.number,
  ),
  _FilterOperatorOption(value: 'isNumeric', requiresValue: false),
  _FilterOperatorOption(value: 'isNotNumeric', requiresValue: false),
  _FilterOperatorOption(value: 'dateBefore', inputKind: _FilterInputKind.date),
  _FilterOperatorOption(value: 'dateAfter', inputKind: _FilterInputKind.date),
  _FilterOperatorOption(value: 'dateOn', inputKind: _FilterInputKind.date),
  _FilterOperatorOption(value: 'dateNotOn', inputKind: _FilterInputKind.date),
  _FilterOperatorOption(
    value: 'dateBetween',
    requiresSecondValue: true,
    inputKind: _FilterInputKind.date,
  ),
  _FilterOperatorOption(
    value: 'dateToday',
    requiresValue: false,
    inputKind: _FilterInputKind.date,
  ),
  _FilterOperatorOption(
    value: 'dateInLastDays',
    inputKind: _FilterInputKind.integer,
  ),
  _FilterOperatorOption(value: 'lengthEq', inputKind: _FilterInputKind.integer),
  _FilterOperatorOption(value: 'lengthGt', inputKind: _FilterInputKind.integer),
  _FilterOperatorOption(value: 'lengthLt', inputKind: _FilterInputKind.integer),
  _FilterOperatorOption(
    value: 'lengthBetween',
    requiresSecondValue: true,
    inputKind: _FilterInputKind.integer,
  ),
  _FilterOperatorOption(value: 'isPresent', requiresValue: false),
  _FilterOperatorOption(value: 'isMissing', requiresValue: false),
  _FilterOperatorOption(value: 'isEmpty', requiresValue: false),
  _FilterOperatorOption(value: 'isNotEmpty', requiresValue: false),
];

String _matchModeLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'contains' => l10n.matchContains,
    'exact' => l10n.matchExact,
    'startsWith' => l10n.matchStartsWith,
    'fuzzy' => l10n.matchFuzzy,
    _ => value,
  };
}

String? _systemFieldLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    '__any__' => l10n.anyField,
    '__id__' => l10n.recordId,
    '__profileId__' => l10n.profileId,
    '__sourceFile__' => l10n.sourceFile,
    '__importBatchId__' => l10n.importBatch,
    '__createdAt__' => l10n.createdAt,
    '__updatedAt__' => l10n.updatedAt,
    _ => null,
  };
}

String _operatorLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'contains' => l10n.contains,
    'notContains' => l10n.doesNotContain,
    'startsWith' => l10n.startsWith,
    'notStartsWith' => l10n.doesNotStartWith,
    'endsWith' => l10n.endsWith,
    'notEndsWith' => l10n.doesNotEndWith,
    'containsAll' => l10n.containsAllWords,
    'containsAny' => l10n.containsAnyWord,
    'containsNone' => l10n.containsNoWords,
    'containsCaseSensitive' => l10n.containsCaseSensitive,
    'eq' => l10n.equalTo,
    'neq' => l10n.notEqualTo,
    'eqCaseSensitive' => l10n.equalCaseSensitive,
    'neqCaseSensitive' => l10n.notEqualCaseSensitive,
    'inList' => l10n.inList,
    'notInList' => l10n.notInList,
    'gt' => l10n.greaterThan,
    'lt' => l10n.lessThan,
    'gte' => l10n.greaterThanOrEqual,
    'lte' => l10n.lessThanOrEqual,
    'between' => l10n.betweenLabel,
    'notBetween' => l10n.notBetween,
    'isNumeric' => l10n.isNumeric,
    'isNotNumeric' => l10n.isNotNumeric,
    'dateBefore' => l10n.dateBefore,
    'dateAfter' => l10n.dateAfter,
    'dateOn' => l10n.dateIs,
    'dateNotOn' => l10n.dateIsNot,
    'dateBetween' => l10n.dateBetween,
    'dateToday' => l10n.dateToday,
    'dateInLastDays' => l10n.dateInLastDays,
    'lengthEq' => l10n.lengthEqual,
    'lengthGt' => l10n.lengthGreaterThan,
    'lengthLt' => l10n.lengthLessThan,
    'lengthBetween' => l10n.lengthBetween,
    'isPresent' => l10n.fieldExists,
    'isMissing' => l10n.fieldMissing,
    'isEmpty' => l10n.isEmpty,
    'isNotEmpty' => l10n.isNotEmpty,
    _ => value,
  };
}

String _operatorChipLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'eq' => '=',
    'neq' => '≠',
    'eqCaseSensitive' => '= Aa',
    'neqCaseSensitive' => '≠ Aa',
    'gt' => '>',
    'lt' => '<',
    'gte' => '≥',
    'lte' => '≤',
    'lengthEq' => '${l10n.characters} =',
    'lengthGt' => '${l10n.characters} >',
    'lengthLt' => '${l10n.characters} <',
    _ => _operatorLabel(l10n, value),
  };
}

String _operatorValueLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'between' || 'notBetween' => l10n.minValue,
    'dateBefore' || 'dateAfter' || 'dateOn' || 'dateNotOn' => l10n.dateLabel,
    'dateBetween' => l10n.startDate,
    'dateInLastDays' => l10n.days,
    'lengthEq' || 'lengthGt' || 'lengthLt' => l10n.characters,
    'lengthBetween' => l10n.minCharacters,
    _ => l10n.valueLabel,
  };
}

String _operatorSecondValueLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'dateBetween' => l10n.endDate,
    'lengthBetween' => l10n.maxCharacters,
    _ => l10n.maxValue,
  };
}

String? _operatorHelperText(AppLocalizations l10n, String value) {
  return switch (value) {
    'containsAll' ||
    'containsAny' ||
    'containsNone' => l10n.separateWordsWithSpaces,
    'inList' || 'notInList' => l10n.listValueHint,
    'dateBefore' ||
    'dateAfter' ||
    'dateOn' ||
    'dateNotOn' ||
    'dateBetween' => l10n.dateFormatHint,
    _ => null,
  };
}

_FilterOperatorOption _operatorByValue(String value) {
  return _filterOperatorOptions.firstWhere(
    (operator) => operator.value == value,
    orElse: () => _FilterOperatorOption(value: value),
  );
}

String _dateInput(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

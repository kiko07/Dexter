import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_screen.dart';
import 'search_provider.dart';
import 'result_card.dart';

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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.designedBy, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.ahmedElKilany, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.phone_android, color: Colors.green),
                  SizedBox(width: 8),
                  Text('WhatsApp: 01015331775', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          )
        ],
      ),
    );
  }



  Widget _buildBody(SearchState state, ThemeData theme) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.query.isEmpty && !state.showAll) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.pleaseEnterDataToSearch, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }
    
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: theme.colorScheme.error.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noResults, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100, top: 8), // Extra padding for the floating nav bar
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.searchTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline),
                          color: theme.colorScheme.primary,
                          onPressed: () => _showAboutDialog(context),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          color: theme.colorScheme.primary,
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  ),
                  onChanged: (val) => notifier.setQuery(val),
                ),
              ),
            ),
            
            // Sorting Options
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      notifier.setSortBy(result);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'newest',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: state.sortBy == 'newest' ? theme.colorScheme.primary : Colors.transparent),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.sortNewest, style: TextStyle(fontWeight: state.sortBy == 'newest' ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'oldest',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: state.sortBy == 'oldest' ? theme.colorScheme.primary : Colors.transparent),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.sortOldest, style: TextStyle(fontWeight: state.sortBy == 'oldest' ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'alphabetical_asc',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: state.sortBy == 'alphabetical_asc' ? theme.colorScheme.primary : Colors.transparent),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.sortAlphabeticalAsc, style: TextStyle(fontWeight: state.sortBy == 'alphabetical_asc' ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'alphabetical_desc',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: state.sortBy == 'alphabetical_desc' ? theme.colorScheme.primary : Colors.transparent),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.sortAlphabeticalDesc, style: TextStyle(fontWeight: state.sortBy == 'alphabetical_desc' ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 20, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.filtersAndSorting, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results Count & Show All
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppLocalizations.of(context)!.totalRecords}: ${state.results.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  TextButton.icon(
                    onPressed: () => notifier.setShowAll(true),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: Text(AppLocalizations.of(context)!.showAllData),
                  ),
                ],
              ),
            ),
            
            // Results List
            Expanded(
              child: _buildBody(state, theme),
            ),
          ],
        ),
      ),
    );
  }
}

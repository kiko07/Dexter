import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_screen.dart';
import '../entries/manual_entry_screen.dart';
import '../import/background_scanner_service.dart';
import '../search/search_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    SearchScreen(key: PageStorageKey('search')),
    ManualEntryScreen(key: PageStorageKey('manual-entry')),
    DataScreen(key: PageStorageKey('data')),
    StatisticsScreen(key: PageStorageKey('statistics')),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(backgroundScannerProvider.notifier).scanNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.edit_note_rounded),
            selectedIcon: const Icon(Icons.edit_note),
            label: l10n.manualEntry,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_rounded),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.data,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_rounded),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
        ],
      ),
    );
  }
}

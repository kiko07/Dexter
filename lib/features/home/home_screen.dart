import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/about_dialog_helper.dart';
import '../data/data_screen.dart';
import '../entries/manual_entry_screen.dart';
import '../import/background_scanner_service.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final showRail = width >= 760;
    final extendRail = width >= 1180;
    final destinations = [
      _WorkspaceDestination(
        label: l10n.search,
        icon: Icons.search_rounded,
        selectedIcon: Icons.search,
      ),
      _WorkspaceDestination(
        label: l10n.manualEntry,
        icon: Icons.edit_note_rounded,
        selectedIcon: Icons.edit_note,
      ),
      _WorkspaceDestination(
        label: l10n.data,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder_rounded,
      ),
      _WorkspaceDestination(
        label: l10n.statistics,
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (showRail)
              _WorkspaceRail(
                destinations: destinations,
                selectedIndex: _currentIndex,
                extended: extendRail,
                onSelected: _selectDestination,
              ),
            Expanded(
              child: Column(
                children: [
                  _WorkspaceHeader(
                    title: destinations[_currentIndex].label,
                    showBrand: !showRail,
                    onShowAbout: () => showAppAboutDialog(context),
                    onOpenSettings: () => _openSettings(context),
                  ),
                  Expanded(
                    child: FocusTraversalGroup(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showRail
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _selectDestination,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }

  void _selectDestination(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}

class _WorkspaceDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _WorkspaceDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _WorkspaceRail extends StatelessWidget {
  final List<_WorkspaceDestination> destinations;
  final int selectedIndex;
  final bool extended;
  final ValueChanged<int> onSelected;

  const _WorkspaceRail({
    required this.destinations,
    required this.selectedIndex,
    required this.extended,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: BorderDirectional(
          end: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        extended: extended,
        minWidth: 80,
        minExtendedWidth: 232,
        groupAlignment: -0.74,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
          child: _DexterBrand(showLabel: extended),
        ),
        destinations: [
          for (final destination in destinations)
            NavigationRailDestination(
              padding: const EdgeInsets.symmetric(vertical: 4),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final String title;
  final bool showBrand;
  final VoidCallback onShowAbout;
  final VoidCallback onOpenSettings;

  const _WorkspaceHeader({
    required this.title,
    required this.showBrand,
    required this.onShowAbout,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(showBrand ? 16 : 28, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (showBrand) ...[
            const _DexterBrand(showLabel: false),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 28,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: 'Dexter',
            onPressed: onShowAbout,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _DexterBrand extends StatelessWidget {
  final bool showLabel;

  const _DexterBrand({required this.showLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mark = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.manage_search_rounded,
        color: theme.colorScheme.onPrimary,
      ),
    );

    if (!showLabel) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text('Dexter', style: theme.textTheme.titleLarge),
      ],
    );
  }
}

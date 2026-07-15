import 'dart:convert';
import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'duplicate_scanner_provider.dart';

class DuplicateScanScreen extends ConsumerStatefulWidget {
  const DuplicateScanScreen({super.key});

  @override
  ConsumerState<DuplicateScanScreen> createState() =>
      _DuplicateScanScreenState();
}

class _DuplicateScanScreenState extends ConsumerState<DuplicateScanScreen> {
  @override
  void initState() {
    super.initState();
    // Start scan on entry
    Future.microtask(() {
      ref.read(duplicateScannerProvider.notifier).scanForDuplicates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duplicateScannerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.scanForDuplicates,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(duplicateScannerProvider.notifier).scanForDuplicates();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isScanning)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.scanningDuplicateEntries,
                      ),
                    ],
                  ),
                ),
              )
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.errorOccurred(state.error!),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.duplicateGroups.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noDuplicatesFound,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.find_in_page_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.duplicatesFound(state.duplicateGroups.length),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.totalRedundantEntries(state.totalDuplicates),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Duplicate Groups List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: state.duplicateGroups.length,
                  itemBuilder: (context, index) {
                    final group = state.duplicateGroups[index];
                    return _DuplicateGroupCard(group: group);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DuplicateGroupCard extends ConsumerWidget {
  final DuplicateGroup group;

  const _DuplicateGroupCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Key Info and Keep First Quick Action
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.fieldName == '__payload__' ? AppLocalizations.of(context)!.payload : group.fieldName}: ${group.dedupKey}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.copiesCount(group.entries.length),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(duplicateScannerProvider.notifier)
                        .keepOneDeleteRest(group);
                  },
                  icon: const Icon(Icons.auto_delete_rounded, size: 18),
                  label: Text(AppLocalizations.of(context)!.keepFirst),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Entries List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = group.entries[index];
              return _DuplicateEntryTile(
                entry: entry,
                index: index,
                onDelete: () {
                  ref
                      .read(duplicateScannerProvider.notifier)
                      .deleteEntry(entry.id);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DuplicateEntryTile extends StatelessWidget {
  final dynamic entry; // Entry type from db
  final int index;
  final VoidCallback onDelete;

  const _DuplicateEntryTile({
    required this.entry,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Map<String, dynamic> data = {};
    try {
      data = (jsonDecode(entry.data) as Map).cast<String, dynamic>();
    } catch (_) {}

    final displayData = Map<String, dynamic>.from(data);
    final sheetName = displayData.remove('_sheetName');
    final detailString = displayData.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: index == 0
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              index == 0
                  ? AppLocalizations.of(context)!.keepBadge
                  : AppLocalizations.of(context)!.duplicateBadge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: index == 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.recordNumber(entry.id as int),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.sourceFile}: ${entry.sourceFile ?? ''}${sheetName != null ? ' ($sheetName)' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              detailString,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.error,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(AppLocalizations.of(context)!.confirmDelete),
              content: Text(
                AppLocalizations.of(context)!.confirmDeleteDuplicateCopy,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

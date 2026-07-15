import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../search/search_provider.dart';
import '../statistics/statistics_provider.dart';
import '../../core/database/app_database.dart';

/// Groups multiple batches that share the same original file name.
class _FileGroup {
  final String fileName;
  final String sourcePath;
  final List<ImportBatch> batches;

  _FileGroup({
    required this.fileName,
    required this.sourcePath,
    required this.batches,
  });

  int get totalRecords => batches.fold(0, (sum, b) => sum + b.rowCount);
  int get importCount => batches.length;
  DateTime get firstImport =>
      batches.map((b) => b.importedAt).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime get lastImport =>
      batches.map((b) => b.importedAt).reduce((a, b) => a.isAfter(b) ? a : b);
}

class ManageFilesScreen extends ConsumerStatefulWidget {
  const ManageFilesScreen({super.key});

  @override
  ConsumerState<ManageFilesScreen> createState() => _ManageFilesScreenState();
}

class _ManageFilesScreenState extends ConsumerState<ManageFilesScreen> {
  List<_FileGroup>? _groups;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final batches = await db.batchesDao.getAllBatches();

      // A filename is not a unique source: two directories can both contain
      // data.xlsx. Group only repeated imports of the same path.
      final grouped = <String, List<ImportBatch>>{};
      for (final batch in batches) {
        final sourcePath = p.normalize(batch.localFilePath);
        grouped.putIfAbsent(sourcePath, () => []).add(batch);
      }

      final groups =
          grouped.entries
              .map(
                (entry) => _FileGroup(
                  fileName: entry.value.first.originalFileName,
                  sourcePath: entry.key,
                  batches: entry.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.lastImport.compareTo(a.lastImport));

      if (!mounted) return;
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorOccurred(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _deleteFileGroup(_FileGroup group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.warningClearAllData),
        content: Text(
          AppLocalizations.of(
            context,
          )!.confirmDeleteImportBatch(group.fileName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);

    try {
      await db.transaction(() async {
        for (final batch in group.batches) {
          await db.entriesDao.deleteEntriesByBatch(batch.id);
          await db.batchesDao.deleteBatch(batch.id);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.deletedSuccessfully(group.fileName),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      await _loadBatches();
      ref.read(searchProvider.notifier).setQuery('');
      ref.invalidate(statisticsProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorOccurred(error.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.manageIndexedFiles,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups == null || _groups!.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_off_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noIndexedFilesFound,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groups!.length,
              itemBuilder: (context, index) {
                final group = _groups![index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // File icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.insert_drive_file_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // File info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                group.sourcePath,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.recordCountAndDate(
                                  group.totalRecords,
                                  group.lastImport.toString().split(' ')[0],
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              if (group.importCount > 1) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.importCount(group.importCount),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () => _deleteFileGroup(group),
                          tooltip: AppLocalizations.of(context)!.delete,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

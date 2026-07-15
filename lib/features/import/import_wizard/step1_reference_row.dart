import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../import_wizard_provider.dart';

class Step1ReferenceRow extends ConsumerWidget {
  const Step1ReferenceRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseFileOrFolder,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ImportActionCard(
                icon: Icons.file_upload_rounded,
                title: AppLocalizations.of(context)!.files,
                subtitle: AppLocalizations.of(context)!.chooseSpecificFiles,
                color: theme.colorScheme.primary,
                onTap: () async {
                  try {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xlsx', 'csv'],
                      allowMultiple: true,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final paths = result.files.map((f) => f.path!).toList();
                      await notifier.setFilePaths(
                        {...state.filePaths, ...paths}.toList(),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.errorOccurred(e.toString()),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            if (!Platform.isAndroid && !Platform.isIOS) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _ImportActionCard(
                  icon: Icons.folder_rounded,
                  title: AppLocalizations.of(context)!.folder,
                  subtitle: AppLocalizations.of(context)!.chooseEntireFolder,
                  color: Colors.orange,
                  onTap: () async {
                    try {
                      final result = await FilePicker.getDirectoryPath();
                      if (result != null) {
                        final dir = Directory(result);
                        final files = dir
                            .listSync()
                            .where((e) {
                              final path = e.path.toLowerCase();
                              return e is File &&
                                  (path.endsWith('.xlsx') ||
                                      path.endsWith('.csv'));
                            })
                            .map((e) => e.path)
                            .toList();
                        if (files.isNotEmpty) {
                          await notifier.setFilePaths(
                            {...state.filePaths, ...files}.toList(),
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.noExcelFilesFound,
                                ),
                              ), // Ideally could rename to noFilesFound
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.errorOccurred(e.toString()),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        if (state.filePaths.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.filesSelected(state.filePaths.length),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear, color: theme.colorScheme.error),
                  onPressed: () async => notifier.setFilePaths([]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.headerRowNumber,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              final isSelected = state.referenceRowIndex == index;
              return ChoiceChip(
                label: Text(AppLocalizations.of(context)!.rowNumber(index + 1)),
                selected: isSelected,
                onSelected: (_) => notifier.setReferenceRow(index),
                selectedColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                backgroundColor: theme.colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              );
            }),
          ),
          if (state.availableSheets.length > 1) ...[
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.selectSheets,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.availableSheets.length,
                itemBuilder: (context, index) {
                  final sheet = state.availableSheets[index];
                  final isSelected = state.selectedSheets.contains(sheet);
                  return CheckboxListTile(
                    title: Text(
                      sheet,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (val) {
                      notifier.toggleSheet(sheet);
                    },
                    activeColor: theme.colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ],
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed:
                state.availableSheets.isNotEmpty &&
                    state.selectedSheets.isNotEmpty
                ? () => notifier.loadHeaders()
                : null,
            child: Text(
              AppLocalizations.of(context)!.next,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }
}

class _ImportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ImportActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

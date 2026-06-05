import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../import_wizard_provider.dart';
import '../../settings/settings_screen.dart';

import 'step1_reference_row.dart';
import 'step2_column_selector.dart';
import 'step3_preview.dart';
import 'step4_progress.dart';
import 'import_summary_screen.dart';

class ImportWizardScreen extends ConsumerWidget {
  const ImportWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importWizardProvider);
    final notifier = ref.read(importWizardProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.importData,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), // Import Data
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.designedBy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.ahmedElKilany,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_android, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'WhatsApp: 01015331775',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepper(context, state, theme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildBody(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(
    BuildContext context,
    ImportWizardState state,
    ThemeData theme,
  ) {
    if (state.currentStep == ImportWizardStep.summary) {
      return const SizedBox.shrink();
    }

    int currentIndex = state.currentStep.index;
    List<String> stepTitles = [
      AppLocalizations.of(context)!.stepReferenceRow,
      AppLocalizations.of(context)!.stepColumnSelection,
      AppLocalizations.of(context)!.stepReview,
      AppLocalizations.of(context)!.stepImporting,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          bool isActive = index <= currentIndex;
          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepTitles[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody(ImportWizardState state, ImportWizardNotifier notifier) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(state.currentStep),
        child: () {
          switch (state.currentStep) {
            case ImportWizardStep.referenceRow:
              return const Step1ReferenceRow();
            case ImportWizardStep.columnSelector:
              return const Step2ColumnSelector();
            case ImportWizardStep.preview:
              return const Step3Preview();
            case ImportWizardStep.progress:
              return const Step4Progress();
            case ImportWizardStep.summary:
              return const ImportSummaryScreen();
          }
        }(),
      ),
    );
  }
}

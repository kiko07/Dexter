import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/app_database.dart';

import '../../core/utils/arabic_normalizer.dart';
import '../../core/utils/dedup_helper.dart';
import '../search/search_provider.dart'; // To access databaseProvider
import '../statistics/statistics_provider.dart';

const _sentinel = Object();

class ManualEntryState {
  final ImportProfile? activeProfile;
  final Map<String, String> formData;
  final bool isSaving;
  final String? error;
  final Entry? duplicateEntryFound;
  final int formVersion;

  ManualEntryState({
    this.activeProfile,
    this.formData = const {},
    this.isSaving = false,
    this.error,
    this.duplicateEntryFound,
    this.formVersion = 0,
  });

  ManualEntryState copyWith({
    Object? activeProfile = _sentinel,
    Map<String, String>? formData,
    bool? isSaving,
    String? error,
    Object? duplicateEntryFound = _sentinel,
    int? formVersion,
  }) {
    return ManualEntryState(
      activeProfile: identical(activeProfile, _sentinel)
          ? this.activeProfile
          : activeProfile as ImportProfile?,
      formData: formData ?? this.formData,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      duplicateEntryFound: identical(duplicateEntryFound, _sentinel)
          ? this.duplicateEntryFound
          : duplicateEntryFound as Entry?,
      formVersion: formVersion ?? this.formVersion,
    );
  }
}

class ManualEntryNotifier extends Notifier<ManualEntryState> {
  @override
  ManualEntryState build() {
    _loadDefaultProfile();
    return ManualEntryState();
  }

  Future<void> _loadDefaultProfile() async {
    final db = ref.read(databaseProvider);
    try {
      final profiles = await db.profilesDao.getAllProfiles();
      state = state.copyWith(
        activeProfile: profiles.isNotEmpty ? profiles.first : null,
      );
    } catch (e) {
      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'ERROR',
          description: 'Failed to load default profile: $e',
        ),
      );
      state = state.copyWith(activeProfile: null, error: e.toString());
    }
  }

  void updateField(String key, String value) {
    final updatedData = Map<String, String>.from(state.formData);
    updatedData[key] = value;
    state = state.copyWith(formData: updatedData);
  }

  Future<bool> saveEntry({bool ignoreDuplicate = false}) async {
    if (state.isSaving) return false;
    if (state.activeProfile == null) {
      state = state.copyWith(error: 'noActiveProfile');
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      error: null,
      duplicateEntryFound: null,
    );
    final db = ref.read(databaseProvider);

    try {
      // 1. Normalize and check for duplicate if required
      if (!ignoreDuplicate && state.activeProfile!.dedupKeyField != null) {
        final dedupKey = state.activeProfile!.dedupKeyField!;
        final rawValue = state.formData[dedupKey] ?? '';
        final normalizedValue = DedupHelper.normalizeForDedup(rawValue);

        if (normalizedValue.isNotEmpty) {
          final allEntries = await db.entriesDao.getEntriesByProfile(
            state.activeProfile!.id,
          );

          Entry? actualDuplicate;
          for (var candidate in allEntries) {
            try {
              final map = jsonDecode(candidate.data) as Map<String, dynamic>;
              final val = map[dedupKey]?.toString().trim();
              if (val != null &&
                  DedupHelper.normalizeForDedup(val) == normalizedValue) {
                actualDuplicate = candidate;
                break;
              }
            } catch (_) {}
          }

          if (actualDuplicate != null) {
            state = state.copyWith(
              isSaving: false,
              duplicateEntryFound: actualDuplicate,
            );
            return false;
          }
        }
      }

      // 2. Build search_payload and JSON data
      final searchPayload = state.formData.values
          .map((v) => arabicNormalize(v))
          .join(' ');

      final dataJson = jsonEncode(state.formData);

      await db.transaction(() async {
        final entryId = await db.entriesDao.insertEntry(
          EntriesCompanion.insert(
            profileId: state.activeProfile!.id,
            data: dataJson,
            searchPayload: searchPayload,
          ),
        );

        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'INSERT',
            description: 'Added manual entry $entryId',
            entryId: drift.Value(entryId),
          ),
        );
      });

      state = state.copyWith(
        isSaving: false,
        formData: {},
        duplicateEntryFound: null,
        formVersion: state.formVersion + 1,
      );
      ref.invalidate(statisticsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final manualEntryProvider =
    NotifierProvider<ManualEntryNotifier, ManualEntryState>(() {
      return ManualEntryNotifier();
    });

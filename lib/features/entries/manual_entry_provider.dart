import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/database/app_database.dart';

import '../../core/utils/arabic_normalizer.dart';
import '../search/search_provider.dart'; // To access databaseProvider

class ManualEntryState {
  final ImportProfile? activeProfile;
  final Map<String, String> formData;
  final bool isSaving;
  final String? error;
  final Entry? duplicateEntryFound;

  ManualEntryState({
    this.activeProfile,
    this.formData = const {},
    this.isSaving = false,
    this.error,
    this.duplicateEntryFound,
  });

  ManualEntryState copyWith({
    ImportProfile? activeProfile,
    Map<String, String>? formData,
    bool? isSaving,
    String? error,
    Entry? duplicateEntryFound,
  }) {
    return ManualEntryState(
      activeProfile: activeProfile ?? this.activeProfile,
      formData: formData ?? this.formData,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      duplicateEntryFound: duplicateEntryFound, // Nullable override
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
    final profiles = await db.profilesDao.getAllProfiles();
    if (profiles.isNotEmpty) {
      state = state.copyWith(activeProfile: profiles.first);
    }
  }

  void updateField(String key, String value) {
    final updatedData = Map<String, String>.from(state.formData);
    updatedData[key] = value;
    state = state.copyWith(formData: updatedData);
  }

  Future<bool> saveEntry({bool ignoreDuplicate = false}) async {
    if (state.activeProfile == null) {
      state = state.copyWith(error: 'No active profile to map data.');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);
    final db = ref.read(databaseProvider);

    try {
      // 1. Normalize and check for duplicate if required
      if (!ignoreDuplicate && state.activeProfile!.dedupKeyField != null) {
        final dedupKey = state.activeProfile!.dedupKeyField!;
        final rawValue = state.formData[dedupKey] ?? '';
        final normalizedValue = arabicNormalize(rawValue);
        
        if (normalizedValue.isNotEmpty) {
           final allEntries = await db.entriesDao.getEntriesByProfile(state.activeProfile!.id);
           
           Entry? actualDuplicate;
           for (var candidate in allEntries) {
             try {
               final map = jsonDecode(candidate.data) as Map<String, dynamic>;
               final val = map[dedupKey]?.toString().trim();
               if (val != null && arabicNormalize(val) == normalizedValue) {
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

      final entryId = await db.entriesDao.insertEntry(EntriesCompanion.insert(
        profileId: state.activeProfile!.id,
        data: dataJson,
        searchPayload: searchPayload,
      ));

      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'INSERT',
          description: 'Added manual entry $entryId',
          entryId: drift.Value(entryId),
        )
      );

      state = state.copyWith(isSaving: false, formData: {});
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final manualEntryProvider = NotifierProvider<ManualEntryNotifier, ManualEntryState>(() {
  return ManualEntryNotifier();
});

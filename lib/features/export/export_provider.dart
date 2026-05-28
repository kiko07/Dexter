
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/export_service.dart';
import '../../core/utils/arabic_normalizer.dart';
import '../search/search_provider.dart';

class ExportState {
  final String query;
  final bool isExporting;
  final String? message;
  final bool isError;

  ExportState({
    this.query = '',
    this.isExporting = false,
    this.message,
    this.isError = false,
  });

  ExportState copyWith({
    String? query,
    bool? isExporting,
    String? message,
    bool? isError,
  }) {
    return ExportState(
      query: query ?? this.query,
      isExporting: isExporting ?? this.isExporting,
      message: message,
      isError: isError ?? this.isError,
    );
  }
}

class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() {
    return ExportState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> exportData(String destinationPath) async {
    state = state.copyWith(isExporting: true, message: null, isError: false);
    final db = ref.read(databaseProvider);

    try {
      List<Entry> entries;

      if (state.query.trim().isEmpty) {
        entries = await db.entriesDao.getAllEntries();
      } else {
        entries = await db.entriesDao.searchEntries(
          query: arabicNormalize(state.query.trim()),
          matchMode: 'contains',
          profileId: null,
        );
      }
      
      if (entries.isEmpty) {
        state = state.copyWith(
          isExporting: false, 
          message: 'noDataToExport',
          isError: true,
        );
        return;
      }

      final List<String> rawData = entries.map((e) => e.data).toList();

      final bytes = await ExportService.generateExcelBytes(
        rawData: rawData,
      );

      if (bytes == null) {
        throw Exception('failedToCreateFile');
      }

      final success = await ExportService.saveExcelFile(destinationPath, bytes);

      if (success) {
        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'EXPORT',
            description: 'Exported ${entries.length} entries (ALL DATA) to $destinationPath',
          )
        );

        state = state.copyWith(
          isExporting: false,
          message: 'allDataExportedSuccess:$destinationPath',
          isError: false,
        );
      } else {
        throw Exception('failedToSaveCheckPermissions');
      }
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> exportDataToShare() async {
    state = state.copyWith(isExporting: true, message: null, isError: false);
    final db = ref.read(databaseProvider);

    try {
      List<Entry> entries;

      if (state.query.trim().isEmpty) {
        entries = await db.entriesDao.getAllEntries();
      } else {
        entries = await db.entriesDao.searchEntries(
          query: arabicNormalize(state.query.trim()),
          matchMode: 'contains',
          profileId: null,
        );
      }
      
      if (entries.isEmpty) {
        state = state.copyWith(
          isExporting: false, 
          message: 'noDataToExport',
          isError: true,
        );
        return;
      }

      final List<String> rawData = entries.map((e) => e.data).toList();

      final bytes = await ExportService.generateExcelBytes(
        rawData: rawData,
      );

      if (bytes == null) {
        throw Exception('failedToCreateFile');
      }

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await db.auditDao.insertLog(
        AuditLogCompanion.insert(
          action: 'EXPORT',
          description: 'Exported ${entries.length} entries to shared file',
        )
      );

      state = state.copyWith(
        isExporting: false,
        message: 'dataExportedSuccess',
        isError: false,
      );

      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'Exported Data'));

    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> exportAllDataByDateRange(String destinationPath, DateTime? start, DateTime? end) async {
    state = state.copyWith(isExporting: true, message: null, isError: false);
    final db = ref.read(databaseProvider);

    try {
      final entries = await db.entriesDao.getEntriesByDateRange(start, end);
      
      if (entries.isEmpty) {
        state = state.copyWith(
          isExporting: false, 
          message: 'noDataToExport',
          isError: true,
        );
        return;
      }

      final List<String> rawData = entries.map((e) => e.data).toList();

      final bytes = await ExportService.generateExcelBytes(
        rawData: rawData,
      );

      if (bytes == null) {
        throw Exception('failedToCreateFile');
      }

      final success = await ExportService.saveExcelFile(destinationPath, bytes);

      if (success) {
        await db.auditDao.insertLog(
          AuditLogCompanion.insert(
            action: 'EXPORT',
            description: 'Exported ${entries.length} entries (Date Range) to $destinationPath',
          )
        );

        state = state.copyWith(
          isExporting: false,
          message: 'dataExportedSuccess:$destinationPath',
          isError: false,
        );
      } else {
        throw Exception('failedToSaveCheckPermissions');
      }
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        message: e.toString(),
        isError: true,
      );
    }
  }
}

final exportProvider = NotifierProvider<ExportNotifier, ExportState>(() {
  return ExportNotifier();
});


import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'dedup_helper.dart';

class ExcelService {
  /// Retrieves sheet names of an excel or csv file.
  static Future<List<String>> getSheetNames(String filePath) async {
    return await compute(_getSheetNamesIsolate, filePath);
  }

  static List<String> _getSheetNamesIsolate(String path) {
    var file = File(path);
    if (!file.existsSync()) return [];
    if (path.toLowerCase().endsWith('.csv')) {
      return ['Sheet1'];
    }
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    return excel.tables.keys.toList();
  }

  /// Reads the headers of an excel file from a given reference row index (0-based)
  static Future<List<String>> readHeaders(
    String filePath,
    int referenceRowIndex, {
    String? sheetName,
  }) async {
    return await compute(_readHeadersIsolate, {
      'path': filePath,
      'rowIndex': referenceRowIndex,
      'sheetName': sheetName,
    });
  }

  static List<String> _readHeadersIsolate(Map<String, dynamic> args) {
    final String path = args['path'];
    final int rowIndex = args['rowIndex'];
    final String? sheetName = args['sheetName'];

    var file = File(path);
    if (!file.existsSync()) return [];

    if (path.toLowerCase().endsWith('.csv')) {
      final csvString = file.readAsStringSync();
      // CSV values are text by default. Dynamic typing would silently turn
      // identifiers such as 00123 into 123.
      final csv = Csv();
      final rows = csv.decode(csvString);
      if (rows.length <= rowIndex) return [];
      return rows[rowIndex].map((cell) => cell?.toString() ?? '').toList();
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return [];
    var sheet = sheetName ?? excel.tables.keys.first;
    var table = excel.tables[sheet];

    if (table == null || table.rows.length <= rowIndex) return [];

    var headerRow = table.rows[rowIndex];
    return headerRow.map((cell) => extractCellValue(cell) ?? '').toList();
  }

  /// Parses the Excel file returning a list of maps, where each map is a row
  /// mapped according to the columnMap.
  static Future<List<Map<String, dynamic>>> parseData({
    required String filePath,
    required Map<String, String> columnMap,
    required int referenceRowIndex,
    String? sheetName,
  }) async {
    return await compute(_parseDataIsolate, {
      'path': filePath,
      'columnMap': columnMap,
      'rowIndex': referenceRowIndex,
      'sheetName': sheetName,
    });
  }

  static List<Map<String, dynamic>> _parseDataIsolate(
    Map<String, dynamic> args,
  ) {
    final String path = args['path'];
    final Map<String, String> columnMap = (args['columnMap'] as Map)
        .cast<String, String>();
    final int rowIndex = args['rowIndex'];
    final String? sheetName = args['sheetName'];

    var file = File(path);
    if (!file.existsSync()) return [];

    if (path.toLowerCase().endsWith('.csv')) {
      final csvString = file.readAsStringSync();
      final csv = Csv();
      final rows = csv.decode(csvString);
      if (rows.length <= rowIndex + 1) return [];

      List<Map<String, dynamic>> parsedRows = [];
      for (int i = rowIndex + 1; i < rows.length; i++) {
        var row = rows[i];
        Map<String, dynamic> rowMap = {};
        bool hasData = false;

        columnMap.forEach((colKey, headerName) {
          int colIndex;
          final parsed = int.tryParse(colKey);
          if (parsed != null) {
            colIndex = parsed;
          } else if (colKey.length == 1 &&
              colKey.codeUnitAt(0) >= 65 &&
              colKey.codeUnitAt(0) <= 90) {
            colIndex = colKey.codeUnitAt(0) - 65;
          } else {
            return;
          }
          if (colIndex >= 0 && colIndex < row.length) {
            var cellValue = row[colIndex]?.toString();
            if (cellValue != null && cellValue.trim().isNotEmpty) {
              rowMap[headerName] = cellValue.trim();
              hasData = true;
            }
          }
        });

        if (hasData) {
          rowMap['_rowIndex'] = (i + 1).toString();
          parsedRows.add(rowMap);
        }
      }
      return parsedRows;
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return [];
    var sheet = sheetName ?? excel.tables.keys.first;
    var table = excel.tables[sheet];

    return _parseTable(table, columnMap, rowIndex);
  }

  /// Parses all sheets in an excel workbook, returning a map of sheet names to lists of row maps.
  static Future<Map<String, List<Map<String, dynamic>>>> parseAllSheets({
    required String filePath,
    required Map<String, String> columnMap,
    required int referenceRowIndex,
  }) async {
    return await compute(_parseAllSheetsIsolate, {
      'path': filePath,
      'columnMap': columnMap,
      'rowIndex': referenceRowIndex,
    });
  }

  static Map<String, List<Map<String, dynamic>>> _parseAllSheetsIsolate(
    Map<String, dynamic> args,
  ) {
    final String path = args['path'];
    final Map<String, String> columnMap = (args['columnMap'] as Map)
        .cast<String, String>();
    final int rowIndex = args['rowIndex'];

    var file = File(path);
    if (!file.existsSync()) return {};

    if (path.toLowerCase().endsWith('.csv')) {
      final rows = _parseDataIsolate({
        'path': path,
        'columnMap': columnMap,
        'rowIndex': rowIndex,
        'sheetName': 'Sheet1',
      });
      return {'Sheet1': rows};
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    Map<String, List<Map<String, dynamic>>> allSheetsData = {};

    for (final sheet in excel.tables.keys) {
      final table = excel.tables[sheet];
      final rows = _parseTable(table, columnMap, rowIndex);
      if (rows.isNotEmpty) {
        allSheetsData[sheet] = rows;
      }
    }

    return allSheetsData;
  }

  /// Shared parser helper for table sheet
  static List<Map<String, dynamic>> _parseTable(
    Sheet? table,
    Map<String, String> columnMap,
    int rowIndex,
  ) {
    if (table == null || table.rows.length <= rowIndex + 1) return [];

    List<Map<String, dynamic>> parsedRows = [];

    for (int i = rowIndex + 1; i < table.rows.length; i++) {
      var row = table.rows[i];
      Map<String, dynamic> rowMap = {};
      bool hasData = false;

      columnMap.forEach((colKey, headerName) {
        int colIndex;
        final parsed = int.tryParse(colKey);
        if (parsed != null) {
          colIndex = parsed;
        } else if (colKey.length == 1 &&
            colKey.codeUnitAt(0) >= 65 &&
            colKey.codeUnitAt(0) <= 90) {
          colIndex = colKey.codeUnitAt(0) - 65;
        } else {
          return; // skip invalid key
        }
        if (colIndex >= 0 && colIndex < row.length) {
          var cellValue = extractCellValue(row[colIndex]);
          if (cellValue != null && cellValue.trim().isNotEmpty) {
            rowMap[headerName] = cellValue.trim();
            hasData = true;
          }
        }
      });

      if (hasData) {
        rowMap['_rowIndex'] = (i + 1).toString();
        parsedRows.add(rowMap);
      }
    }

    return parsedRows;
  }

  /// Extracts formatted cell values, specifically handling percentages and decimal digits.
  static String? extractCellValue(Data? cell) {
    if (cell == null || cell.value == null) return null;
    final value = cell.value!;

    if (value is DoubleCellValue) {
      final doubleVal = value.value;
      final numFormat = cell.cellStyle?.numberFormat;
      if (numFormat != null && numFormat.formatCode.contains('%')) {
        final decimalPlaces = _getDecimalPlaces(numFormat.formatCode);
        return '${(doubleVal * 100).toStringAsFixed(decimalPlaces)}%';
      }
      if (doubleVal == doubleVal.roundToDouble()) {
        return doubleVal.toInt().toString();
      }
      return doubleVal.toString();
    }

    if (value is IntCellValue) {
      return value.value.toString();
    }
    if (value is BoolCellValue) {
      return value.value.toString();
    }
    if (value is TextCellValue) {
      return value.value.toString();
    }

    return value.toString();
  }

  static int _getDecimalPlaces(String formatCode) {
    final parts = formatCode.split('.');
    if (parts.length < 2) return 0;
    final afterDecimal = parts[1];
    int count = 0;
    for (int i = 0; i < afterDecimal.length; i++) {
      final char = afterDecimal[i];
      if (char == '0' || char == '#') {
        count++;
      } else if (char == '%') {
        break;
      }
    }
    return count;
  }

  /// Builds an index-to-field mapping while making duplicate headers safe.
  /// Without this, later columns overwrite earlier values in the row map.
  static Map<String, String> buildColumnMap(List<String> headers) {
    final result = <String, String>{};
    final usedNames = <String>{};

    for (var i = 0; i < headers.length; i++) {
      final baseName = headers[i].trim();
      if (baseName.isEmpty) continue;

      var name = baseName;
      var suffix = 2;
      while (!usedNames.add(name.toLowerCase())) {
        name = '$baseName ($suffix)';
        suffix++;
      }
      result[i.toString()] = name;
    }

    return result;
  }

  /// Converts a 1-based column index to an Excel column label.
  static String columnLetter(int index) {
    if (index <= 0) {
      throw ArgumentError.value(index, 'index', 'Must be 1-based.');
    }

    var result = '';
    var i = index;
    while (i > 0) {
      i--;
      result = String.fromCharCode(65 + (i % 26)) + result;
      i ~/= 26;
    }
    return result;
  }

  /// Writes database entries to an .xlsx file and returns the output file.
  static Future<File> exportEntriesToXlsx({
    required List<Entry> entries,
    required String outputPath,
  }) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    const sheetName = 'Data';
    final sheet = excel[sheetName];
    if (defaultSheet != null && defaultSheet != sheetName) {
      excel.delete(defaultSheet);
    }

    final decodedRows = <Map<String, dynamic>>[];
    final fieldNames = <String>[];
    final seenFields = <String>{};

    for (final entry in entries) {
      var data = <String, dynamic>{};
      try {
        data = (jsonDecode(entry.data) as Map).cast<String, dynamic>();
      } catch (_) {}
      decodedRows.add(data);

      final exportData = Map<String, dynamic>.from(data);
      exportData.remove('_rowIndex');
      exportData.remove('_sheetName');
      for (final key in exportData.keys) {
        if (seenFields.add(key)) {
          fieldNames.add(key);
        }
      }
    }

    final headers = <String>[
      'ID',
      'Profile ID',
      'Source File',
      'Sheet',
      'Row',
      'Created At',
      ...fieldNames,
    ];

    for (var column = 0; column < headers.length; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0))
          .value = TextCellValue(
        headers[column],
      );
    }

    for (var row = 0; row < entries.length; row++) {
      final entry = entries[row];
      final data = decodedRows[row];
      final metadataFree = DedupHelper.stripMetadataForDedup(data);
      final values = <String>[
        entry.id.toString(),
        entry.profileId.toString(),
        entry.sourceFile ?? '',
        data['_sheetName']?.toString() ?? '',
        data['_rowIndex']?.toString() ?? '',
        entry.createdAt.toIso8601String(),
        ...fieldNames.map((field) => metadataFree[field]?.toString() ?? ''),
      ];

      for (var column = 0; column < values.length; column++) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: column,
                rowIndex: row + 1,
              ),
            )
            .value = TextCellValue(
          values[column],
        );
      }
    }

    final bytes = excel.save(fileName: outputPath);
    if (bytes == null) {
      throw StateError('Failed to encode Excel workbook.');
    }

    final file = File(outputPath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> sweepOldExports({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      await for (final entity in tempDir.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        if (!name.startsWith('dexter_export_') || !name.endsWith('.xlsx')) {
          continue;
        }
        try {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > maxAge) {
            await entity.delete();
          }
        } catch (_) {
          // Cleanup is best-effort and must never prevent app startup.
        }
      }
    } catch (_) {
      // Cleanup is best-effort and must never prevent app startup.
    }
  }
}

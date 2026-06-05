import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';

class ExcelService {
  /// Reads the headers of an excel file from a given reference row index (0-based)
  static Future<List<String>> readHeaders(
    String filePath,
    int referenceRowIndex,
  ) async {
    return await compute(_readHeadersIsolate, {
      'path': filePath,
      'rowIndex': referenceRowIndex,
    });
  }

  static List<String> _readHeadersIsolate(Map<String, dynamic> args) {
    final String path = args['path'];
    final int rowIndex = args['rowIndex'];

    var file = File(path);
    if (!file.existsSync()) return [];

    if (path.toLowerCase().endsWith('.csv')) {
      final csvString = file.readAsStringSync();
      final rows = Csv().decode(csvString);
      if (rows.length <= rowIndex) return [];
      return rows[rowIndex].map((cell) => cell?.toString() ?? '').toList();
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Use the first sheet or default sheet
    var sheet = excel.tables.keys.first;
    var table = excel.tables[sheet];

    if (table == null || table.rows.length <= rowIndex) return [];

    var headerRow = table.rows[rowIndex];
    return headerRow.map((cell) => cell?.value?.toString() ?? '').toList();
  }

  /// Parses the Excel file returning a list of maps, where each map is a row
  /// mapped according to the columnMap.
  static Future<List<Map<String, dynamic>>> parseData({
    required String filePath,
    required Map<String, String> columnMap,
    required int referenceRowIndex,
  }) async {
    return await compute(_parseDataIsolate, {
      'path': filePath,
      'columnMap': columnMap,
      'rowIndex': referenceRowIndex,
    });
  }

  static List<Map<String, dynamic>> _parseDataIsolate(
    Map<String, dynamic> args,
  ) {
    final String path = args['path'];
    final Map<String, String> columnMap = (args['columnMap'] as Map)
        .cast<String, String>();
    final int rowIndex = args['rowIndex'];

    var file = File(path);
    if (!file.existsSync()) return [];

    if (path.toLowerCase().endsWith('.csv')) {
      final csvString = file.readAsStringSync();
      final rows = Csv().decode(csvString);
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
          rowMap['_rowIndex'] = i + 1;
          parsedRows.add(rowMap);
        }
      }
      return parsedRows;
    }

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    var sheet = excel.tables.keys.first;
    var table = excel.tables[sheet];

    if (table == null || table.rows.length <= rowIndex + 1) return [];

    List<Map<String, dynamic>> parsedRows = [];

    // Process rows after the header row
    for (int i = rowIndex + 1; i < table.rows.length; i++) {
      var row = table.rows[i];
      Map<String, dynamic> rowMap = {};

      bool hasData = false;

      columnMap.forEach((colKey, headerName) {
        // Column key is an integer string index ("0", "1", "2", ...)
        // Fall back to letter-based for backwards compatibility (A=0, B=1, ...)
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
          var cellValue = row[colIndex]?.value?.toString();
          if (cellValue != null && cellValue.trim().isNotEmpty) {
            rowMap[headerName] = cellValue.trim();
            hasData = true;
          }
        }
      });

      if (hasData) {
        rowMap['_rowIndex'] = i + 1;
        parsedRows.add(rowMap);
      }
    }

    return parsedRows;
  }
}

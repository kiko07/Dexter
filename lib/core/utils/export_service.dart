import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  /// Generates an Excel file from a list of entries in a background isolate.
  /// Returns the raw bytes of the generated `.xlsx` file.
  static Future<List<int>?> generateExcelBytes({
    required List<String> rawData,
  }) async {
    return await compute(_generateExcelIsolate, {
      'data': rawData,
    });
  }

  static List<int>? _generateExcelIsolate(Map<String, dynamic> args) {
    final List<String> rawData = (args['data'] as List).cast<String>();
    
    // Parse JSON and extract headers simultaneously in the background isolate
    Set<String> allHeaders = {};
    List<Map<String, dynamic>> dataList = [];
    
    for (String raw in rawData) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        dataList.add(map);
        allHeaders.addAll(map.keys);
      } catch (_) {
        dataList.add({});
      }
    }
    
    final List<String> headers = allHeaders.toList();

    var excel = Excel.createExcel();
    var sheet = excel['Export'];
    excel.setDefaultSheet('Export');

    // Remove the default 'Sheet1'
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Write Headers
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Write Data Rows
    for (var rowData in dataList) {
      final row = headers.map((header) {
        final val = rowData[header];
        return val != null ? TextCellValue(val.toString()) : TextCellValue('');
      }).toList();
      
      sheet.appendRow(row);
    }

    return excel.encode();
  }

  /// Helper to save bytes to a specified file path
  static Future<bool> saveExcelFile(String path, List<int> bytes) async {
    try {
      final file = File(path);
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      debugPrint('Export Error: $e');
      return false;
    }
  }
}

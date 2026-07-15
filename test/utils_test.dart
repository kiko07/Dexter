import 'dart:io';

import 'package:dexter/core/utils/dedup_helper.dart';
import 'package:dexter/core/utils/excel_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('columnLetter handles Excel boundaries', () {
    expect(ExcelService.columnLetter(1), 'A');
    expect(ExcelService.columnLetter(26), 'Z');
    expect(ExcelService.columnLetter(27), 'AA');
    expect(ExcelService.columnLetter(52), 'AZ');
    expect(ExcelService.columnLetter(53), 'BA');
    expect(ExcelService.columnLetter(702), 'ZZ');
    expect(ExcelService.columnLetter(703), 'AAA');
  });

  test('fallback dedup normalization excludes import metadata', () {
    final first = DedupHelper.normalizePayloadForDedup({
      'name': 'Ali',
      'city': 'Cairo',
      '_sheetName': 'Sheet1',
      '_rowIndex': '2',
    });
    final second = DedupHelper.normalizePayloadForDedup({
      'name': 'Ali',
      'city': 'Cairo',
      '_sheetName': 'Sheet2',
      '_rowIndex': '5',
    });

    expect(first, second);
  });

  test('fallback dedup keeps field boundaries and field names', () {
    final first = DedupHelper.normalizePayloadForDedup({
      'first': 'Ali Hassan',
      'city': 'Cairo',
    });
    final reordered = DedupHelper.normalizePayloadForDedup({
      'city': 'Cairo',
      'first': 'Ali Hassan',
    });
    final swapped = DedupHelper.normalizePayloadForDedup({
      'first': 'Cairo',
      'city': 'Ali Hassan',
    });

    expect(first, reordered);
    expect(first, isNot(swapped));
  });

  test('buildColumnMap disambiguates duplicate headers', () {
    expect(ExcelService.buildColumnMap(['Name', 'Name', 'name', '', 'Code']), {
      '0': 'Name',
      '1': 'Name (2)',
      '2': 'name (3)',
      '4': 'Code',
    });
  });

  test(
    'CSV parsing preserves leading zero identifiers and row metadata',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'dexter_csv_test_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}codes.csv');
      await file.writeAsString('Code,Name\n00123,Ali\n');

      final rows = await ExcelService.parseData(
        filePath: file.path,
        columnMap: const {'0': 'Code', '1': 'Name'},
        referenceRowIndex: 0,
      );

      expect(rows, hasLength(1));
      expect(rows.single['Code'], '00123');
      expect(rows.single['_rowIndex'], '2');
    },
  );

  test('quoteJsonPath handles spaces and quotes', () {
    expect(DedupHelper.quoteJsonPath('First Name'), r'$."First Name"');
    expect(DedupHelper.quoteJsonPath('a"b'), r'$."a\"b"');
  });
}

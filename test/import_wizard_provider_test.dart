import 'dart:convert';
import 'dart:io';

import 'package:dexter/core/database/app_database.dart';
import 'package:dexter/features/import/import_wizard_provider.dart';
import 'package:dexter/features/search/search_provider.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('import preserves sheet selection and source row metadata', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final directory = await Directory.systemTemp.createTemp(
      'dexter_import_test_',
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await directory.delete(recursive: true);
    });

    final workbook = Excel.createExcel();
    final first = workbook['Sheet1'];
    first.cell(CellIndex.indexByString('A1')).value = TextCellValue('Ignored');
    first.cell(CellIndex.indexByString('A2')).value = TextCellValue('first');
    final selected = workbook['Selected'];
    selected.cell(CellIndex.indexByString('A1')).value = TextCellValue('Code');
    selected.cell(CellIndex.indexByString('A2')).value = TextCellValue('00123');

    final file = File(
      '${directory.path}${Platform.pathSeparator}selection.xlsx',
    );
    await file.writeAsBytes(workbook.save()!);

    final notifier = container.read(importWizardProvider.notifier);
    await notifier.setFilePaths([file.path]);
    notifier.toggleSheet('Sheet1');
    await notifier.loadHeaders();

    expect(container.read(importWizardProvider).selectedSheets, ['Selected']);
    expect(container.read(importWizardProvider).selectedColumns, {'0': 'Code'});

    await notifier.startImport();

    final entries = await db.entriesDao.getAllEntries();
    expect(entries, hasLength(1));
    final data = (jsonDecode(entries.single.data) as Map)
        .cast<String, dynamic>();
    expect(data['Code'], '00123');
    expect(data['_sheetName'], 'Selected');
    expect(data['_rowIndex'], '2');
  });
}

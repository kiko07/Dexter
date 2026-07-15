import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/utils/excel_service.dart';
import 'core/utils/secure_storage_service.dart';
import 'features/search/search_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SecureStorageService.initializeOnFirstRun();
  await ExcelService.sweepOldExports();
  final encryptionKey = await SecureStorageService.getDatabaseEncryptionKey();
  final database = AppDatabase(encryptionKey: encryptionKey);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const DexterApp(),
    ),
  );
}

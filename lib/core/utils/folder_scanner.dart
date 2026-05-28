import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class FolderScanner {
  /// Scans a specific folder for .xlsx files.
  /// IMPORTANT: This is a shallow scan (recursive: false) to prevent reading massive directory trees.
  static Future<List<File>> scanForExcelFiles(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) return [];

      final files = <File>[];
      
      // Shallow list, no recursion
      await for (final entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (ext == '.xlsx') {
            files.add(entity);
          }
        }
      }
      
      return files;
    } catch (e) {
      debugPrint('Folder Scan Error: $e');
      return [];
    }
  }

  /// Sets up a basic file watcher on a directory to listen for new .xlsx files
  static Stream<FileSystemEvent>? watchDirectory(String directoryPath) {
    try {
      final dir = Directory(directoryPath);
      if (!dir.existsSync()) return null;
      
      return dir.watch(events: FileSystemEvent.create);
    } catch (e) {
      debugPrint('Folder Watch Error: $e');
      return null;
    }
  }
}

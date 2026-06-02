import 'dart:io';

import 'package:quick_share_app/shared_prefs/record_backup_prefs.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<void> cleanAudioCache() async {
    final backupPath = RecordBackupPrefs.getBackupPath();
    final skipRecordFolder = backupPath != null && backupPath != "";

    final tempDir = await getTemporaryDirectory();
    final tempContents = tempDir.listSync();

    for (final entity in tempContents) {
      final isDirectory = entity is Directory;
      final path = entity.path;

      final isRecordFolder = isDirectory && path.endsWith('/record');
      final isIntermediateFolder = isDirectory && path.endsWith('/intermediate');
      if (skipRecordFolder && isRecordFolder) {
        continue; // Skip deleting /record
      }

      if (isIntermediateFolder || isRecordFolder) {
        try {
          await entity.delete(recursive: true);
          print("Deleted intermediate folder: $path");
        } catch (e) {
          print("Error deleting $path: $e");
        }
      }
    }
  }

  static Future<int> getFolderSize(Directory dir) async {
    int size = 0;

    try {
      final files = dir.listSync(recursive: true, followLinks: false);
      for (var file in files) {
        if (file is File) {
          size += await file.length();
        }
      }
    } catch (e) {
      print("Error calculating size of ${dir.path}: $e");
    }

    return size;
  }
}
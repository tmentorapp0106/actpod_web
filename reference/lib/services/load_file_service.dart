import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LoadFileService {
  static Future<File?> loadAudioFile({required Function(double progress) progressFunction}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: false, // Prevent loading large files into memory
      type: Platform.isAndroid? FileType.audio : FileType.any, // audio type will cause ios crash
    );

    if (result == null) return null;

    final file = result.files.single;

    final filePath = file.path;
    if (filePath == null) {
      ToastService.showNoticeToast("無法讀取檔案路徑");
      return null;
    }

    final mimeType = lookupMimeType(filePath);
    if (mimeType != "audio/mp4" &&
        mimeType != "audio/mpeg" &&
        mimeType != "audio/x-m4a") {
      ToastService.showNoticeToast("請上傳 m4a 或是 mp3 檔案");
      return null;
    }

    // Use getTemporaryDirectory instead of ApplicationSupportDirectory
    final tempDir = await getTemporaryDirectory();
    final intermediateDir = Directory('${tempDir.path}/intermediate');
    if (!await intermediateDir.exists()) {
      await intermediateDir.create(recursive: true);
    }

    final fileExtension = p.extension(filePath); // e.g. .mp3 or .m4a
    final newFileName = '${const Uuid().v4()}$fileExtension';
    final localPath = p.join(intermediateDir.path, newFileName);
    final localFile = File(localPath);
    final outSink = localFile.openWrite();

    // Determine total size
    int totalBytes = file.size; // file_picker gives this even withData:false (usually)
    if (totalBytes == 0) {
      // Fallback (some providers return 0)
      totalBytes = await File(filePath).length();
    }
    int transferred = 0;

    final inStream = File(filePath).openRead(); // you can also set a chunk size: openRead(0, someEnd)
    final completer = Completer<File?>();

    final sub = inStream.listen(
          (chunk) {
        transferred += chunk.length;
        outSink.add(chunk);
        if (totalBytes > 0) {
          progressFunction(transferred / totalBytes);
        }
      },
      onError: (e, st) async {
        await outSink.flush();
        await outSink.close();
        completer.completeError(e, st);
      },
      onDone: () async {
        await outSink.flush();
        await outSink.close();
        // Ensure we end at 100% for good UX
        progressFunction(1.0);
        completer.complete(localFile);
      },
      cancelOnError: true,
    );

    // If you need to cancel mid-way, keep a reference to `sub` and call sub.cancel()
    return completer.future;
  }

  static Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }
}
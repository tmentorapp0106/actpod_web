import 'dart:io';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../../../services/toast_service.dart';

class DownloadController {
  Future<void> downloadAudioFile(String url, String fileName) async {
    Directory dir = await getDownloadDirectory();
    final taskId = await FlutterDownloader.enqueue(
      saveInPublicStorage: true,
      url: url,
      headers: {}, // optional: header send with url (a th token etc)
      savedDir: dir.path,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
  }
}
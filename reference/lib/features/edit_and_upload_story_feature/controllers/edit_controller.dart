import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

class EditController {
  WidgetRef _ref;
  double lastVolume = 1.0;

  EditController(this._ref);

  Future<void> clearNoise(String filePath, int nf, Function(String) successCallback, Function(int) processingCallback, Function failedCallback) async {
    AudioUtils.clearNoise(filePath, nf.toString(), successCallback, failedCallback, processingCallback);
  }
}
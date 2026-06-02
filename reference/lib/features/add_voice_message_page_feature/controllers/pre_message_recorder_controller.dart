import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../providers.dart';
import '../providers.dart';
import '../services/record_service.dart';

class PreMessageRecorderController {
  WidgetRef _ref;
  RecordService recordService = RecordService();
  String? audioFilePath;

  PreMessageRecorderController(this._ref);

  void dispose() {
    recordService.dispose();
  }

  Future<void> startRecord() async {
    WakelockPlus.enable();
    await recordService.startRecording(changeRecorderTimer);
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "recording";
  }

  Future<void> pauseRecord() async {
    await recordService.pauseRecording();
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "pausing";
  }

  Future<void> resumeRecording() async {
    await recordService.resumeRecording();
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "recording";
  }

  Future<void> stopRecord() async {
    _ref.watch(loadingProvider.notifier).state = true;
    audioFilePath = await recordService.stopRecording();
    AudioUtils.normalizeAudio(
      audioFilePath!,
      "mp3",
      (filePath) async {
        if (await File(audioFilePath!).exists()) {
          try {
            await File(audioFilePath!).delete();
          } catch (e) {
            print("Error deleting file: $e");
          }
        } else {
          print("File does not exist: $audioFilePath");
        }
        audioFilePath = filePath;
        _ref.watch(loadingProvider.notifier).state = false;
        _ref.watch(loadingPercentageProvider.notifier).state = null;
        _ref.watch(preMessageRecordStatusProvider.notifier).state = "recorded";
        _ref.watch(preMessageLengthProvider.notifier).state = recordService.getRecordedDuration();
        WakelockPlus.disable();
        _ref.watch(loadingProvider.notifier).state = false;
      }, 
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        _ref.watch(loadingProvider.notifier).state = false;
        _ref.watch(loadingPercentageProvider.notifier).state = null;
        WakelockPlus.disable();
        _ref.watch(loadingProvider.notifier).state = false;
      },
      (progress) {
        _ref.watch(loadingPercentageProvider.notifier).state = (progress / _ref.watch(preMessagePlayingTimerProvider).inMilliseconds * 100).toInt();
      },
      false,
      noiseLoudness: -35
    );
  }

  Future<void> playAudio() async {
    if(audioFilePath == null || audioFilePath == "") {
      return;
    }

    recordService.playAudio(audioFilePath!, () {
      _ref.watch(preMessageRecordStatusProvider.notifier).state = "recorded";
    },(duration) {
      changePlayerTimer(duration);
    });
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "playing";
    return;
  }

  Future<void> pauseAudio() async {
    recordService.pauseAudio();
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "pausing";
  }

  Future<void> resetRecording() async {
    await recordService.resetRecording();
    audioFilePath = null;
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "pending";
    _ref.watch(preMessageLengthProvider.notifier).state = Duration.zero;
    _ref.watch(preMessageRecordTimerProvider.notifier).state = Duration.zero;
    _ref.watch(preMessagePlayingTimerProvider.notifier).state = Duration.zero;
  }

  Future<void> restartAudio() async {
    recordService.restartAudio();
    _ref.watch(preMessageRecordStatusProvider.notifier).state = "playing";
  }

  void changeRecorderTimer(Duration duration) {
    _ref.watch(preMessageRecordTimerProvider.notifier).state = duration;
  }

  void changePlayerTimer(Duration duration) {
    _ref.watch(preMessagePlayingTimerProvider.notifier).state = duration;
  }
}
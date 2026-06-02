import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers.dart';
import '../services/record_service.dart';

class AfterMessageRecorderController {
  WidgetRef _ref;
  RecordService recordService = RecordService();
  String? audioFilePath;

  AfterMessageRecorderController(this._ref);

  void dispose() {
    recordService.dispose();
  }

  Future<void> startRecord() async {
    WakelockPlus.enable();
    await recordService.startRecording(changeRecorderTimer);
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "recording";
  }

  Future<void> pauseRecord() async {
    await recordService.pauseRecording();
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "pausing";
  }

  Future<void> resumeRecording() async {
    await recordService.resumeRecording();
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "recording";
  }

  Future<void> stopRecord() async {
    _ref.watch(loadingProvider.notifier).state = true;
    audioFilePath = await recordService.stopRecording();
    WakelockPlus.disable();
    _ref.watch(loadingProvider.notifier).state = false;
    AudioUtils.normalizeAudio(
      audioFilePath!,
      "mp3",
      (filePath) async {
        File(audioFilePath!).delete();
        audioFilePath = filePath;
        _ref.watch(loadingProvider.notifier).state = false;
        _ref.watch(loadingPercentageProvider.notifier).state = null;
        _ref.watch(afterMessageRecordStatusProvider.notifier).state = "recorded";
        _ref.watch(afterMessageLengthProvider.notifier).state = recordService.getRecordedDuration();
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
        try {
          _ref.watch(loadingPercentageProvider.notifier).state = (progress / _ref.watch(afterMessagePlayingTimerProvider).inMilliseconds * 100).toInt();
        } catch(e) {
          print(e);
        }
      },
      false,
      noiseLoudness: -35
    );
  }

  Future<Duration> playAudio() async {
    if(audioFilePath == null || audioFilePath == "") {
      return Duration.zero;
    }
    Duration length = await recordService.playAudio(audioFilePath!, () {
      _ref.watch(afterMessageRecordStatusProvider.notifier).state = "recorded";
    },(duration) {
      changePlayerTimer(duration);
    });
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "playing";
    return length;
  }

  Future<void> pauseAudio() async {
    recordService.pauseAudio();
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "pausing";
  }

  Future<void> resetRecording() async {
    await recordService.resetRecording();
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "pending";
    _ref.watch(afterMessageLengthProvider.notifier).state = Duration.zero;
    _ref.watch(afterMessageRecordTimerProvider.notifier).state = Duration.zero;
    _ref.watch(afterMessagePlayingTimerProvider.notifier).state = Duration.zero;
  }

  Future<void> restartAudio() async {
    recordService.restartAudio();
    _ref.watch(afterMessageRecordStatusProvider.notifier).state = "playing";
  }

  void changeRecorderTimer(Duration duration) {
    _ref.watch(afterMessageRecordTimerProvider.notifier).state = duration;
  }

  void changePlayerTimer(Duration duration) {
    _ref.watch(afterMessagePlayingTimerProvider.notifier).state = duration;
  }
}
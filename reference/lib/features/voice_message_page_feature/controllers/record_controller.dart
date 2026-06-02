import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/voice_message_page_feature/service/record_service.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers.dart';

class RecordController {
  WidgetRef ref;
  RecordService recordService;
  String? audioFilePath;

  RecordController(this.ref, this.recordService);

  Future<void> startRecord() async {
    WakelockPlus.enable();
    await recordService.startRecording(changeRecorderTimer);
  }

  Future<void> stopRecord() async {
    audioFilePath = await recordService.stopRecording();
    ref.watch(loadingProvider.notifier).state = true;
    AudioUtils.normalizeAudio(
      audioFilePath!,
      "mp3",
      (filePath) async {
        File(audioFilePath!).delete();
        audioFilePath = filePath;
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
        ref.watch(responseStatusProvider.notifier).state = "recorded";
        ref.watch(responseRecordTimerProvider.notifier).state = Duration.zero;
        ref.watch(responsePlayingTimerProvider.notifier).state = Duration.zero;
        ref.watch(responseLengthProvider.notifier).state = recordService.getRecordedDuration();
        WakelockPlus.disable();
        ref.watch(loadingProvider.notifier).state = false;
      }, 
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
        WakelockPlus.disable();
        ref.watch(loadingProvider.notifier).state = false;
      },
      (progress) {
        ref.watch(loadingPercentageProvider.notifier).state = (progress / ref.watch(responseRecordTimerProvider).inMilliseconds * 100).toInt();
      },
      ref.watch(changeVoiceProvider),
      noiseLoudness: -35
    );
    WakelockPlus.disable();
  }

  Future<Duration> playAudio() async {
    if(audioFilePath == null || audioFilePath == "") {
      return Duration.zero;
    }
    Duration length = await recordService.playAudio(audioFilePath!, () {
      ref.watch(responseStatusProvider.notifier).state = "recorded";
    },(duration) {
      ref.watch(responsePlayingTimerProvider.notifier).state = duration;
    });
    ref.watch(responseStatusProvider.notifier).state = "playing";
    return length;
  }

  Future<void> pauseAudio() async {
    recordService.pauseAudio();
    ref.watch(responseStatusProvider.notifier).state = "pausing";
  }

  Future<void> stopAudio() async {
    recordService.stopAudio();
    ref.watch(responseStatusProvider.notifier).state = "pausing";
  }

  Future<void> resetRecording() async {
    await recordService.resetRecording();
    ref.watch(responseStatusProvider.notifier).state = "pending";
    ref.watch(responseLengthProvider.notifier).state = Duration.zero;
    ref.watch(responseRecordTimerProvider.notifier).state = Duration.zero;
    ref.watch(responsePlayingTimerProvider.notifier).state = Duration.zero;
  }

  Future<void> restartAudio() async {
    recordService.restartAudio();
    ref.watch(responseStatusProvider.notifier).state = "playing";
  }

  void changeRecorderTimer(Duration duration) {
    if(duration > Duration(seconds: 299)) {
      stopRecord();
    }
    ref.watch(responseRecordTimerProvider.notifier).state = duration;
  }
}
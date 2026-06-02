import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/send_voice_message_feature/services/send_expend_message_record_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../providers.dart';
import '../../../services/toast_service.dart';
import '../../../utils/audio_utils.dart';
import '../providers.dart';

class RecordController {
  BuildContext context;
  WidgetRef ref;
  SendExpendMessageRecordService recordService;
  String? audioFilePath;

  RecordController(this.context, this.ref, this.recordService);

  Future<void> startRecord() async {
    WakelockPlus.enable();
    await recordService.startRecording(onDurationChange);
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
        ref.watch(sendVoiceMessageStatusProvider.notifier).state = "recorded";
        ref.watch(messagePlayingTimerProvider.notifier).state = Duration.zero;
        ref.watch(voiceMessageLengthProvider.notifier).state = recordService.getRecordedDuration();
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
        ref.watch(loadingPercentageProvider.notifier).state = (progress / ref.watch(messageRecordTimerProvider).inMilliseconds * 100).toInt();
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
      ref.watch(sendVoiceMessageStatusProvider.notifier).state = "recorded";
    },(duration) {
      ref.watch(messagePlayingTimerProvider.notifier).state = duration;
    });
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "playing";
    return length;
  }

  Future<void> pauseAudio() async {
    recordService.pauseAudio();
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "paused";
  }

  Future<void> stopAudio() async {
    recordService.stopAudio();
    ref.watch(voiceMessageLengthProvider.notifier).state = Duration.zero;
    ref.watch(messageRecordTimerProvider.notifier).state = Duration.zero;
    ref.watch(messagePlayingTimerProvider.notifier).state = Duration.zero;
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
  }

  Future<void> resetRecording() async {
    await recordService.resetRecording();
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "pending";
    ref.watch(voiceMessageLengthProvider.notifier).state = Duration.zero;
    ref.watch(messageRecordTimerProvider.notifier).state = Duration.zero;
    ref.watch(messagePlayingTimerProvider.notifier).state = Duration.zero;
  }

  Future<void> restartAudio() async {
    recordService.restartAudio();
    ref.watch(sendVoiceMessageStatusProvider.notifier).state = "playing";
  }

  void onDurationChange(Duration duration) {
    if(duration > Duration(seconds: 299)) {
      stopRecord();
    }
    ref.watch(messageRecordTimerProvider.notifier).state = duration;
  }
}
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RecordService {
  final RecorderController recorderController = RecorderController();
  final PlayerController playerController = PlayerController();
  String? path;

  RecordService();

  void dispose() {
    recorderController.dispose();
    playerController.dispose();
  }

  Future<void> startRecording(Function onDurationChanged) async {
    final hasPermission = await recorderController.checkPermission();
    if (!hasPermission) {
      ToastService.showSuccessToast("please grant microphone permission");
      return;
    }

    Directory appDirectory = await getTemporaryDirectory();
    String path = "${appDirectory.path}/${const Uuid().v1()}.m4a";
    recorderController.onCurrentDuration.listen((duration) {
      onDurationChanged(duration);
    });

    await recorderController.record(
        path: path,
    );
  }

  Future<String> stopRecording() async {
    String? path = await recorderController.stop();
    recorderController.refresh();
    return path!;
  }

  Future<void> pauseRecording() async {
    await recorderController.pause();
  }

  Future<void> resumeRecording() async {
    await recorderController.record(
        path: path,
    );
  }

  Duration getRecordedDuration() {
    return recorderController.recordedDuration;
  }

  Future<Duration> playAudio(String audioPath, Function onCompletion, Function onCursorChange) async {
    await playerController.preparePlayer(
      path: audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    playerController.startPlayer();
    playerController.onCompletion.listen((_) {
      playerController.stopPlayer();
      onCompletion();
    });
    playerController.onCurrentDurationChanged.listen((durationMillisecond) {
      onCursorChange(Duration(milliseconds: durationMillisecond));
    });

    final duration = await playerController.getDuration(DurationType.max);
    return Duration(milliseconds: duration?? 0);
  }

  Future<void> resetRecording() async {
    playerController.stopPlayer();
    recorderController.stop(false);
    recorderController.reset();
  }

  Future<void> restartAudio() async {
    playerController.startPlayer();
  }

  Future<void> pauseAudio() async {
    await playerController.pausePlayer();
  }

  Future<void> stopAudio() async {
    await playerController.stopPlayer();
  }
}
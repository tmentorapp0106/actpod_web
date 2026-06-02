
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RecordService {
  final RecorderController _recorderController;
  final PlayerController _playerController;
  StreamSubscription<Duration>? recordTimerSub;

  RecordService(this._recorderController, this._playerController);

  Future<void> startRecording(Function onDurationChanged) async {
    final hasPermission = await _recorderController.checkPermission();
    if (!hasPermission) {
      ToastService.showSuccessToast("please grant microphone permission");
      return;
    }

    Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = "${appDirectory.path}/${const Uuid().v1()}.m4a";
    if(recordTimerSub != null) {
      recordTimerSub!.cancel();
      recordTimerSub = null;
    }
    recordTimerSub = _recorderController.onCurrentDuration.listen((duration) {
      final fixed = Platform.isAndroid
          ? Duration(milliseconds: (duration.inMilliseconds / 2).round())
          : duration;
      onDurationChanged(fixed);
    });

    await _recorderController.record(
      path: path,
    );
  }

  Future<String> stopRecording() async {
    String? path = await _recorderController.stop();
    _recorderController.refresh();
    return path!;
  }

  Future<void> pauseRecording() async {
    await _recorderController.pause();
  }

  Duration getRecordedDuration() {
    return _recorderController.recordedDuration;
  }

  void dispose() {
    recordTimerSub?.cancel();
    recordTimerSub = null;
    _recorderController.dispose();
    _playerController.dispose();
  }

  Future<Duration> playAudio(String audioPath, Function onCompletion, Function onCursorChange) async {
    await _playerController.preparePlayer(
      path: audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    _playerController.startPlayer();
    _playerController.onCompletion.listen((_) {
      _playerController.stopPlayer();
      onCompletion();
    });
    _playerController.onCurrentDurationChanged.listen((durationMillisecond) {
      onCursorChange(Duration(milliseconds: durationMillisecond));
    });

    final duration = await _playerController.getDuration(DurationType.max);
    return Duration(milliseconds: duration);
  }

  Future<void> resetRecording() async {
    _recorderController.stop(false);
    _recorderController.reset();
  }

  Future<void> restartAudio() async {
    _playerController.startPlayer();
  }

  Future<void> pauseAudio() async {
    await _playerController.pausePlayer();
  }

  Future<void> stopAudio() async {
    await _playerController.stopPlayer();
  }
}
import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

class PlayService {
  final AudioPlayer _audioPlayer;
  StreamSubscription<Duration>? positionStreamSub;
  StreamSubscription<ProcessingState>? stateStreamSub;
  StreamSubscription<int?>? indexStreamSub;
  final _playList = ConcatenatingAudioSource(children: [], useLazyPreparation: false);


  PlayService(this._audioPlayer);

  void dispose() {
    _audioPlayer.dispose();
    positionStreamSub?.cancel();
    stateStreamSub?.cancel();
  }

  Future<void> playAudio() async {
    await _audioPlayer.play();
  }

  Future<Duration?> prepareFileAudio(String audioPath, Function onCursorChange, Function onComplete, {double? positionFreq}) async {
    Duration? duration = await _audioPlayer.setAudioSource(AudioSource.file(audioPath));

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      onCursorChange(duration);
    });

    if(stateStreamSub != null) {
      await stateStreamSub!.cancel();
      stateStreamSub = null;
    }
    stateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
    });

    return duration;
  }

  Future<Duration?> prepareUrlAudio(String url, Function onCursorChange, Function onComplete) async {
    Duration? duration = await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      onCursorChange(duration);
    });

    if(stateStreamSub != null) {
      await stateStreamSub!.cancel();
      stateStreamSub = null;
    }
    stateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
    });

    return duration;
  }

  Future<void> prepareConcatenatingAudio(Function onCursorChange, Function onComplete) async {
    ConcatenatingAudioSource(children: [], useLazyPreparation: true);
    await _audioPlayer.setAudioSource(_playList);

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      onCursorChange(duration);
    });

    if(stateStreamSub != null) {
      await stateStreamSub!.cancel();
      stateStreamSub = null;
    }
    stateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
    });
  }

  Future<void> insertConcatenatingAudio(String url, int index) async {
    final newAudioSource = AudioSource.uri(Uri.parse(url));
    await _playList.insert(index, newAudioSource);

    return;
  }

  Future<void> popConcatenatingAudio(int index) async {
    await _playList.removeAt(index);
    return;
  }

  Future<void> restartAudio() async {
    await _audioPlayer.play();
    // playerController.startPlayer(finishMode: FinishMode.loop);
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _audioPlayer.setFilePath("");
  }

  Future<void> seekPosition(int millisecond, {int? index}) async {
    if(index != null) {
      await _audioPlayer.seek(Duration(milliseconds: millisecond), index: index);
      return;
    }
    await _audioPlayer.seek(Duration(milliseconds: millisecond));
  }
}
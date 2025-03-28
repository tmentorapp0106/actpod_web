import 'dart:async';

import 'package:just_audio/just_audio.dart';

class PlayService {
  final AudioPlayer _audioPlayer;
  StreamSubscription<Duration>? positionStreamSub;
  StreamSubscription<ProcessingState>? processingStateStreamSub;
  StreamSubscription<PlayerState>? playerStateStreamSub;
  StreamSubscription<int?>? indexStreamSub;
  final _playList = ConcatenatingAudioSource(children: [], useLazyPreparation: false);


  PlayService(this._audioPlayer);

  void dispose() {
    _audioPlayer.dispose();
    positionStreamSub?.cancel();
    processingStateStreamSub?.cancel();
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

    if(processingStateStreamSub != null) {
      await processingStateStreamSub!.cancel();
      processingStateStreamSub = null;
    }
    processingStateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
    });

    return duration;
  }

  Future<Duration?> prepareUrlAudio(
    String url, 
    Function onCursorChange, 
    Function onComplete,
    Function onReady,
    Function onPaused,
    Function onPlaying
  ) async {
    Duration? duration = await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      onCursorChange(duration);
    });

    if(processingStateStreamSub != null) {
      await processingStateStreamSub!.cancel();
      processingStateStreamSub = null;
    }
    processingStateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
      if (state == ProcessingState.ready) {
        onReady();
      }
    });

    if(playerStateStreamSub != null) {
      await playerStateStreamSub!.cancel();
      playerStateStreamSub = null;
    }
    playerStateStreamSub = _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        onPlaying();
      } else {
        onPaused();
      }
    });

    return duration;
  }

  Future<void> prepareConcatenatingAudioWithoutList(Function onCursorChange, Function onComplete) async {
    ConcatenatingAudioSource(children: [], useLazyPreparation: true);
    await _audioPlayer.setAudioSource(_playList);

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      onCursorChange(duration);
    });

    if(processingStateStreamSub != null) {
      await processingStateStreamSub!.cancel();
      processingStateStreamSub = null;
    }
    processingStateStreamSub = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        onComplete();
      }
    });
  }

  Future<void> prepareConcatenatingAudioWithList(List<AudioSource> audioList, List<Duration> lengthList, Function onCursorChange, Function onComplete) async {
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: audioList, useLazyPreparation: true));

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      if(duration == Duration.zero) {
        return;
      }
      // Accumulate duration of previous audio tracks
      Duration accumulatedDuration = Duration.zero;
      for (int i = 0; i < _audioPlayer.currentIndex!; i++) {
        accumulatedDuration += lengthList[i];
      }

      // Add the current position to the accumulated duration
      Duration totalDuration = accumulatedDuration + duration;
      onCursorChange(totalDuration);
    });

    if(processingStateStreamSub != null) {
      await processingStateStreamSub!.cancel();
      processingStateStreamSub = null;
    }
    processingStateStreamSub = _audioPlayer.processingStateStream.listen((state) {
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

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> forward(Duration duration) async {
    final currentPosition = _audioPlayer.position;
    final duration = _audioPlayer.duration; // total duration

    if (duration != null) {
      final newPosition = currentPosition + Duration(seconds: 15);
      await _audioPlayer.seek(newPosition < duration ? newPosition : duration);
    } else {
      await _audioPlayer.seek(currentPosition + Duration(seconds: 15));
    }
  }

  Future<void> backward(Duration duration) async {
    final currentPosition = _audioPlayer.position;
    final newPosition = currentPosition - Duration(seconds: 15);
    await _audioPlayer.seek(newPosition >= Duration.zero ? newPosition : Duration.zero);
  }

  Future<void> restartAudio() async {
    await _audioPlayer.play();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _audioPlayer.setFilePath("");
    // await playerController.stopPlayer();
  }

  Future<void> seekPosition(int millisecond, {int? index}) async {
    if(index != null) {
      await _audioPlayer.seek(Duration(milliseconds: millisecond), index: index);
      return;
    }
    await _audioPlayer.seek(Duration(milliseconds: millisecond));
  }
}
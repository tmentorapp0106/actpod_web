import 'dart:async';

import 'package:just_audio/just_audio.dart';

class PlayService {
  final AudioPlayer _audioPlayer;
  StreamSubscription<Duration>? positionStreamSub;
  StreamSubscription<ProcessingState>? stateStreamSub;
  StreamSubscription<int?>? indexStreamSub;


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

  Future<void> preparePlayer(Function onCursorChange, Function onComplete) async {
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

  Future<Duration?> setAudio(String url) async {
    return await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
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

  Future<void> changeAudio(String url) async {
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
  }

  Future<void> prepareConcatenatingAudio(List<AudioSource> audioList, List<Duration> lengthList, Function onCursorChange, Function onComplete) async {
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
    // await playerController.stopPlayer();
  }

  Future<void> seekPosition(int millisecond, {int? index}) async {
    if(index != null) {
      await _audioPlayer.seek(Duration(milliseconds: millisecond), index: index);
      return;
    }
    await _audioPlayer.seek(Duration(milliseconds: millisecond));
  }

  Future<void> fastFroward(Duration duration) async {
    final currentPosition = _audioPlayer.position;
    final length = _audioPlayer.duration ?? Duration.zero;

    // Calculate the new position
    Duration newPosition = currentPosition + duration;

    // Ensure we don't go past the duration
    if (newPosition > length) {
      newPosition = length;
    }

    // Seek to the new position
    await _audioPlayer.seek(newPosition);
  }

  Future<void> rewind(Duration duration) async {
    final currentPosition = _audioPlayer.position;

    // Calculate the new position by subtracting the rewind interval
    Duration newPosition = currentPosition - duration;

    // Ensure we don't go before the start of the audio (position < 0)
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }

    // Seek to the new position
    await _audioPlayer.seek(newPosition);
  }
}
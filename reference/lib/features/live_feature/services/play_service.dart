import 'dart:async';

import 'package:just_audio/just_audio.dart';

class PlayService {
  final AudioPlayer _audioPlayer;
  StreamSubscription<Duration>? positionStreamSub;
  StreamSubscription<PlayerState>? stateStreamSub;
  Duration _currentPosition = Duration.zero;


  PlayService(this._audioPlayer);

  void dispose() {
    _audioPlayer.dispose();
    positionStreamSub?.cancel();
    stateStreamSub?.cancel();
  }

  Future<void> playAudio() async {
    await _audioPlayer.play();
  }

  Future<Duration?> setAudio(String url) async {
    return await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
  }

  bool isPlaying() {
    return _audioPlayer.playing;
  }

  Future<Duration?> prepareUrlAudio(String url, Function onCursorChange, Function onComplete, Function onIsPlayingChange) async {
    Duration? duration = await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));

    if(positionStreamSub != null) {
      await positionStreamSub!.cancel();
      positionStreamSub = null;
    }
    positionStreamSub = _audioPlayer.createPositionStream(minPeriod: const Duration(milliseconds: 16), maxPeriod: const Duration(milliseconds: 20)).listen((duration) async {
      _currentPosition = duration;
      onCursorChange(duration);
    });

    if(stateStreamSub != null) {
      await stateStreamSub!.cancel();
      stateStreamSub = null;
    }

    stateStreamSub = _audioPlayer.playerStateStream.listen((playerState) {
      // 播放 / 暫停
      onIsPlayingChange(playerState.playing);

      // 播放完成
      if (playerState.processingState == ProcessingState.completed) {
        onComplete();
      }
    });

    return duration;
  }

  Future<void> changeAudio(String url) async {
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
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

  Future<void> setSpeed(double speed) async {
    _audioPlayer.setSpeed(speed);
  }

  double getSpeed() {
    return _audioPlayer.speed;
  }

  Duration getCurrentPosition() {
    return _currentPosition;
  }
}

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/noise_providers.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../services/play_service.dart';

class NoisePreviewPlayerController {
  WidgetRef _ref;
  final PlayService _player = PlayService(AudioPlayer());
  String? audioFilePath;

  NoisePreviewPlayerController(this._ref);

  void dispose() {
    if(audioFilePath != null) {
      final audioFile = File(audioFilePath!);
      audioFile.delete();
    }
    _player.dispose();
  }

  Future<void> preparePlayer(String filePath) async {
    audioFilePath = filePath;
    Duration? audioLength = await AudioUtils.getAudioFileLength(filePath);
    _ref.watch(noisePreviewPlayerLengthProvider.notifier).state = audioLength!;
    await _player.prepareFileAudio(filePath, onCursorChange, onComplete);
  }

  Future<void> playPause() async {
    if(_ref.watch(noisePreviewPlayerStatusProvider) == "playing") {
      _player.pauseAudio();
      _ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
    } else {
      _player.playAudio();
      _ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "playing";
    }
  }

  Future<void> pause() async {
    _player.pauseAudio();
    _ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
  }

  Future<void> onCursorChange(Duration duration) async {
    _ref.watch(noisePreviewPlayerDurationProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {
    await _player.seekPosition(0);
    _player.pauseAudio();
    _ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
  }

  Future<void> seek(Duration duration) async {
    await _player.seekPosition(duration.inMilliseconds);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

import '../services/play_service.dart';

class MusicPlayerController {
  WidgetRef _ref;
  final PlayService _musicPlayerService = PlayService(AudioPlayer());

  MusicPlayerController(this._ref);

  void dispose() {
    _musicPlayerService.dispose();
  }

  Future<void> playMusic(String url) async {
    await _musicPlayerService.prepareUrlAudio(url, onCursorChange, onComplete);
    _ref.watch(musicPlayingUrlProvider.notifier).state = url;
    _ref.watch(musicPlayerStatusProvider.notifier).state = "playing";
    _musicPlayerService.playAudio();
  }

  Future<void> pauseMusic() async {
    await _musicPlayerService.pauseAudio();
    _ref.watch(musicPlayerStatusProvider.notifier).state = "paused";
  }

  Future<void> restartMusic() async {
    _musicPlayerService.playAudio();
    _ref.watch(musicPlayerStatusProvider.notifier).state = "playing";
  }

  Future<void> onCursorChange(Duration duration) async {
    _ref.watch(musicPlayerDurationProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {
    await _musicPlayerService.seekPosition(0);
    await _musicPlayerService.pauseAudio();
    _ref.watch(musicPlayerStatusProvider.notifier).state = "paused";
  }
}
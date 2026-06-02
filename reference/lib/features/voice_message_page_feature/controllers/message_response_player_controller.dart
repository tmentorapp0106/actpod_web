import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/voice_message_page_feature/providers.dart';

import '../service/play_service.dart';

class MessageResponsePlayerController {
  WidgetRef _ref;
  final PlayService playerService = PlayService(AudioPlayer());

  MessageResponsePlayerController(this._ref);

  void dispose() {
    playerService.dispose();
  }

  Future<void> preparePlayer() async {
    await playerService.preparePlayer(onCursorChange, onComplete);
  }

  void onCursorChange(Duration duration) {
    _ref.watch(messagePlayerProgressProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {
    await seekPosition(Duration.zero);
    _ref.watch(focusAudioIdProvider.notifier).state = null;
    pause();
  }

  Future<void> playAudio(String url, String audioId) async {
    _ref.watch(focusAudioIdProvider.notifier).state = audioId;
    _ref.watch(messagePlayerStatusProvider.notifier).state = "loading";
    await playerService.setAudio(url);
    _ref.watch(messagePlayerStatusProvider.notifier).state = "playing";
    playerService.playAudio();
  }

  Future<void> resume() async {
    _ref.watch(messagePlayerStatusProvider.notifier).state = "playing";
    await playerService.playAudio();
  }

  Future<void> pause() async {
    _ref.watch(messagePlayerStatusProvider.notifier).state = "pause";
    await playerService.pauseAudio();
  }

  Future<void> stop() async {
    await playerService.stopAudio();
    _ref.watch(messagePlayerStatusProvider.notifier).state = "pause";
  }

  Future<void> seekPosition(Duration position) async {
    await playerService.seekPosition(position.inMilliseconds);
  }
}
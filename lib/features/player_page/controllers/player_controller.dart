import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/api_manager/story_dto/listen_story_res.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/services/play_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';


class PlayerController {
  WidgetRef _ref;
  final PlayService _playService = PlayService(AudioPlayer());

  PlayerController(this._ref);

  Future<void> getStoryInfo(String storyId) async {
    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
        return;
    }
    _ref.watch(storyInfoProvider.notifier).state = response.story;
    if(response.story != null) {
      Duration? length = await _playService.prepareUrlAudio(
        response.story!.storyUrl, 
        onCursorChange, 
        onComplete,
        onReady,
        onPaused,
        onPlaying
      );
      if(length != null) {
        _ref.watch(audioLengthProvider.notifier).state = length;
      }
    }
  }

  Future<void> onReady() async {
    _ref.watch(playerStatusProvider.notifier).state = "ready";
    GetOneStoryResItem? storyInfo = _ref.watch(storyInfoProvider);
    if(storyInfo == null) {
      return;
    }

    ListenStoryRes response = await storyApiManager.listenStory(storyInfo.storyId, Uuid().v4());
  }

  void onPaused() {
    _ref.watch(playerStatusProvider.notifier).state = "paused";
  }

  void onPlaying() {
    _ref.watch(playerStatusProvider.notifier).state = "playing";
  }

  Future<void> onCursorChange(Duration duration) async {
    _ref.watch(audioPositionProvider.notifier).state = duration;
  }

  void onComplete() {
    _playService.pauseAudio();
  }

  Future<void> setSpeed(double speed) async {
    await _playService.setSpeed(speed);
  }

  Future<void> backward(Duration duration) async {
    await _playService.backward(duration);
  }

  Future<void> forward(Duration duration) async {
    await _playService.forward(duration);
  }

  Future<void> seekPosition(Duration duration) async {
    await _playService.seekPosition(duration.inMilliseconds);
  }

  Future<void> play() async {
    if(_ref.watch(playerStatusProvider) == "preparing") {
      return;
    }
    await _playService.playAudio();
  }

  Future<void> pause() async {
    await _playService.pauseAudio();
  }
}
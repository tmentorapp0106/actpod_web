import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/play_service.dart';

class PlayerController {
  WidgetRef ref;
  PlayService playService;

  PlayerController(this.ref, this.playService);

  Future<void> initPlayer(String storyId) async {
    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(storyInfoProvider.notifier).state = response.story;
    playService.prepareUrlAudio(response.story?.storyUrl?? "", onCursorChange, onComplete, onIsPlayingChange);
  }

  Future<void> onCursorChange(Duration duration) async {
    ref.watch(currentPositionProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {

  }

  void onIsPlayingChange(bool isPlaying) {
    ref.watch(isPlayingPodcastProvider.notifier).state = isPlaying;
  }

  Duration getCurrentPosition() {
    return playService.getCurrentPosition();
  }

  void dispose() {
    playService.dispose();
  }
}
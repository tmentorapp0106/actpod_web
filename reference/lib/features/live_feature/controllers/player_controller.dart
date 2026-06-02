import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/services/remote_config_service.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../main.dart';
import '../../../providers.dart';
import '../../../services/player_service.dart';

class PlayerController {
  WidgetRef ref;
  bool playerInitialed = false;

  PlayerController(this.ref);

  Future<void> initPlayer(String storyId) async {
    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(storyInfoProvider.notifier).state = response.story;
    await actPodAudioHandler?.pause();
    ref.watch(mainPlayerStoryInfoProvider.notifier).state = null;
    ref.watch(mainPlayerItemListProvider.notifier).state = [];
    ref.watch(loadingPlayerStoryInfoProvider.notifier).state = null;
    await playerService.setStreaming(onCursorChange, onComplete, onAudioInfoChange, onIsPlayingPodcastChange, (position){});
    ref.watch(loadingPlayerStoryInfoProvider.notifier).state = null;
  }

  Future<void> onCursorChange(Duration duration) async {
    if(!ref.context.mounted) return;
    if(actPodAudioHandler?.getCurrentMediaItemId() == ref.read(storyInfoProvider)?.storyId) {
      if(duration < Duration(milliseconds: 100)) return; // 換歌曲會回到原點，所以 skip
      if(ref.watch(podcastPlayerStatusProvider) == PodcastPlayerStatus.playing) {
        ref.watch(currentPositionProvider.notifier).state = duration;
      }
    }
  }

  Future<void> onComplete() async {

  }

  Future<void> onAudioInfoChange(String storyId) async {
  }

  void onIsPlayingPodcastChange(bool isPlaying) {
    if(!ref.context.mounted) return;
    if(actPodAudioHandler?.getCurrentMediaItemId() == ref.read(storyInfoProvider)?.storyId) {
      ref.watch(podcastPlayerStatusProvider.notifier).state = isPlaying? PodcastPlayerStatus.playing : PodcastPlayerStatus.paused;
    } else {
      ref.watch(podcastPlayerStatusProvider.notifier).state = PodcastPlayerStatus.paused;
    }
  }

  Duration getCurrentPosition() {
    return actPodAudioHandler?.getCurrentDuration()?? Duration.zero;
  }

  void dispose() {
    actPodAudioHandler?.pause();
  }
}
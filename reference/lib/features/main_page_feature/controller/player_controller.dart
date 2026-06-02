import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

import '../../../main.dart';

class PlayerController {
  WidgetRef _ref;

  PlayerController(this._ref);

  void initStreaming() {
    actPodAudioHandler?.mediaItem.listen((mediaItem) {
      _ref.watch(mainPlayerLengthProvider.notifier).state = mediaItem?.duration?? Duration.zero;
      _ref.watch(isPlayingInteractiveContentProvider.notifier).state = mediaItem?.extras?["isVoiceMessage"]?? false;
      List<PlayerItemDto> playerItemDtoList = _ref.watch(mainPlayerItemListProvider);
      if(playerItemDtoList.isEmpty) {
        return;
      }
      if(_ref.watch(loadingPlayerStoryInfoProvider) != null) {
        _ref.watch(mainPlayerStoryInfoProvider.notifier).state = _ref.watch(loadingPlayerStoryInfoProvider);
      } else {
        if(playerItemDtoList.where((dto) => dto.storyId == mediaItem?.id).isEmpty) {
          return;
        }
        PlayerItemDto playerItemDto = playerItemDtoList.where((dto) => dto.storyId == mediaItem?.id).first;
        _ref.watch(mainPlayerStoryInfoProvider.notifier).state = playerItemDto;
      }
    });

    AudioService.position.listen((position) {
      _ref.watch(mainPlayerPositionProvider.notifier).state = position;
    });

    actPodAudioHandler?.playbackState.listen((PlaybackState state) {
      if(state.playing && state.processingState == AudioProcessingState.buffering) {
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.loading;
      } else if (state.processingState == AudioProcessingState.completed) {
        actPodAudioHandler?.pause();
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.paused;
      } else if (state.playing) {
        _ref.watch(loadingPlayerStoryInfoProvider.notifier).state = null;
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.playing;
      } else if(state.processingState == AudioProcessingState.loading || state.processingState == AudioProcessingState.idle) {
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.initiating;
      } else if(state.processingState == AudioProcessingState.buffering) {
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.loading;
      } else {
        _ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.paused;
      }
    });
  }

}
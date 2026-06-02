import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/signed_url_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_interactive_content_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/login_feature/login_screen.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/likes_controller.dart';
import 'package:quick_share_app/services/player_service.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/services/user_service.dart';
import '../../../dto/interactive_content_dto.dart';
import '../../../providers.dart';
import '../../send_voice_message_feature/send_voice_message_screen.dart';
import '../providers.dart';
import 'comment_controller.dart';

class PlayerController {
  WidgetRef ref;
  LikesController likesController;
  CommentController commentController;
  BuildContext dialogContext;
  bool isEnded = false;
  PlayerItemDto storyInfo;
  bool alreadyOpenRecorder = false;

  PlayerController(this.ref, this.commentController, this.likesController, this.dialogContext, this.storyInfo);

  void initVoiceMessageStatus(int? initialIndex, bool isNewItem) {
    if(isNewItem) {
      ref.watch(voiceMessageStatusProvider.notifier).state = storyInfo.voiceMessageStatus == "enable"? true : false;
    } else {
      ref.watch(voiceMessageStatusProvider.notifier).state = storyInfo.voiceMessageStatus == "enable"? true : false;
    }
  }

  Future<void> getInteractiveContent() async {
    GetInteractiveContentRes response = await voiceMessageApiManager.getInteractiveContent(storyInfo.storyId);
    if(response.code != "0000") {
      return;
    }
    List<InteractiveMessageInfoDto>? messageInfoList = response.data!.exist? response.data!.interactiveContentDto!.messageInfoList : [];
    ref.watch(interactiveMessageInfoListProvider.notifier).state = messageInfoList;

    final position = ref.read(mainPlayerPositionProvider);
    if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId && ref.read(isPlayingInteractiveContentProvider)) {
      for(int i = 0; i < messageInfoList.length; i++) {
        if(messageInfoList[i].fromMilliSec <= position.inMilliseconds && position.inMilliseconds <= messageInfoList[i].toMilliSec) {
          ref.watch(interactiveMessageInfoIndexProvider.notifier).state = i;
          break;
        }
      }
    }
  }

  Future<void> initStream(String storyId) async {
    likesController.getCount(storyId);
    likesController.checkExist(storyId);
    playerService.setStreaming(
      positionChangeFunction,
      (){},
      audioInfoChangeFunction,
      (state){},
      setInitPosition
    );
  }

  Future<void> positionChangeFunction(Duration position) async {
    if(actPodAudioHandler?.mediaItem.value?.id == storyInfo.storyId && ref.read(isPlayingInteractiveContentProvider)) {
      final messageInfoList = ref.watch(interactiveMessageInfoListProvider);
      if(messageInfoList == null) {
        return;
      }

      for(int i = 0; i < messageInfoList.length; i++) {
        if(position.inMilliseconds >= messageInfoList[i].fromMilliSec && position.inMilliseconds < messageInfoList[i].toMilliSec) {
          ref.watch(interactiveMessageInfoIndexProvider.notifier).state = i;
          break;
        }
      }
    }
  }

  void setInitPosition(Duration duration) {
    ref.watch(mainPlayerPositionProvider.notifier).state = duration;
  }

  Future<void> audioInfoChangeFunction(String? storyId) async {
    if(storyId == null) {
      return;
    }
    likesController.getCount(storyId);
    likesController.checkExist(storyId);
    isEnded = false;
    ref.watch(showShareLinkProvider.notifier).state = storyInfo.review == null? true : (storyInfo.review!.status == "reject"? false : true);
    ref.watch(voiceMessageStatusProvider.notifier).state = storyInfo.voiceMessageStatus == "enable"? true : false;
  }

  Future<void> onCompleteFunction() async {
    isEnded = true;
    if(actPodAudioHandler == null || actPodAudioHandler?.mediaItem.value == null) {
      return;
    }
  }

  Future<void> initNewStat(PlayerItemDto storyInfo) async {
    likesController.getCount(storyInfo.storyId);
    likesController.checkExist(storyInfo.storyId);
    ref.watch(showShareLinkProvider.notifier).state = storyInfo.review == null? true : (storyInfo.review!.status == "reject"? false : true);
  }

  Future<void> checkPaid(PlayerItemDto storyInfo) async {
    if(!UserService.hasLoggedIn()) {
      ref.watch(premiumStatusProvider.notifier).state = PremiumStatus.unpaid;
      return;
    }

    SignedUrlRes signedRes = await storyApiManager.signedUrl(storyInfo.storyId);
    if(signedRes.code == "0006") {
      ref.watch(premiumStatusProvider.notifier).state = PremiumStatus.unpaid;
      return;
    }
    if(signedRes.code != "0000") {
      ref.watch(premiumStatusProvider.notifier).state = PremiumStatus.unpaid;
      return;
    }
    storyInfo.storyUrl = signedRes.url?? "";
    ref.watch(premiumStatusProvider.notifier).state = PremiumStatus.paid;
  }

  Future<void> initNewPlayItemList(PlayerItemDto storyInfo, bool autoPlay) async {
    await actPodAudioHandler?.stop();
    ref.watch(mainPlayerStoryInfoProvider.notifier).state = storyInfo;
    ref.watch(mainPlayerItemListProvider.notifier).state = [storyInfo];
    ref.watch(loadingPlayerStoryInfoProvider.notifier).state = storyInfo;
    ref.watch(mainPlayerStatusProvider.notifier).state = MainPlayerState.loading;
    await playerService.setStreaming(positionChangeFunction, onCompleteFunction, audioInfoChangeFunction, (playing) {}, (position){});
    playerService.changeMusicByUrl(
        id: storyInfo.storyId,
        title: storyInfo.storyName,
        url: storyInfo.storyUrl,
        album: storyInfo.channelName,
        artist: storyInfo.storyDescription,
        showSeekControls: true,
        artUrl: storyInfo.storyImageUrls[0],
        repeatMode: AudioServiceRepeatMode.none,
        captureVoiceMessages: true,
        storyOwnerId: storyInfo.userId,
        voiceMessageStatus: storyInfo.voiceMessageStatus
    );
    // await playerService.setAudio([storyInfo], initIndex,
    // () async {
    //   if(autoPlay) {
    //     actPodAudioHandler?.play();
    //   } else {
    //     actPodAudioHandler?.pause();
    //   }
    // },
    // (state){},
    // positionChangeFunction,
    // (bufferPosition) {
    //   if(bufferPosition == null) {
    //     return;
    //   }
    //   ref.watch(mainPlayerBufferPositionProvider.notifier).state = bufferPosition;
    // },
    // audioInfoChangeFunction,
    // onCompleteFunction);
    ref.watch(loadingPlayerStoryInfoProvider.notifier).state = null;
  }

  Future<void> checkAndShowVoiceMessageDialog() async {
    if(!ref.watch(isForegroundProvider) && isEnded) {
      await actPodAudioHandler?.skipToNext();
      return;
    }

    if(alreadyOpenRecorder) {
      return;
    }

    if(!UserService.hasLoggedIn()) {
      showDialog(
          context: dialogContext,
          builder: (context) {
            return LoginPageScreen();
          }
      );
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: dialogContext,
      builder: (context) {
        return SendVoiceMessageScreen(dialogContext, storyInfo);
      }
    ).then((value) async {
      alreadyOpenRecorder = false;
    });
  }

  Duration getCurrentPosition() {
    return ref.watch(mainPlayerPositionProvider);
  }

  Future<void> seekAudioPosition(Duration position) async {
    isEnded = false;
    instantCommentWaitingQueue.clear();
    ref.watch(mainPlayerPositionProvider.notifier).state = position;
    playerService.seekPosition(position);
  }

  Future<void> fastForward() async {
    actPodAudioHandler?.fastForward(); // audio service's config: 15s
  }

  Future<void> rewind() async {
    actPodAudioHandler?.rewind(); // audio service's config: 15s
  }

  Future<void> setSpeed(double speed) async {
    playerService.setSpeed(speed);
  }

  void cancelStreamingFunction() {
    playerService.setStreaming(
        (position) {},
        (){},
        (storyId) {},
        (state){},
        (position){}
    );
  }
}
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/listen_story_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/utils/device_utils.dart';

import '../apiManagers/voice_message_api_dto/get_interactive_content_res.dart';
import '../utils/audio_fix_utils.dart';


PlayerService playerService = PlayerService();
class PlayerService {
  StreamSubscription? positionStream;
  StreamSubscription? mediaItemStream;
  StreamSubscription? playBackStream;
  String? lastCalledCompleteFunctionId = "";
  String? lastMediaItemId = "";
  String? currentMediaItemId = ""; // avoid overfire ready function
  bool hasReached20Sec = false;
  bool finishInit = false;

  Future<void> setAudio(List<PlayerItemDto> playItemList, int initialIndex, Function audioReadyFunction, Function playStatusChangeFunction, Function audioPositionChangeFunction,
      Function audioBufferPositionChangeFunction, Function audioInfoChangeFunction,
      Function onCompleteFunction) async {

    List<MediaItem> mediaItemList = [];
    hasReached20Sec = false;
    for (var playerItem in playItemList) {
      String artUrl = playerItem.storyImageUrls[0];
      mediaItemList.add(
        MediaItem(
          id: playerItem.storyId,
          album: playerItem.userName,
          title: playerItem.storyName,
          artist: playerItem.storyDescription,
          artUri: Uri.parse(artUrl),
          extras: {
            "storyOwnerId": playerItem.userId,
            "voiceMessageStatus": playerItem.voiceMessageStatus,
            "url": playerItem.storyUrl,
            "isVoiceMessage": false
          }
        )
      );
      GetInteractiveContentRes interactiveContentRes = await voiceMessageApiManager.getInteractiveContent(playerItem.storyId);
      if(interactiveContentRes.code != "0000" || !interactiveContentRes.data!.exist) {
        continue;
      }
      mediaItemList.add(
        MediaItem(
          id: playerItem.storyId,
          album: playerItem.userName,
          title: "${playerItem.storyName} (互動)",
          artist: playerItem.storyDescription,
          artUri: Uri.parse(artUrl),
          extras: {
            "storyOwnerId": playerItem.userId,
            "voiceMessageStatus": playerItem.voiceMessageStatus,
            "url": interactiveContentRes.data!.interactiveContentDto!.url,
            "isVoiceMessage": true
          }
        )
      );
    }

    actPodAudioHandler?.setShowSeekControls(true);
    await actPodAudioHandler?.replaceQueueAndPlay(
      mediaItems: mediaItemList,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
      autoPlay: true,
      repeatMode: AudioServiceRepeatMode.none,
    );

    if(positionStream != null) {
      await positionStream!.cancel();
      positionStream = null;
    }
    positionStream = AudioService.position.listen((position) {
      if (!hasReached20Sec && position.inSeconds >= 20) {
        hasReached20Sec = true; // Set flag to true to prevent multiple calls
        _listenStory(actPodAudioHandler?.mediaItem.value?.id);
      }
      audioPositionChangeFunction(position);

      int? totalDurationMilliSecond = actPodAudioHandler?.mediaItem.value?.duration?.inMilliseconds;
      if(lastCalledCompleteFunctionId != actPodAudioHandler?.mediaItem.value?.id && totalDurationMilliSecond != null && position.inMilliseconds > totalDurationMilliSecond - 200) {
        lastCalledCompleteFunctionId = actPodAudioHandler?.mediaItem.value?.id; // prevent over fired
        onCompleteFunction();
      }
    });

    if(mediaItemStream != null) {
      await mediaItemStream!.cancel();
      mediaItemStream = null;
    }
    mediaItemStream = actPodAudioHandler?.mediaItem.listen((mediaItem) {
      lastCalledCompleteFunctionId = ""; // prevent over fired -> if info changed means already completed.
      if(lastMediaItemId != actPodAudioHandler?.mediaItem.value?.id) {
        hasReached20Sec = false;
        audioInfoChangeFunction(actPodAudioHandler?.mediaItem.value?.id);
        lastMediaItemId = actPodAudioHandler?.mediaItem.value?.id;
      }
    });

    if(playBackStream != null) {
      await playBackStream!.cancel();
      playBackStream = null;
    }
    playBackStream = actPodAudioHandler?.playbackState.listen((PlaybackState state) {
      playStatusChangeFunction(state.playing);

      if(state.playing) {
        return;
      } else {
        switch(state.processingState) {
          case AudioProcessingState.ready:
            if(currentMediaItemId != actPodAudioHandler?.mediaItem.value?.id) {
              print("ready...");
              currentMediaItemId = actPodAudioHandler?.mediaItem.value?.id;
              audioReadyFunction();
            }
            break;
          case AudioProcessingState.completed:
            print("completed...");
            break;
          case AudioProcessingState.idle:
            print("idle...");
            break;
          case AudioProcessingState.loading:
            print("loading...");
            break;
          case AudioProcessingState.buffering:
            print("buffering...");
            break;
          case AudioProcessingState.error:
            print("error!!");
            break;
        }
      }
    });
  }

  Future<void> setStreaming(Function audioPositionChangeFunction, Function onCompleteFunction, Function audioInfoChangeFunction, Function playStatusChangeFunction, Function setInitPosition) async {
    if(positionStream != null) {
      await positionStream!.cancel();
      positionStream = null;
    }
    positionStream = AudioService.position.listen((position) {
      if (!hasReached20Sec && position.inSeconds >= 20) {
        hasReached20Sec = true; // Set flag to true to prevent multiple calls
        _listenStory(actPodAudioHandler?.mediaItem.value?.id);
      }

      audioPositionChangeFunction(position);

      int? totalDurationMilliSecond = actPodAudioHandler?.mediaItem.value?.duration?.inMilliseconds;
      if(lastCalledCompleteFunctionId != actPodAudioHandler?.mediaItem.value?.id && totalDurationMilliSecond != null && position.inMilliseconds > totalDurationMilliSecond - 200) {
        lastCalledCompleteFunctionId = actPodAudioHandler?.mediaItem.value?.id; // prevent over fired
        onCompleteFunction();
      }
    });

    if(mediaItemStream != null) {
      await mediaItemStream!.cancel();
      mediaItemStream = null;
    }
    mediaItemStream = actPodAudioHandler?.mediaItem.listen((mediaItem) {
      lastCalledCompleteFunctionId = ""; // prevent over fired -> if info changed means already completed.
      if(lastMediaItemId != actPodAudioHandler?.mediaItem.value?.id) {
        audioInfoChangeFunction(actPodAudioHandler?.mediaItem.value?.id?? "");
        lastMediaItemId = actPodAudioHandler?.mediaItem.value?.id;
      }
    });

    if(playBackStream != null) {
      await playBackStream!.cancel();
      playBackStream = null;
    }
    playBackStream = actPodAudioHandler?.playbackState.listen((PlaybackState state) {
      playStatusChangeFunction(state.playing);
      final position = state.position;
      setInitPosition(position);

      if(state.playing) {
        return;
      } else {
        switch(state.processingState) {
          case AudioProcessingState.ready:
            print("ready...");
            break;
          case AudioProcessingState.completed:
            print("completed...");
            break;
          case AudioProcessingState.idle:
            print("idle...");
            break;
          case AudioProcessingState.loading:
            print("loading...");
            break;
          case AudioProcessingState.buffering:
            print("buffering...");
            break;
          case AudioProcessingState.error:
            print("error!!");
            break;
        }
      }
    });
  }

  Future<void> changeMusicByUrl({
    required String id,
    required String title,
    required String url,
    String? album,
    String? artist,
    String? artUrl,
    bool autoPlay = true,
    bool showSeekControls = false,
    AudioServiceRepeatMode repeatMode = AudioServiceRepeatMode.none,
    Duration initPosition = Duration.zero,
    bool captureVoiceMessages = false,
    String voiceMessageStatus = "",
    String storyOwnerId = ""
  }) async {
    final handler = actPodAudioHandler;
    if (handler == null) return;

    List<MediaItem> mediaItemList = [];
    final mediaItem = MediaItem(
      id: id,
      album: album,
      title: title,
      artist: artist,
      artUri: artUrl != null && artUrl.isNotEmpty ? Uri.parse(artUrl) : null,
      extras: {
        "url": url,
        "isVoiceMessage": false,
      },
    );
    mediaItemList.add(mediaItem);

    lastCalledCompleteFunctionId = "";
    lastMediaItemId = "";
    currentMediaItemId = "";
    hasReached20Sec = false;

    handler.setShowSeekControls(showSeekControls);

    if(captureVoiceMessages) {
      GetInteractiveContentRes interactiveContentRes = await voiceMessageApiManager.getInteractiveContent(id);
      if(interactiveContentRes.code == "0000" && interactiveContentRes.data!.exist) {
        mediaItemList.add(
            MediaItem(
              id: id,
              album: album,
              title: "$title(互動)",
              artist: artist,
              artUri: artUrl != null && artUrl.isNotEmpty ? Uri.parse(artUrl) : null,
              extras: {
                "storyOwnerId": storyOwnerId,
                "voiceMessageStatus": voiceMessageStatus,
                "url": interactiveContentRes.data!.interactiveContentDto!.url,
                "isVoiceMessage": true
              }
            )
        );
      }
    }

    await handler.replaceQueueAndPlay(
      mediaItems: mediaItemList,
      initialIndex: 0,
      initialPosition: initPosition,
      autoPlay: autoPlay,
      repeatMode: repeatMode
    );
  }

  Future<void> seekPosition(Duration position) async {
    lastCalledCompleteFunctionId = ""; // need to reset completed judgement
    actPodAudioHandler?.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    actPodAudioHandler?.setSpeed(speed);
  }

  Future<void> _listenStory(String? storyId) async {
    if(storyId == null || storyId.contains("https:/")) {
      return;
    }
    String deviceId = await DeviceUtils.getDeviceId();
    ListenStoryRes response = await storyApiManager.listenStory(storyId, deviceId);
    if(response.code != "0000") {
      print("listen story error: ${response.code}");
    }
  }

  void cancelStreaming() {
    positionStream?.cancel();
    positionStream = null;
    mediaItemStream?.cancel();
    mediaItemStream = null;
    playBackStream?.cancel();
    playBackStream = null;
  }
}
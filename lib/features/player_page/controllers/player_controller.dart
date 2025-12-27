import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/api_manager/story_dto/listen_story_res.dart';
import 'package:actpod_web/api_manager/story_dto/signed_url_res.dart';
import 'package:actpod_web/api_manager/voice_message_api_manager.dart';
import 'package:actpod_web/api_manager/voice_message_dto/get_interactive_content_res.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/play_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';


class PlayerController {
  WidgetRef _ref;
  final PlayService _playService = PlayService(AudioPlayer());

  PlayerController(this._ref);

  Future<void> getStoryInfo(String storyId) async {
    GetInteractiveContentRes interactiveContentResponse = await voiceMessageApiManager.getInteractiveContent(storyId);
    if(interactiveContentResponse.code != "0000") {
      ToastService.showNoticeToast(interactiveContentResponse.message);
      return;
    }
    _ref.watch(interactiveMessageInfoListProvider.notifier).state = interactiveContentResponse.data?.interactiveContentDto?.messageInfoList;
    _ref.watch(interactiveContentUrlProvider.notifier).state = interactiveContentResponse.data!.exist? interactiveContentResponse.data!.interactiveContentDto?.url : null;

    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
      print(response.code);
      return;
    }
    _ref.watch(storyInfoProvider.notifier).state = response.story;
    if(response.story != null) {
      if(response.story!.isPremium) {
        if(!AuthService.isLoggedIn()) {
          _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.unpaid;
          return;
        } else {
          checkPaid(storyId);
          return;
        }
      } else {
        await _playService.prepareUrlAudio(
          response.story!.storyUrl,
          interactiveContentResponse.data!.exist? interactiveContentResponse.data!.interactiveContentDto?.url : null,
          onCursorChange, 
          onComplete,
          onReady,
          onPaused,
          onPlaying,
          onIndexChange,
          onDurationChange
        );
      }
    }
  }

  Future<void> checkPaid(String storyId) async {
    _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.preparing;
    if(!AuthService.isLoggedIn()) {
      _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.unpaid;
      return;
    }

    SignedUrlRes signedRes = await storyApiManager.signedUrl(storyId);
    if(signedRes.code == "0006") {
      _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.unpaid;
      return;
    }
    if(signedRes.code != "0000") {
      _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.unpaid;
      return;
    }
    GetOneStoryResItem? story = _ref.watch(storyInfoProvider);
    story!.storyUrl = signedRes.url!;
    await _playService.prepareUrlAudio(
      signedRes.url!,
      _ref.watch(interactiveContentUrlProvider),
      onCursorChange, 
      onComplete,
      onReady,
      onPaused,
      onPlaying,
      onIndexChange,
      onDurationChange
    );
  }

  Future<void> onIndexChange(int? index) async {
    if(index == 1) {
      _ref.watch(playContentProvider.notifier).state = PlayContent.interactiveContent;
    } else {
      _ref.watch(playContentProvider.notifier).state = PlayContent.story;
    }
  }

  Future<void> onDurationChange(Duration? duration) async {
    if(duration != null) {
      _ref.watch(audioLengthProvider.notifier).state = duration;
    }
  }

  Future<void> onReady() async {
    _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.ready;
    GetOneStoryResItem? storyInfo = _ref.watch(storyInfoProvider);
    if(storyInfo == null) {
      return;
    }

    ListenStoryRes response = await storyApiManager.listenStory(storyInfo.storyId, Uuid().v4());
  }

  void onPaused() {
    _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.paused;
  }

  void onPlaying() {
    _ref.watch(playerStatusProvider.notifier).state = PlayerStatus.playing;
  }

  Future<void> onCursorChange(Duration duration) async {
    _ref.watch(audioPositionProvider.notifier).state = duration;
    final messageInfoList = _ref.watch(interactiveMessageInfoListProvider);
    if(messageInfoList == null) {
      return;
    }

    for(int i = 0; i < messageInfoList.length; i++) {
      if(duration.inMilliseconds >= messageInfoList[i].fromMilliSec && duration.inMilliseconds < messageInfoList[i].toMilliSec) {
        _ref.watch(interactiveMessageInfoIndexProvider.notifier).state = i;
        break;
      }
    }
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
    if(_ref.watch(playerStatusProvider) == PlayerStatus.preparing) {
      return;
    }
    await _playService.playAudio();
  }

  Future<void> pause() async {
    await _playService.pauseAudio();
  }

  Future<void> playIndex(int index) async {
    await _playService.playIndex(index);
  }
}
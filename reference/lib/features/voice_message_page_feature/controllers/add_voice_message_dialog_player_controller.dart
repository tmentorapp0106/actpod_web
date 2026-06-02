import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../providers.dart';
import '../service/play_service.dart';

class AddVoiceMessageDialogPlayerController {
  WidgetRef _ref;
  VoiceMessageDto voiceMessageDto;
  final PlayService playerService = PlayService(AudioPlayer());
  List<Duration> lengthList = [];

  AddVoiceMessageDialogPlayerController(this._ref, this.voiceMessageDto);

  Future<void> prepareVoiceMessage() async {
    _ref.watch(loadingProvider.notifier).state = true;
    List<AudioSource> audioList = [];
    List<String> audioUrlList = [];
    Duration audioLength = Duration.zero;
    audioUrlList.add(voiceMessageDto.url);
    audioList.add(AudioSource.uri(Uri.parse(voiceMessageDto.url)));
    lengthList.add(Duration(milliseconds: voiceMessageDto.length));
    audioLength += Duration(milliseconds: voiceMessageDto.length);

    for(ResponseDto responseDto in voiceMessageDto.responseList?? []) {
      audioUrlList.add(responseDto.url);
      audioList.add(AudioSource.uri(Uri.parse(responseDto.url)));
      lengthList.add(Duration(milliseconds: responseDto.length));
      audioLength += Duration(milliseconds: responseDto.length);
    }

    String resultPath;
    AudioUtils.concatRemoteAudios(
      audioUrlList,
      (filePath) {
        resultPath = filePath;
        playerService.prepareFileAudio(resultPath, onCursorChange, onComplete);
        _ref.watch(addVoiceMessageLengthProvider.notifier).state = audioLength;
        _ref.watch(loadingProvider.notifier).state = false;
      },
      () {
        print("concat failed");
        _ref.watch(loadingProvider.notifier).state = false;
      },
      () {
        print("processing");
      }
    );
  }

  void onCursorChange(Duration duration) {
    _ref.watch(addVoiceMessagePlayerProgressProvider.notifier).state = duration;
  }

  Future<void> onComplete() async {
    await playerService.seekPosition(0, index: 0);
    pause();
  }

  Future<void> play() async {
    _ref.watch(addVoiceMessagePlayerStatusProvider.notifier).state = "playing";
    playerService.playAudio();
  }

  Future<void> pause() async {
    _ref.watch(addVoiceMessagePlayerStatusProvider.notifier).state = "pause";
    await playerService.pauseAudio();
  }

  Future<void> seekPosition(Duration position) async {
    Duration accumulateLength = Duration.zero;
    for(int i = 0; i < lengthList.length; i++) {
      Duration lastAccumulateDuration = accumulateLength;
      accumulateLength += lengthList[i];
      if(accumulateLength.inMilliseconds > position.inMilliseconds) {
        await playerService.seekPosition(position.inMilliseconds - lastAccumulateDuration.inMilliseconds, index: i);
        return;
      }
    }
  }
}
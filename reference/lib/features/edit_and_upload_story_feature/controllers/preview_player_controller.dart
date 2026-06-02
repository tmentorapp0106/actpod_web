import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/const/const.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/preview_player_timer_controller.dart';

import '../../../dto/background_music_dto.dart';
import '../../../dto/story_dto.dart';
import '../../../utils/audio_utils.dart';
import '../../../dto/block_info_dto.dart';
import '../providers.dart';
import '../services/play_service.dart';

class PreviewPlayerController { // todo: add soundEffect into it
  WidgetRef _ref;
  final PreviewPlayerTimerController _previewPlayerTimerController;
  String? storyAudioPath;
  final PlayService _storyAudioPlayerService = PlayService(AudioPlayer());
  final PlayService _backgroundAudioPlayerService = PlayService(AudioPlayer());
  final PlayService _soundEffectPlayerService = PlayService(AudioPlayer());
  List<PlayService> _insertedSoundPlayerServices = [];
  String currentPlayingService = "story";
  bool soundEffectIsPlaying = false;
  bool backgroundIsPlaying = false;
  Duration _currentSoundEffectDuration = Duration.zero;
  Duration _currentBackgroundDuration = Duration.zero;

  PreviewPlayerController(this._ref, this._previewPlayerTimerController);

  void dispose() {
    _storyAudioPlayerService.dispose();
    _backgroundAudioPlayerService.dispose();
    _soundEffectPlayerService.dispose();
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].dispose();
    }
  }

  Future<void> prepareStory(String storyPath, {required bool isFromPickedFile}) async {
    storyAudioPath = storyPath;
    List<BackgroundMusicDto> selectedBackgrounds = _ref.watch(selectedBackgroundProvider);
    List<SoundEffectDto> selectedSoundEffects = _ref.watch(selectedSoundEffectDtoProvider);
    Duration? duration = await AudioUtils.getAudioFileLength(storyPath);
    _ref.watch(totalLengthProvider.notifier).state = duration?? Duration.zero;
    await _soundEffectPlayerService.prepareConcatenatingAudio(onSoundEffectCursorChange, onSoundEffectComplete);
    await _backgroundAudioPlayerService.prepareConcatenatingAudio(onBackgroundCursorChange, onBackgroundComplete);
    await _storyAudioPlayerService.prepareFileAudio(storyPath, onStoryCursorChange, onStoryComplete);

    if(isFromPickedFile) {
      _ref.watch(blockInfosProvider.notifier).state = [
        BlockInfoDto(
          from: Duration.zero,
          to: duration?? Duration.zero,
          position: Duration.zero,
          length: duration?? Duration.zero,
          soundIndex: 0,
          volume: 1,
          url: "",
          name: "",
          skip: Duration.zero,
          waveformData: [],
          type: "story",
          soundType: "",
        ),
      ];
    }

    for(int i = 0; i < selectedSoundEffects.length; i++) {
      await _soundEffectPlayerService.insertConcatenatingAudio(selectedSoundEffects[i].url, i);
    }
    for(int i = 0; i < selectedBackgrounds.length; i++) {
      await _backgroundAudioPlayerService.insertConcatenatingAudio(selectedBackgrounds[i].url, i);
    }
    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    for(BlockInfoDto blockInfoDto in blockInfoList) {
      if(blockInfoDto.type == "sound") {
        PlayService soundPlayService = PlayService(AudioPlayer(), soundIndex: blockInfoDto.soundIndex);
        await soundPlayService.prepareInsertedSoundAudio(blockInfoDto.url, onInsertAudioCursorChange, onInsertAudioComplete);
        _insertedSoundPlayerServices.add(soundPlayService);
        _previewPlayerTimerController.insertBlockPosition(0, Duration(milliseconds: 0));
      }
    }
  }

  Future<void> onStoryCursorChange(Duration duration) async {
    if(currentPlayingService == "sound" || _ref.watch(isSeekingProvider)) {
      return;
    }
    if(_previewPlayerTimerController.getCursor() + _ref.watch(extractedPreviewLengthProvider) > _ref.watch(totalLengthProvider) - Duration(milliseconds: changeGap)) {
      pauseAudio();
      return;
    }
    _previewPlayerTimerController.changeStoryTimer(duration);
    checkAndPlaySoundEffect();
    checkAndPlayBackground();

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _previewPlayerTimerController.getCursor();

    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(currentCursor > blockInfoList[i].to - Duration(milliseconds: changeGap)) {
          if(i == blockInfoList.length - 1){
            pauseAudio();
            return;
          }
          // 處理自然分割的情形（不用跳段落）-> 自然分割是為了 performance
          if(blockInfoList[i+1].type == "story" && blockInfoList[i].skip == Duration.zero) {
            return;
          }

          if(blockInfoList[i].type == "story") {
            if(blockInfoList[i+1].type == "sound") {
              await _storyAudioPlayerService.pauseAudio();
              await _storyAudioPlayerService.seekPosition((blockInfoList[i].position + blockInfoList[i].length).inMilliseconds); //手動調整到對的位置，不然其實前 50 millisec 就暫停了
              _previewPlayerTimerController.changeStoryPosition(blockInfoList[i].position + blockInfoList[i].length);
              // playedInsertedBlockIndex = blockInfoList[i+1].soundIndex;
              if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
                _insertedSoundPlayerServices[blockInfoList[i+1].soundIndex].playAudio();
              }
              currentPlayingService = "sound";
            } else if(blockInfoList[i+1].type == "story") {
              _previewPlayerTimerController.stopTrackingProgress();
              await _storyAudioPlayerService.seekPosition((blockInfoList[i+1].position).inMilliseconds);
              _previewPlayerTimerController.addSkipLength(i, blockInfoList[i].skip);
              _previewPlayerTimerController.startTrackingProgress();
            }
          }
        }
      }
    }
  }

  Future<void> onStoryComplete() async {
    _storyAudioPlayerService.pauseAudio();
    _backgroundAudioPlayerService.pauseAudio();
  }

  Future<void> onBackgroundCursorChange(Duration duration) async {
    if((_currentBackgroundDuration - duration).inMilliseconds < 50) { // since just_audio has bug that can't pause the playlist when changing index, so use this workaround method
      _backgroundAudioPlayerService.pauseAudio();
      backgroundIsPlaying = false;
    }
  }

  Future<void> onBackgroundComplete() async {
    _backgroundAudioPlayerService.pauseAudio();
    backgroundIsPlaying = false;
  }

  Future<void> onInsertAudioCursorChange(int soundIndex, Duration duration) async {
    if(currentPlayingService == "story" || _ref.watch(isSeekingProvider)) {
      return;
    }
    if(_previewPlayerTimerController.getCursor() + _ref.watch(extractedPreviewLengthProvider) > _ref.watch(totalLengthProvider) - const Duration(milliseconds: 50)) {
      pauseAudio();
      return;
    }
    _previewPlayerTimerController.changeBlockPosition(soundIndex, duration);
    checkAndPlaySoundEffect();
    checkAndPlayBackground();

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _previewPlayerTimerController.getCursor();
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(currentCursor > blockInfoList[i].to - Duration(milliseconds: changeGap)) {
          if(i == blockInfoList.length - 1){
            return;
          }

          if(blockInfoList[i].type == "sound") {
            if(blockInfoList[i + 1].type == "story") {
              _previewPlayerTimerController.stopTrackingProgress();
              _previewPlayerTimerController.addSkipLength(i, blockInfoList[i].skip);
              if(blockInfoList[i].skip != Duration.zero) {
                await _storyAudioPlayerService.seekPosition(blockInfoList[i+1].position.inMilliseconds);
              }
              _previewPlayerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
              _insertedSoundPlayerServices[soundIndex].pauseAudio();
              if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
                _storyAudioPlayerService.playAudio();
                currentPlayingService = "story";
              }
              _previewPlayerTimerController.startTrackingProgress();
            } else if(blockInfoList[i + 1].type == "sound") {
              await _insertedSoundPlayerServices[blockInfoList[i].soundIndex].pauseAudio();
              _previewPlayerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
              if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
                _insertedSoundPlayerServices[blockInfoList[i+1].soundIndex].playAudio();
                currentPlayingService = "sound";
              }
            }
          }
        }
      }
    }
  }

  Future<void> onInsertAudioComplete(int soundIndex) async {
    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _previewPlayerTimerController.getCursor();
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(blockInfoList[i].type == "sound") {
          if(blockInfoList[i + 1].type == "story") {
            _previewPlayerTimerController.stopTrackingProgress();
            _previewPlayerTimerController.addSkipLength(i, blockInfoList[i].skip);
            if(blockInfoList[i].skip != Duration.zero) {
              await _storyAudioPlayerService.seekPosition(blockInfoList[i+1].position.inMilliseconds);
            }
            _previewPlayerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
            _insertedSoundPlayerServices[soundIndex].pauseAudio();
            if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
              _storyAudioPlayerService.playAudio();
              currentPlayingService = "story";
            }
            _previewPlayerTimerController.startTrackingProgress();
          } else if(blockInfoList[i + 1].type == "sound") {
            _previewPlayerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
            await _insertedSoundPlayerServices[blockInfoList[i].soundIndex].pauseAudio();
            if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
              _insertedSoundPlayerServices[blockInfoList[i+1].soundIndex].playAudio();
              currentPlayingService = "sound";
            }
          }
        }
      }
    }
  }

  Future<void> onSoundEffectCursorChange(Duration duration) async {
    if((_currentSoundEffectDuration - duration).inMilliseconds < 50) { // since just_audio has bug that can't pause the playlist when changing index, so use this workaround method
      _soundEffectPlayerService.pauseAudio();
      soundEffectIsPlaying = false;
    }
  }

  Future<void> onSoundEffectComplete() async {
    _soundEffectPlayerService.pauseAudio();
    soundEffectIsPlaying = false;
  }

  Future<void> playAudio() async {
    if(_ref.watch(isSeekingProvider) || _ref.watch(isScrollingProvider)) {
      return;
    }

    _previewPlayerTimerController.startTrackingProgress();
    _ref.watch(previewStoryPlayerStatusProvider.notifier).state = "playing";
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _previewPlayerTimerController.getCursor();
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(blockInfoList[i].type == "story") {
          currentPlayingService = "story";
          _storyAudioPlayerService.playAudio();
        } else if(blockInfoList[i].type == "sound") {
          currentPlayingService = "sound";
          _insertedSoundPlayerServices[blockInfoList[i].soundIndex].playAudio();
        }
        break;
      }
    }
  }

  Future<void> pauseAudio() async {
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;
    _ref.watch(previewStoryPlayerStatusProvider.notifier).state = "pausing";
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].pauseAudio();
    }
    await _storyAudioPlayerService.pauseAudio();
    await _backgroundAudioPlayerService.pauseAudio();
    await _soundEffectPlayerService.pauseAudio();
  }

  Future<void> seekPosition(int seekDuration,  {bool track = true, bool stopTrackFirst = false}) async {
    if(seekDuration < 0) {
      seekDuration = 0;
    }
    if(seekDuration > _ref.watch(totalLengthProvider).inMilliseconds - 100) {
      seekDuration = _ref.watch(totalLengthProvider).inMilliseconds - 100;
    }

    // disable audio bar's scrolling when seeking
    _ref.watch(isSeekingProvider.notifier).state = true;
    _previewPlayerTimerController.setAllTrackPositionsToZero();
    _previewPlayerTimerController.changeStoryTimer(Duration(milliseconds: 0));
    await _storyAudioPlayerService.seekPosition(0);
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      await _insertedSoundPlayerServices[i].seekPosition(0);
      await _insertedSoundPlayerServices[i].pauseAudio();
    }

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    // 開頭被裁切的情形
    if(seekDuration == 0 && blockInfoList[0].type == "story") {
      _previewPlayerTimerController.skipLength = blockInfoList[0].position;
      await _storyAudioPlayerService.seekPosition(blockInfoList[0].position.inMilliseconds);
      _previewPlayerTimerController.changeStoryTimer(blockInfoList[0].position);
      _ref.watch(isSeekingProvider.notifier).state = false;
      if(!track) {
        _previewPlayerTimerController.changeTimer();
      } else {
        _previewPlayerTimerController.startTrackingProgress();
      }
      return;
    }

    // 添加開頭 padding
    if(blockInfoList[0].type == "story") {
      _previewPlayerTimerController.addSkipLength(0, blockInfoList[0].position);
    }
    Duration? lastStoryBlockPosition = null;
    for(int i = 0; i < blockInfoList.length; i++) {
      // 已經過去的 block
      if(blockInfoList[i].to.inMilliseconds <= seekDuration) {
        if(blockInfoList[i].type == "story") {
          lastStoryBlockPosition = blockInfoList[i].position + blockInfoList[i].length; // 不要每次都 seek 以提升效能
          _previewPlayerTimerController.changeStoryPosition(blockInfoList[i].position + blockInfoList[i].length);
          _previewPlayerTimerController.addSkipLength(i, blockInfoList[i].skip);
        } else if(blockInfoList[i].type == "sound") {
          _previewPlayerTimerController.changeBlockPosition(blockInfoList[i].soundIndex, blockInfoList[i].length);
          _previewPlayerTimerController.addSkipLength(i, blockInfoList[i].skip);
        }
        // 正在播放的 block
      } else if(blockInfoList[i].from.inMilliseconds <= seekDuration && blockInfoList[i].to.inMilliseconds > seekDuration) {
        if (blockInfoList[i].type == "story") {
          currentPlayingService = "story";
          await _storyAudioPlayerService.seekPosition(
              (blockInfoList[i].position +
                  Duration(milliseconds: seekDuration) - blockInfoList[i].from)
                  .inMilliseconds);
          lastStoryBlockPosition = null;
          _previewPlayerTimerController.changeStoryPosition(
              blockInfoList[i].position + Duration(milliseconds: seekDuration) -
                  blockInfoList[i].from);
        } else if (blockInfoList[i].type == "sound") {
          currentPlayingService = "sound";
          await _insertedSoundPlayerServices[blockInfoList[i].soundIndex]
              .seekPosition(
              (Duration(milliseconds: seekDuration) - blockInfoList[i].from)
                  .inMilliseconds);
          _previewPlayerTimerController.changeBlockPosition(
              blockInfoList[i].soundIndex,
              Duration(milliseconds: seekDuration) - blockInfoList[i].from);
        }
      }
    }
    if(lastStoryBlockPosition != null) {
      await _storyAudioPlayerService.seekPosition(lastStoryBlockPosition.inMilliseconds);
    }

    _ref.watch(isSeekingProvider.notifier).state = false;
    if(!track) {
      _previewPlayerTimerController.changeTimer();
    } else {
      _previewPlayerTimerController.startTrackingProgress();
    }
  }

  Future<void> checkAndPlaySoundEffect() async {
    final soundEffectList = _ref.watch(selectedSoundEffectDtoProvider);
    if(soundEffectIsPlaying) {
      return;
    }

    for(int i = 0; i < soundEffectList.length; i++) {
      Duration position = _previewPlayerTimerController.getCursor();
      if(soundEffectList[i].checkReached(position)) {
        soundEffectIsPlaying = true;
        _currentSoundEffectDuration = soundEffectList[i].getDuration();
        await _soundEffectPlayerService.seekPosition(_previewPlayerTimerController.getCursor().inMilliseconds - soundEffectList[i].startMilliSec, index: i);
        if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
          _soundEffectPlayerService.playAudio();
        }
        return;
      } else {
        soundEffectIsPlaying = false;
        _soundEffectPlayerService.pauseAudio();
      }
    }
  }

  Future<void> checkAndPlayBackground() async {
    final backgroundList = _ref.watch(selectedBackgroundProvider);
    if(backgroundIsPlaying) {
      return;
    }

    for(int i = 0; i < backgroundList.length; i++) {
      Duration position = _previewPlayerTimerController.getCursor();
      if(backgroundList[i].checkReached(position)) {
        backgroundIsPlaying = true;
        _currentBackgroundDuration = backgroundList[i].getDuration();
        await _backgroundAudioPlayerService.seekPosition(_previewPlayerTimerController.getCursor().inMilliseconds - backgroundList[i].startMilliSec, index: i);
        if(_ref.watch(previewStoryPlayerStatusProvider) == "playing") {
          _backgroundAudioPlayerService.playAudio();
        }
        return;
      } else {
        backgroundIsPlaying = false;
        _backgroundAudioPlayerService.pauseAudio();
      }
    }
  }
}
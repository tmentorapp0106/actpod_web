import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/find_audios_res.dart';
import 'package:quick_share_app/dto/sound_effect_list_item_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../dto/background_music_dto.dart';
import '../../../dto/story_dto.dart';
import '../../../utils/audio_utils.dart';
import '../const/const.dart';
import '../providers.dart';
import '../services/play_service.dart';

class EditTrimPlayController {
  final WidgetRef _ref;
  int? originAudioLength;
  String? originWavFilePath;
  String? normalizedWavFilePath;
  final PlayService _storyAudioPlayerService = PlayService(AudioPlayer());
  final PlayService _backgroundMusicPlayerService = PlayService(AudioPlayer());
  final PlayService _soundEffectPlayerService = PlayService(AudioPlayer());
  List<PlayService> _insertedSoundPlayerServices = [];
  List<Map<Duration, List<BlockInfoDto>>> _cutStack = [];
  final EditTrimPlayerTimerController _playerTimerController;
  String currentPlayingService = "story";
  bool soundEffectIsPlaying = false;
  Duration _currentSoundEffectDuration = Duration.zero;
  bool backgroundIsPlaying = false;
  Duration _currentBackgroundDuration = Duration.zero;



  EditTrimPlayController(this._ref, this._playerTimerController);

  Future<void> dispose() async {
    _storyAudioPlayerService.dispose();
    _backgroundMusicPlayerService.dispose();
    _soundEffectPlayerService.dispose();
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].dispose();
    }
  }

  void clearInsertSoundPlayer() {
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].dispose();
    }
    _insertedSoundPlayerServices = [];
  }

  Future<void> changeAudioPath(String filePath) async {
    await _storyAudioPlayerService.prepareFileAudio(filePath, onStoryCursorChange, onStoryComplete);
    try{
      if(normalizedWavFilePath != null) {
        await File(normalizedWavFilePath!).delete();
      }
    } catch(e) {
      print(e);
    }
    normalizedWavFilePath = filePath;
    seekPosition(0);
  }

  Future<void> prepareStory(String originFilePath, String normalizedFilePath, List<double>? waveformData, List<BlockInfoDto>? blockInfos) async {
    _ref.watch(loadingProvider.notifier).state = true;
    originWavFilePath = originFilePath;
    normalizedWavFilePath = normalizedFilePath;
    Duration? duration = await AudioUtils.getAudioFileLength(normalizedWavFilePath!);
    originAudioLength = duration!.inMilliseconds;
    await _storyAudioPlayerService.prepareFileAudio(normalizedWavFilePath!, onStoryCursorChange, onStoryComplete);
    _ref.watch(loadingProvider.notifier).state = false;
    if(waveformData != null) {
      _ref.watch(blockInfosProvider.notifier).state = _splitIntoChunks(
        BlockInfoDto(
          from: Duration.zero,
          to: duration,
          position: Duration.zero,
          length: duration,
          soundIndex: 0,
          volume: 1,
          url: "",
          name: "",
          skip: Duration.zero,
          waveformData: waveformData,
          type: "story",
          soundType: "",
        ),
      );
      _ref.watch(totalLengthProvider.notifier).state = duration?? Duration.zero;
    }
    if(blockInfos != null) {
      _ref.watch(blockInfosProvider.notifier).state = blockInfos;
      _ref.watch(totalLengthProvider.notifier).state = blockInfos.last.to;
    }
  }

  List<BlockInfoDto> _splitIntoChunks(BlockInfoDto block) {
    List<BlockInfoDto> chunkedBlocks = [];
    Duration start = block.from;
    Duration end = block.to;
    int totalWaveformLength = block.waveformData.length;
    int totalDuration = end.inMilliseconds;

    // Split into chunks of 120 seconds
    while (start < end) {
      Duration chunkEnd = (start + Duration(seconds: 120)).compareTo(end) > 0 ? end : start + Duration(seconds: 120);

      // Calculate the portion of the waveform data for this chunk
      int startIndex = ((start.inMilliseconds / totalDuration) * totalWaveformLength).toInt();
      int endIndex = (((chunkEnd.inMilliseconds / totalDuration) * totalWaveformLength).toInt()).clamp(0, totalWaveformLength);

      List<double> chunkWaveformData = block.waveformData.sublist(startIndex, endIndex);

      chunkedBlocks.add(BlockInfoDto(
        from: start,
        to: chunkEnd,
        position: start,
        length: chunkEnd - start,
        soundIndex: block.soundIndex,
        volume: block.volume,
        url: block.url,
        name: block.name,
        skip: block.skip,
        waveformData: chunkWaveformData,  // Updated waveform data
        type: block.type,
        soundType: block.soundType,
      ));

      start = chunkEnd;
    }

    return chunkedBlocks;
  }

  Future<void> insertSound(String url, String name, String soundType) async {
    await pauseAudio();
    _ref.watch(loadingProvider.notifier).state = true;
    Duration currentPosition = _playerTimerController.getCursor();
    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration? length = await AudioUtils.getAudioUrlLength(url);
    if(length == null) {
      return;
    }

    if(currentPosition == Duration.zero) {
      for(BlockInfoDto blockInfo in blockInfoList) {
        blockInfo.from = blockInfo.from + length;
        blockInfo.to = blockInfo.to + length;
        if(blockInfo.type == "sound") {
          blockInfo.soundIndex++;
        }
      }
      PlayService soundPlayService = PlayService(AudioPlayer(), soundIndex: 0);
      await soundPlayService.prepareInsertedSoundAudio(url, onInsertAudioCursorChange, onInsertAudioComplete);
      _insertedSoundPlayerServices.insert(0, soundPlayService);
      for(int i = 1; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! + 1;
      }
      blockInfoList.insert(0, BlockInfoDto(
        from: Duration.zero,
        to: length,
        position: Duration.zero,
        length: length,
        volume: 1,
        url: url,
        name: name,
        waveformData: [],
        soundIndex: 0,
        skip: blockInfoList[0].position,
        type: "sound",
        soundType: soundType
      ));
      _playerTimerController.insertBlockPosition(0, Duration(milliseconds: 0));
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) + length;
      await seekPosition(0);
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    if(currentPosition >= blockInfoList.last.to) {
      // find last sound index
      int lastSoundIndex = -1;
      for(int i = 0; i < blockInfoList.length; i++) {
        if(blockInfoList[i].type == "sound") {
          lastSoundIndex = blockInfoList[i].soundIndex;
        }
      }
      blockInfoList.add(BlockInfoDto(
        from: currentPosition,
        to: currentPosition + length,
        position: Duration.zero,
        length: length,
        volume: 1,
        url: url,
        soundIndex: lastSoundIndex + 1,
        name: name,
        waveformData: [],
        skip: Duration.zero,
        type: "sound",
        soundType: soundType
      ));
      PlayService soundPlayService = PlayService(AudioPlayer(), soundIndex: lastSoundIndex + 1);
      await soundPlayService.prepareInsertedSoundAudio(url, onInsertAudioCursorChange, onInsertAudioComplete);
      _insertedSoundPlayerServices.add(soundPlayService);
      _playerTimerController.insertBlockPosition(lastSoundIndex + 1, Duration(milliseconds: 0));
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) + length;
      await seekPosition(currentPosition.inMilliseconds - changeGap, reset: true);
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    int insertedIndex = 0;
    int insertedPlayerIndex = 0;
    for(int i = 0; i < blockInfoList.length; i++) {
      if(currentPosition == blockInfoList[i].from) {
        insertedIndex = i;
        break;
      }
      if(blockInfoList[i].type == "sound") {
        _playerTimerController.changeBlockPosition(blockInfoList[i].soundIndex, blockInfoList[i].length);
        insertedPlayerIndex++;
      }
      if(blockInfoList[i].from < currentPosition && blockInfoList[i].to > currentPosition) {
        insertedIndex = i;
        break;
      }
    }

    if(currentPosition == blockInfoList[insertedIndex].from) {
      blockInfoList.insert(insertedIndex, BlockInfoDto(
        from: currentPosition,
        to: currentPosition + length,
        position: Duration.zero,
        soundIndex: insertedPlayerIndex,
        length: length,
        volume: 1,
        url: url,
        name: name,
        waveformData: [],
        skip: blockInfoList[insertedIndex - 1].skip,
        type: "sound",
        soundType: soundType
      ));
      blockInfoList[insertedIndex - 1].skip = Duration.zero;
      PlayService soundPlayService = PlayService(AudioPlayer(), soundIndex: insertedPlayerIndex);
      await soundPlayService.prepareInsertedSoundAudio(url, onInsertAudioCursorChange, onInsertAudioComplete);
      _insertedSoundPlayerServices.insert(insertedPlayerIndex, soundPlayService);
      for(int i = insertedPlayerIndex + 1; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! + 1;
      }
      _playerTimerController.insertBlockPosition(insertedPlayerIndex, Duration(milliseconds: 0));
      for(int i = insertedIndex + 1; i < blockInfoList.length; i++) {
        blockInfoList[i].from = blockInfoList[i].from + length;
        blockInfoList[i].to = blockInfoList[i].to + length;
        if(blockInfoList[i].type == "sound") {
          blockInfoList[i].soundIndex++;
        }
      }
      _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) + length;
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _playerTimerController.stopTrackingProgress();
      await seekPosition(currentPosition.inMilliseconds, reset: true);
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    if(blockInfoList[insertedIndex].type == "sound") {
      ToastService.showNoticeToast("不可重複插入音檔");
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }

    // update inserted block
    Duration originLength = blockInfoList[insertedIndex].to - blockInfoList[insertedIndex].from;
    Duration originSkip = blockInfoList[insertedIndex].skip;
    List<double> originWaveformData = blockInfoList[insertedIndex].waveformData;
    blockInfoList[insertedIndex].to = currentPosition;
    Duration afterLength = blockInfoList[insertedIndex].to - blockInfoList[insertedIndex].from;
    blockInfoList[insertedIndex].length = afterLength;
    blockInfoList[insertedIndex].skip = Duration.zero;
    blockInfoList[insertedIndex].waveformData = originWaveformData.sublist(0, blockInfoList[insertedIndex].waveformData.length * afterLength.inMilliseconds ~/ originLength.inMilliseconds);

    // insert separated new story block
    BlockInfoDto newStoryBlock = BlockInfoDto(
      from: currentPosition,
      to: currentPosition + originLength - afterLength,
      position: blockInfoList[insertedIndex].position + blockInfoList[insertedIndex].length,
      length: originLength - afterLength,
      soundIndex: -1,
      volume: 1,
      skip: originSkip,
      url: "",
      name: "",
      waveformData: originWaveformData.sublist(originWaveformData.length * afterLength.inMilliseconds ~/ originLength.inMilliseconds, originWaveformData.length),
      type: "story",
      soundType: ""
    );
    blockInfoList.insert(insertedIndex + 1, newStoryBlock);

    for(int i = insertedIndex + 1; i < blockInfoList.length; i++) {
      blockInfoList[i].from = blockInfoList[i].from + length;
      blockInfoList[i].to = blockInfoList[i].to + length;
      blockInfoList[i].soundIndex++;
    }

    blockInfoList.insert(insertedIndex + 1, BlockInfoDto(
      from: currentPosition,
      to: currentPosition + length,
      position: Duration.zero,
      soundIndex: insertedPlayerIndex,
      length: length,
      volume: 1,
      url: url,
      name: name,
      waveformData: [],
      skip: Duration.zero,
      type: "sound",
      soundType: soundType
    ));
    PlayService soundPlayService = PlayService(AudioPlayer(), soundIndex: insertedPlayerIndex);
    await soundPlayService.prepareInsertedSoundAudio(url, onInsertAudioCursorChange, onInsertAudioComplete);
    _insertedSoundPlayerServices.insert(insertedPlayerIndex, soundPlayService);
    for(int i = insertedPlayerIndex + 1; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! + 1;
    }
    _playerTimerController.insertBlockPosition(insertedPlayerIndex, Duration(milliseconds: 0));
    _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) + length;
    _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
    _playerTimerController.stopTrackingProgress();
    await seekPosition(currentPosition.inMilliseconds - changeGap, reset: true);
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> removeSound(int index, BlockInfoDto removedBlockInfo) async {
    if(removedBlockInfo.type == "story") {
      ToastService.showNoticeToast("不可刪除故事片段");
      return;
    }

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    // 避免 cursor 超出範圍，所以先移動
    Duration currentCursor = _playerTimerController.getCursor();
    if(blockInfoList.last.to - currentCursor < removedBlockInfo.length) {
      await seekPosition((currentCursor - removedBlockInfo.length).inMilliseconds);
    }

    // 移除會超出範圍的 background music and sound effect
    List<BackgroundMusicDto> selectedBackgrounds = _ref.watch(selectedBackgroundProvider);
    List<SoundEffectDto> selectedSoundEffects = _ref.watch(selectedSoundEffectDtoProvider);
    for(int i = 0; i < selectedBackgrounds.length; i++) {
      if(_ref.watch(totalLengthProvider) - Duration(milliseconds: selectedBackgrounds[i].endMilliSec) < removedBlockInfo.length) {
        removeBackgroundMusic(i);
      }
    }
    for(int i = 0; i < selectedSoundEffects.length; i++) {
      if(_ref.watch(totalLengthProvider) - Duration(milliseconds: selectedSoundEffects[i].endMilliSec) < removedBlockInfo.length) {
        removeSoundEffect(i);
      }
    }
    await Future.delayed(Duration(milliseconds: 500));// for user experience(let user know the progress)

    // 移除開頭音效
    if(removedBlockInfo.from == Duration.zero) {
      for(int i = 1; i < blockInfoList.length; i++) {
        blockInfoList[i].from -= removedBlockInfo.length;
        blockInfoList[i].to -= removedBlockInfo.length;
        if(blockInfoList[i].type == "sound") {
          blockInfoList[i].soundIndex--;
        }
      }
      blockInfoList.removeAt(0);
      _insertedSoundPlayerServices[0].dispose();
      _insertedSoundPlayerServices.removeAt(0);
      for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! - 1;
      }
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(totalLengthProvider.notifier).state -= removedBlockInfo.length;
    } else if(index == blockInfoList.length - 1) { // 移除最後一個音效
      blockInfoList.removeLast();
      _insertedSoundPlayerServices.last.dispose();
      _insertedSoundPlayerServices.removeLast();
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(totalLengthProvider.notifier).state -= removedBlockInfo.length;
      await seekPosition(currentCursor.inMilliseconds, reset: true);
      return;
    } else if(blockInfoList[index - 1].type == "sound" || blockInfoList[index + 1].type == "sound") {
      for(int i = index + 1; i < blockInfoList.length; i++) {
        blockInfoList[i].from -= removedBlockInfo.length;
        blockInfoList[i].to -= removedBlockInfo.length;
        if(blockInfoList[i].type == "sound") {
          blockInfoList[i].soundIndex--;
        }
      }
      blockInfoList[index - 1].skip = blockInfoList[index].skip;
      blockInfoList.removeAt(index);
      _playerTimerController.stopTrackingProgress();
      for(int i = removedBlockInfo.soundIndex + 1; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! - 1;
      }
      _insertedSoundPlayerServices[removedBlockInfo.soundIndex].dispose();
      _insertedSoundPlayerServices.removeAt(removedBlockInfo.soundIndex);
      _ref.watch(totalLengthProvider.notifier).state -= removedBlockInfo.length;
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      await seekPosition(currentCursor.inMilliseconds, reset: true);
    } else if(blockInfoList[index].skip != Duration.zero) { // 在插入前，原本就是兩個 block 的情況
      for(int i = index + 1; i < blockInfoList.length; i++) {
        blockInfoList[i].from -= removedBlockInfo.length;
        blockInfoList[i].to -= removedBlockInfo.length;
        if(blockInfoList[i].type == "sound") {
          blockInfoList[i].soundIndex--;
        }
      }
      blockInfoList[index - 1].skip = blockInfoList[index].skip;
      blockInfoList.removeAt(index);
      _playerTimerController.stopTrackingProgress();
      for(int i = removedBlockInfo.soundIndex + 1; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! - 1;
      }
      _insertedSoundPlayerServices[removedBlockInfo.soundIndex].dispose();
      _insertedSoundPlayerServices.removeAt(removedBlockInfo.soundIndex);
      _ref.watch(totalLengthProvider.notifier).state -= removedBlockInfo.length;
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      await seekPosition(currentCursor.inMilliseconds, reset: true);
    } else {
      blockInfoList[index - 1].to += blockInfoList[index + 1].length;
      blockInfoList[index - 1].length += blockInfoList[index + 1].length;
      blockInfoList[index - 1].waveformData += blockInfoList[index + 1].waveformData;
      blockInfoList[index - 1].skip = blockInfoList[index + 1].skip;
      for(int i = index + 2; i < blockInfoList.length; i++) {
        if(blockInfoList[i].type == "story") {
          blockInfoList[i].from -= removedBlockInfo.length;
          blockInfoList[i].to -= removedBlockInfo.length;
        } else if (blockInfoList[i].type == "sound") {
          blockInfoList[i].from -= removedBlockInfo.length;
          blockInfoList[i].to -= removedBlockInfo.length;
          blockInfoList[i].soundIndex--;
        }
      }

      // 移除音效以及合併的故事片段
      blockInfoList.removeAt(index);
      blockInfoList.removeAt(index);
      _playerTimerController.stopTrackingProgress();
      for(int i = removedBlockInfo.soundIndex + 1; i < _insertedSoundPlayerServices.length; i++) {
        _insertedSoundPlayerServices[i].soundIndex = _insertedSoundPlayerServices[i].soundIndex! - 1;
      }
      _insertedSoundPlayerServices[removedBlockInfo.soundIndex].dispose();
      _insertedSoundPlayerServices.removeAt(removedBlockInfo.soundIndex);
      _ref.watch(totalLengthProvider.notifier).state -= removedBlockInfo.length;
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      await seekPosition(currentCursor.inMilliseconds, reset: true);
    }
  }

  Future<void> rollbackCut(List<BlockInfoDto> rollbackBlocks, Duration totalLength, Duration cutFrom) async {
    await seekPosition(0);
    _ref.watch(blockInfosProvider.notifier).state = rollbackBlocks;
    _ref.watch(totalLengthProvider.notifier).state = totalLength;
    await seekPosition(cutFrom.inMilliseconds - changeGap); // 如果刪除很長的一段 list view 有可能會跑掉 所以在搜尋一次
    ToastService.showNoticeToast("剪輯出現異常，請再試一次");
    await Future.delayed(const Duration(seconds: 1));
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> cutStory(Duration cutFrom, Duration cutTo) async {
    if(_ref.watch(isSeekingProvider) || _ref.watch(isScrollingProvider)) {
      ToastService.showNoticeToast("定位中");
      return;
    }
    if(cutTo < cutFrom || cutTo - cutFrom < Duration(milliseconds: changeGap)) {
      ToastService.showNoticeToast("位置錯誤");
      return;
    }
    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    _ref.watch(loadingProvider.notifier).state = true;

    int fromBlockIndex = 0;
    int toBlockIndex = 0;
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= cutFrom && blockInfoList[i].to > cutFrom) {
        fromBlockIndex = i;
      }
      if(blockInfoList[i].from <= cutTo && blockInfoList[i].to > cutTo) {
        toBlockIndex = i;
        break;
      }
    }

    if(cutFrom.inMilliseconds == 0) { // 移除開頭
      // 增加剪輯紀錄
      List<BlockInfoDto> originBlockInfo = [
        ..._ref.watch(blockInfosProvider).map((block) => block.clone())
      ];
      Map<Duration, List<BlockInfoDto>> newHistory = {};
      newHistory[cutFrom] = originBlockInfo;
      _cutStack.add(newHistory);
      if(_cutStack.length > 5) {
        _cutStack.removeAt(0); // removes the first (oldest) item -> 如果無限制，會導致 memory overflow
      }
      Duration offset = cutTo - blockInfoList[toBlockIndex].from;
      Duration originalLength = blockInfoList[toBlockIndex].length;
      int originalWaveformLength = blockInfoList[toBlockIndex].waveformData.length;
      blockInfoList[toBlockIndex].from = Duration.zero;
      blockInfoList[toBlockIndex].to = originalLength - offset;
      blockInfoList[toBlockIndex].position += offset;
      blockInfoList[toBlockIndex].length -= offset;
      blockInfoList[toBlockIndex].skip = blockInfoList[toBlockIndex].skip;
      blockInfoList[toBlockIndex].waveformData = blockInfoList[toBlockIndex].waveformData.sublist(originalWaveformLength * offset.inMilliseconds ~/ originalLength.inMilliseconds);
      // Remove all blocks before toBlockIndex
      blockInfoList = blockInfoList.sublist(toBlockIndex);

      // Adjust the from and to values for the remaining blocks
      for (int i = 1; i < blockInfoList.length; i++) {
        blockInfoList[i].from -= (cutTo - cutFrom);
        blockInfoList[i].to -= (cutTo - cutFrom);
      }

      _playerTimerController.stopTrackingProgress();
      await seekPosition(0);
      _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) - (cutTo - cutFrom);
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(cutFromProvider.notifier).state = null;
      _ref.watch(cutToProvider.notifier).state = null;
    } else if (cutTo.inMilliseconds + edgeLimit.inMilliseconds > _ref.watch(totalLengthProvider).inMilliseconds){ // 切除尾巴
      // 增加剪輯紀錄
      List<BlockInfoDto> originBlockInfo = [
        ..._ref.watch(blockInfosProvider).map((block) => block.clone())
      ];
      Map<Duration, List<BlockInfoDto>> newHistory = {};
      newHistory[cutFrom] = originBlockInfo;
      _cutStack.add(newHistory);
      if(_cutStack.length > 5) {
        _cutStack.removeAt(0); // removes the first (oldest) item -> 如果無限制，會導致 memory overflow
      }

      if(cutFrom == blockInfoList[fromBlockIndex].from) { // 覆蓋完整的多個 blocks
        blockInfoList = blockInfoList.sublist(0, fromBlockIndex);
      } else {
        Duration originalLength = blockInfoList[fromBlockIndex].length;
        int originalWaveformLength = blockInfoList[fromBlockIndex].waveformData.length;
        blockInfoList[fromBlockIndex].to = cutFrom;
        blockInfoList[fromBlockIndex].length = blockInfoList[fromBlockIndex].to - blockInfoList[fromBlockIndex].from;
        blockInfoList[fromBlockIndex].skip = Duration.zero;
        blockInfoList[fromBlockIndex].waveformData = blockInfoList[fromBlockIndex].waveformData.sublist(0, originalWaveformLength * blockInfoList[fromBlockIndex].length.inMilliseconds ~/ originalLength.inMilliseconds);
        // Remove all blocks after fromBlockIndex
        blockInfoList = blockInfoList.sublist(0, fromBlockIndex + 1);
      }

      _playerTimerController.stopTrackingProgress();
      _ref.watch(totalLengthProvider.notifier).state = cutFrom;
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      _ref.watch(cutFromProvider.notifier).state = null;
      _ref.watch(cutToProvider.notifier).state = null;
      await seekPosition(cutFrom.inMilliseconds, reset: true);
    } else { // 切除中間片段
      if(blockInfoList[fromBlockIndex].to - blockInfoList[fromBlockIndex].from < const Duration(milliseconds: 500) || blockInfoList[toBlockIndex].to - blockInfoList[toBlockIndex].from < const Duration(milliseconds: 500)) {
        ToastService.showNoticeToast("區塊過小，無法再次剪輯");
        return;
      }

      // 增加剪輯紀錄
      List<BlockInfoDto> originBlockInfo = [
        ..._ref.watch(blockInfosProvider).map((block) => block.clone())
      ];
      Map<Duration, List<BlockInfoDto>> newHistory = {};
      newHistory[cutFrom] = originBlockInfo;
      _cutStack.add(newHistory);
      if(_cutStack.length > 5) {
        _cutStack.removeAt(0); // removes the first (oldest) item -> 如果無限制，會導致 memory overflow
      }
      _ref.watch(cutFromProvider.notifier).state = null;
      _ref.watch(cutToProvider.notifier).state = null;

      if(cutFrom == blockInfoList[fromBlockIndex].from && cutTo  == blockInfoList[toBlockIndex].from) { // 直接整個 block 都剪掉
        BlockInfoDto lastBlock = blockInfoList[fromBlockIndex - 1];
        BlockInfoDto nextBlock = blockInfoList[toBlockIndex];
        lastBlock.skip = nextBlock.position - (lastBlock.position + lastBlock.length);
        for(int i = toBlockIndex; i < blockInfoList.length; i++) {
          blockInfoList[i].from -= (cutTo - cutFrom);
          blockInfoList[i].to -= (cutTo - cutFrom);
        }
        blockInfoList.removeRange(fromBlockIndex, toBlockIndex);
      } else if(cutFrom == blockInfoList[fromBlockIndex].from) {
        BlockInfoDto lastBlock = blockInfoList[fromBlockIndex - 1];
        Duration newToBlockPosition = blockInfoList[toBlockIndex].position + blockInfoList[toBlockIndex].length - (blockInfoList[toBlockIndex].to - cutTo);
        lastBlock.skip = newToBlockPosition - (lastBlock.position + lastBlock.length);
        Duration originToBlockLength = blockInfoList[toBlockIndex].length;
        int originWaveformLength = blockInfoList[toBlockIndex].waveformData.length;
        blockInfoList[toBlockIndex].from = cutTo;
        blockInfoList[toBlockIndex].position = newToBlockPosition;
        blockInfoList[toBlockIndex].length = blockInfoList[toBlockIndex].to - cutTo;
        int start = originWaveformLength * (originToBlockLength - blockInfoList[toBlockIndex].length).inMilliseconds ~/ originToBlockLength.inMilliseconds;
        blockInfoList[toBlockIndex].waveformData = blockInfoList[toBlockIndex].waveformData.sublist(start);
        for(int i = toBlockIndex; i < blockInfoList.length; i++) {
          blockInfoList[i].from -= (cutTo - cutFrom);
          blockInfoList[i].to -= (cutTo - cutFrom);
        }
        blockInfoList.removeRange(fromBlockIndex, toBlockIndex);
      } else if(cutTo == blockInfoList[toBlockIndex].from) {
        Duration originFromBlockLength = blockInfoList[fromBlockIndex].length;
        int originWaveformLength = blockInfoList[fromBlockIndex].waveformData.length;
        blockInfoList[fromBlockIndex].to = cutFrom;
        blockInfoList[fromBlockIndex].length = blockInfoList[fromBlockIndex].to - blockInfoList[fromBlockIndex].from;
        blockInfoList[fromBlockIndex].skip = blockInfoList[toBlockIndex].position - (blockInfoList[fromBlockIndex].position + blockInfoList[fromBlockIndex].length);
        blockInfoList[fromBlockIndex].waveformData = blockInfoList[fromBlockIndex].waveformData.sublist(0, originWaveformLength * blockInfoList[fromBlockIndex].length.inMilliseconds ~/ originFromBlockLength.inMilliseconds);
        for(int i = toBlockIndex; i < blockInfoList.length; i++) {
          blockInfoList[i].from -= (cutTo - cutFrom);
          blockInfoList[i].to -= (cutTo - cutFrom);
        }
        blockInfoList.removeRange(fromBlockIndex + 1, toBlockIndex);
      } else if(fromBlockIndex == toBlockIndex) {
        Duration originalTo = blockInfoList[fromBlockIndex].to;
        Duration originalLength = blockInfoList[fromBlockIndex].length;
        int originalWaveformLength = blockInfoList[fromBlockIndex].waveformData.length;
        List<double> originWaveformData = blockInfoList[fromBlockIndex].waveformData;
        Duration originalSkip = blockInfoList[fromBlockIndex].skip;
        blockInfoList[fromBlockIndex].to = cutFrom;
        blockInfoList[fromBlockIndex].length = blockInfoList[fromBlockIndex].to - blockInfoList[fromBlockIndex].from;
        blockInfoList[fromBlockIndex].waveformData = blockInfoList[fromBlockIndex].waveformData.sublist(0, originalWaveformLength * blockInfoList[fromBlockIndex].length.inMilliseconds ~/ originalLength.inMilliseconds);
        blockInfoList[fromBlockIndex].skip = cutTo - cutFrom;
        BlockInfoDto newBlock = BlockInfoDto(
            from: cutFrom,
            to: originalTo - (cutTo - cutFrom),
            position: blockInfoList[fromBlockIndex].position + cutTo - blockInfoList[fromBlockIndex].from,
            soundIndex: -1,
            length: originalTo - cutTo,
            volume: 1,
            url: "",
            name: "story",
            waveformData: originWaveformData.sublist(originalWaveformLength * (blockInfoList[fromBlockIndex].length + cutTo - cutFrom).inMilliseconds ~/ originalLength.inMilliseconds, originalWaveformLength),
            skip: originalSkip,
            type: "story",
            soundType: ""
        );
        blockInfoList.insert(fromBlockIndex+1, newBlock);
        for(int i = fromBlockIndex+2; i < blockInfoList.length; i++) {
          blockInfoList[i].from -= (cutTo - cutFrom);
          blockInfoList[i].to -= (cutTo - cutFrom);
        }
      } else {
        Duration toBlockRemain = blockInfoList[toBlockIndex].to - cutTo;
        Duration toBlockOffset = cutTo - blockInfoList[toBlockIndex].from;
        Duration fromBlockOriginalLength = blockInfoList[fromBlockIndex].length;
        Duration toBlockOriginalLength = blockInfoList[toBlockIndex].length;
        int fromBlockOriginalWaveformLength = blockInfoList[fromBlockIndex].waveformData.length;
        int toBlockOriginalWaveformLength = blockInfoList[toBlockIndex].waveformData.length;
        blockInfoList[toBlockIndex].from = cutFrom;
        blockInfoList[fromBlockIndex].to = cutFrom;
        blockInfoList[toBlockIndex].to = cutFrom + toBlockRemain;
        blockInfoList[toBlockIndex].position += toBlockOffset;
        blockInfoList[fromBlockIndex].length = blockInfoList[fromBlockIndex].to - blockInfoList[fromBlockIndex].from;
        blockInfoList[toBlockIndex].length -= toBlockOffset;
        blockInfoList[fromBlockIndex].skip = blockInfoList[toBlockIndex].position - (blockInfoList[fromBlockIndex].position + blockInfoList[fromBlockIndex].length);
        blockInfoList[fromBlockIndex].waveformData = blockInfoList[fromBlockIndex].waveformData.sublist(0, fromBlockOriginalWaveformLength * blockInfoList[fromBlockIndex].length.inMilliseconds ~/ fromBlockOriginalLength.inMilliseconds);
        blockInfoList[toBlockIndex].waveformData = blockInfoList[toBlockIndex].waveformData.sublist(toBlockOriginalWaveformLength * toBlockOffset.inMilliseconds ~/ toBlockOriginalLength.inMilliseconds);

        for(int i = toBlockIndex+1; i < blockInfoList.length; i++) {
          blockInfoList[i].from -= (cutTo - cutFrom);
          blockInfoList[i].to -= (cutTo - cutFrom);
        }

        // Remove blocks between `fromBlockIndex` and `toBlockIndex`
        if (toBlockIndex > fromBlockIndex + 1) {
          blockInfoList.removeRange(fromBlockIndex + 1, toBlockIndex);
        }
      }

      _ref.watch(totalLengthProvider.notifier).state = _ref.watch(totalLengthProvider) - (cutTo - cutFrom);
      _ref.watch(blockInfosProvider.notifier).state = [...blockInfoList];
      await seekPosition(cutFrom.inMilliseconds - changeGap, reset: true); // 如果刪除很長的一段 list view 有可能會跑掉 所以需要 reset
    }
  }

  Future<void> restoreCutStory() async {
    if(_ref.watch(isSeekingProvider)) {
      return;
    }
    if(_cutStack.isEmpty) {
      ToastService.showNoticeToast("無剪輯紀錄\n(目前系統只記錄最近五次剪輯紀錄)");
      return;
    }
    _ref.watch(loadingProvider.notifier).state = true;
    List<BlockInfoDto> currentBlockInfos = _ref.watch(blockInfosProvider);
    _ref.watch(blockInfosProvider.notifier).state = [..._cutStack.last.entries.first.value];
    _ref.watch(totalLengthProvider.notifier).state = _cutStack.last.entries.first.value.last.to;
    // 回復開頭的情況
    if(currentBlockInfos.first.position != Duration.zero && _cutStack.last.entries.first.value.first.position == Duration.zero) {
      await seekPosition(0, reset: true);
    } else if(currentBlockInfos.length == 1 && currentBlockInfos[0].position != Duration.zero) {
      await seekPosition(0, reset: true);
    } else {
      await seekPosition(_cutStack.last.entries.first.key.inMilliseconds, reset: true);
    }
    _cutStack.removeLast();
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> prepareBackgroundMusic() async {
    await _backgroundMusicPlayerService.prepareConcatenatingAudio(onBackgroundCursorChange, onBackgroundComplete);
  }

  Future<void> onBackgroundCursorChange(Duration duration) async {
    if((_currentBackgroundDuration - duration).inMilliseconds < changeGap) { // since just_audio has bug that can't pause the playlist when changing index, so use this workaround method
      _backgroundMusicPlayerService.pauseAudio();
      backgroundIsPlaying = false;
    }
  }

  Future<void> onBackgroundComplete() async {
    _backgroundMusicPlayerService.pauseAudio();
    backgroundIsPlaying = false;
  }

  Future<void> overlapBackgroundMusic(String musicUrl, String musicName) async {
    Duration currentPosition = _playerTimerController.getCursor();

    _ref.watch(loadingProvider.notifier).state = true;
    Duration? audioLength = await AudioUtils.getAudioUrlLength(musicUrl);
    List<BackgroundMusicDto> backgroundMusicList = _ref.watch(selectedBackgroundProvider);
    for(BackgroundMusicDto background in backgroundMusicList) {
      if(background.checkReached(currentPosition)) {
        ToastService.showNoticeToast("背景音樂不可重疊");
        _ref.watch(loadingProvider.notifier).state = false;
        return;
      }
    }

    int insertIndex = 0;
    for(int i = 0; i < backgroundMusicList.length; i++) {
      if(backgroundMusicList[i].startMilliSec > currentPosition.inMilliseconds) {
        break;
      }
      insertIndex++;
    }

    int endMilliSec;
     if(insertIndex < backgroundMusicList.length && (currentPosition + audioLength!).inMilliseconds > backgroundMusicList[insertIndex].startMilliSec) {
      endMilliSec = backgroundMusicList[insertIndex].startMilliSec - 70;
    } else if ((currentPosition + audioLength!).inMilliseconds > _ref.watch(totalLengthProvider).inMilliseconds){
      endMilliSec = _ref.watch(totalLengthProvider).inMilliseconds;
    }else {
      endMilliSec = (currentPosition + audioLength).inMilliseconds;
    }

    await _backgroundMusicPlayerService.insertConcatenatingAudio(musicUrl, insertIndex);
    backgroundMusicList.insert(insertIndex, BackgroundMusicDto(
      url: musicUrl,
      name: musicName,
      startMilliSec: currentPosition.inMilliseconds,
      endMilliSec: endMilliSec
    ));
    backgroundIsPlaying = false;
    soundEffectIsPlaying = false;
    _ref.watch(selectedBackgroundProvider.notifier).state = [...backgroundMusicList];
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> removeBackgroundMusic(int index) async {
    await pauseAudio();
    List<BackgroundMusicDto> backgroundList = _ref.watch(selectedBackgroundProvider);
    await _backgroundMusicPlayerService.popConcatenatingAudio(index);
    backgroundList.removeAt(index);
    _ref.watch(selectedBackgroundProvider.notifier).state = [...backgroundList];
  }

  Future<void> prepareSoundEffect() async {
    await _soundEffectPlayerService.prepareConcatenatingAudio(onSoundEffectCursorChange, onSoundEffectComplete);
  }

  Future<void> overlapSoundEffect({SoundEffectListItemDto? soundEffectListItemDto, FindAudiosResItem? findAudioResItem}) async {
    Duration currentPosition = _playerTimerController.getCursor();

    _ref.watch(loadingProvider.notifier).state = true;
    Duration? audioLength = await AudioUtils.getAudioUrlLength(findAudioResItem == null? soundEffectListItemDto!.soundEffectUrl : findAudioResItem.audioUrl);
    List<SoundEffectDto> soundEffectInfoList = _ref.watch(selectedSoundEffectDtoProvider);
    for(SoundEffectDto playInfo in soundEffectInfoList) {
      if(playInfo.checkReached(currentPosition)) {
        ToastService.showNoticeToast("音效不可重疊");
        _ref.watch(loadingProvider.notifier).state = false;
        return;
      }
    }

    int insertIndex = 0;
    for(int i = 0; i < soundEffectInfoList.length; i++) {
      if(soundEffectInfoList[i].startMilliSec > currentPosition.inMilliseconds) {
        break;
      }
      insertIndex++;
    }

    int endMilliSec;
    if(insertIndex < soundEffectInfoList.length && (currentPosition + audioLength!).inMilliseconds > soundEffectInfoList[insertIndex].startMilliSec) {
      endMilliSec = soundEffectInfoList[insertIndex].startMilliSec - 70;
    } else if ((currentPosition + audioLength!).inMilliseconds > _ref.watch(totalLengthProvider).inMilliseconds){
      endMilliSec = _ref.watch(totalLengthProvider).inMilliseconds;
    }else {
      endMilliSec = (currentPosition + audioLength).inMilliseconds;
    }

    await _soundEffectPlayerService.insertConcatenatingAudio(findAudioResItem == null? soundEffectListItemDto!.soundEffectUrl : findAudioResItem.audioUrl, insertIndex);
    soundEffectInfoList.insert(insertIndex, SoundEffectDto(
      url: findAudioResItem == null? soundEffectListItemDto!.soundEffectUrl : findAudioResItem.audioUrl,
      soundEffectName: findAudioResItem == null? soundEffectListItemDto!.soundEffectName : findAudioResItem.audioName,
      startMilliSec: currentPosition.inMilliseconds,
      endMilliSec: endMilliSec
    ));
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;
    _ref.watch(selectedSoundEffectDtoProvider.notifier).state = [...soundEffectInfoList];
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> onInsertAudioCursorChange(int soundIndex, Duration duration) async {
    if(currentPlayingService == "story" || _ref.watch(isSeekingProvider)) {
      return;
    }
    _playerTimerController.changeBlockPosition(soundIndex, duration);
    checkAndPlaySoundEffect();
    checkAndPlayBackground();

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _playerTimerController.getCursor();
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(currentCursor > blockInfoList[i].to - Duration(milliseconds: changeGap)) {
          if(i == blockInfoList.length - 1){
            return;
          }

          if(blockInfoList[i].type == "sound") {
            if(blockInfoList[i + 1].type == "story") {
              _playerTimerController.stopTrackingProgress();
              _playerTimerController.addSkipLength(i, blockInfoList[i].skip);
              if(blockInfoList[i].skip != Duration.zero) {
                await _storyAudioPlayerService.seekPosition(blockInfoList[i+1].position.inMilliseconds);
              }
              _playerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
              _insertedSoundPlayerServices[soundIndex].pauseAudio();
              if(_ref.watch(playerStatusProvider) == "playing") {
                _storyAudioPlayerService.playAudio();
                currentPlayingService = "story";
              }
              _playerTimerController.startTrackingProgress();
            } else if(blockInfoList[i + 1].type == "sound") {
              await _insertedSoundPlayerServices[blockInfoList[i].soundIndex].pauseAudio();
              _playerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
              if(_ref.watch(playerStatusProvider) == "playing") {
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
    Duration currentCursor = _playerTimerController.getCursor();
    for(int i = 0; i < blockInfoList.length; i++) {
      if(blockInfoList[i].from <= currentCursor && blockInfoList[i].to > currentCursor) {
        if(blockInfoList[i].type == "sound") {
          if(blockInfoList[i + 1].type == "story") {
            _playerTimerController.stopTrackingProgress();
            _playerTimerController.addSkipLength(i, blockInfoList[i].skip);
            if(blockInfoList[i].skip != Duration.zero) {
              await _storyAudioPlayerService.seekPosition(blockInfoList[i+1].position.inMilliseconds);
            }
            _playerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
            _insertedSoundPlayerServices[soundIndex].pauseAudio();
            if(_ref.watch(playerStatusProvider) == "playing") {
              _storyAudioPlayerService.playAudio();
              currentPlayingService = "story";
            }
            _playerTimerController.startTrackingProgress();
          } else if(blockInfoList[i + 1].type == "sound") {
            await _insertedSoundPlayerServices[blockInfoList[i].soundIndex].pauseAudio();
            _playerTimerController.changeBlockPosition(soundIndex, blockInfoList[i].length);
            if(_ref.watch(playerStatusProvider) == "playing") {
              _insertedSoundPlayerServices[blockInfoList[i+1].soundIndex].playAudio();
              currentPlayingService = "sound";
            }
          }
        }
      }
    }
  }

  Future<void> onStoryCursorChange(Duration duration) async {
    if(currentPlayingService == "sound" || _ref.watch(isSeekingProvider)) {
      return;
    }
    _playerTimerController.changeStoryPosition(duration);
    checkAndPlaySoundEffect();
    checkAndPlayBackground();

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _playerTimerController.getCursor();

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
              _playerTimerController.changeStoryPosition(blockInfoList[i].position + blockInfoList[i].length);
              if(_ref.watch(playerStatusProvider) == "playing") {
                _insertedSoundPlayerServices[blockInfoList[i+1].soundIndex].playAudio();
                currentPlayingService = "sound";
              }
            } else if(blockInfoList[i+1].type == "story") {
              _playerTimerController.stopTrackingProgress();
              await _storyAudioPlayerService.seekPosition((blockInfoList[i+1].position).inMilliseconds);
              _playerTimerController.addSkipLength(i, blockInfoList[i].skip);
              _playerTimerController.startTrackingProgress();
            }
          }
        }
      }
    }
  }

  Future<void> onStoryComplete() async {
    pauseAudio();
  }

  Future<void> onBackgroundMusicCursorChange(Duration duration) async {
  }

  Future<void> onBackgroundMusicComplete() async {
    // playService.seekPosition(_backgroundMusicPlayer, 0); // will originally loop itself
  }

  Future<void> onSoundEffectCursorChange(Duration duration) async {
    if((_currentSoundEffectDuration - duration).inMilliseconds < changeGap) { // since just_audio has bug that can't pause the playlist when changing index, so use this workaround method
      _soundEffectPlayerService.pauseAudio();
      soundEffectIsPlaying = false;
    }
  }

  Future<void> onSoundEffectComplete() async {
    _soundEffectPlayerService.pauseAudio();
    soundEffectIsPlaying = false;
  }

  Future<void> playAudio() async {
    if(normalizedWavFilePath == null || normalizedWavFilePath == "") {
      return ;
    }
    if(_ref.watch(isSeekingProvider)) {
      return;
    }

    _playerTimerController.startTrackingProgress();
    _ref.watch(playerStatusProvider.notifier).state = "playing";
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    Duration currentCursor = _playerTimerController.getCursor();
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

  Future<void> seekPosition(int seekDuration, {bool track = true, bool stopTrackFirst = false, bool reset = false}) async {
    if(seekDuration < 0) {
      seekDuration = 0;
    }
    if(seekDuration > _ref.watch(totalLengthProvider).inMilliseconds - 100) {
      seekDuration = _ref.watch(totalLengthProvider).inMilliseconds - 100;
    }
    // disable audio bar's scrolling when seeking
    _ref.watch(isSeekingProvider.notifier).state = true;
    String originPlayStatus = _ref.watch(playerStatusProvider);
    if(stopTrackFirst) {
      _playerTimerController.stopTrackingProgress();
    }

    _playerTimerController.setAllTrackPositionsToZero();
    _playerTimerController.changeStoryPosition(Duration(milliseconds: 0));
    await _storyAudioPlayerService.seekPosition(0);
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      await _insertedSoundPlayerServices[i].seekPosition(0);
      await _insertedSoundPlayerServices[i].pauseAudio();
    }

    List<BlockInfoDto> blockInfoList = _ref.watch(blockInfosProvider);
    // 開頭被裁切的情形
    if(seekDuration == 0 && blockInfoList[0].type == "story") {
      _playerTimerController.skipLength = blockInfoList[0].position;
      await _storyAudioPlayerService.seekPosition(blockInfoList[0].position.inMilliseconds);
      _playerTimerController.changeStoryPosition(blockInfoList[0].position);
      _ref.watch(isSeekingProvider.notifier).state = false;
      if(!track) {
        _playerTimerController.changeTimer();
      } else {
        _playerTimerController.startTrackingProgress();
      }
      if(originPlayStatus == "playing") {
        playAudio();
      }
      return;
    }

    // 添加開頭 padding
    if(blockInfoList[0].type == "story") {
      _playerTimerController.addSkipLength(0, blockInfoList[0].position);
    }
    Duration? lastStoryBlockPosition = null;
    for(int i = 0; i < blockInfoList.length; i++) {
      // 已經過去的 block
      if(blockInfoList[i].to.inMilliseconds <= seekDuration) {
        if(blockInfoList[i].type == "story") {
          lastStoryBlockPosition = blockInfoList[i].position + blockInfoList[i].length; // 不要每次都 seek 以提升效能
          _playerTimerController.changeStoryPosition(blockInfoList[i].position + blockInfoList[i].length);
          _playerTimerController.addSkipLength(i, blockInfoList[i].skip);
        } else if(blockInfoList[i].type == "sound") {
          _playerTimerController.changeBlockPosition(blockInfoList[i].soundIndex, blockInfoList[i].length);
          _playerTimerController.addSkipLength(i, blockInfoList[i].skip);
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
          _playerTimerController.changeStoryPosition(
              blockInfoList[i].position + Duration(milliseconds: seekDuration) -
                  blockInfoList[i].from);
        } else if (blockInfoList[i].type == "sound") {
          currentPlayingService = "sound";
          await _insertedSoundPlayerServices[blockInfoList[i].soundIndex]
              .seekPosition(
              (Duration(milliseconds: seekDuration) - blockInfoList[i].from)
                  .inMilliseconds);
          _playerTimerController.changeBlockPosition(
              blockInfoList[i].soundIndex,
              Duration(milliseconds: seekDuration) - blockInfoList[i].from);
        }
      }
    }
    if(lastStoryBlockPosition != null) {
      await _storyAudioPlayerService.seekPosition(lastStoryBlockPosition.inMilliseconds);
    }

    _ref.watch(isSeekingProvider.notifier).state = false;
    // 為了解決重複 seek scrollbar 會亂跑的問題 -> scroll seek 等到 play audio 才開始 track scroll position
    if(!track) {
      _playerTimerController.changeTimer();
    } else if(reset) {
      await _playerTimerController.resetCursor();
    } else {
      _playerTimerController.startTrackingProgress();
    }
  }

  Future<void> removeSoundEffect(int? index) async {
    if(index == null) {
      return;
    }

    await pauseAudio();
    List<SoundEffectDto> soundEffectInfoList = _ref.watch(selectedSoundEffectDtoProvider);
    soundEffectIsPlaying = false;
    await _soundEffectPlayerService.popConcatenatingAudio(index);
    soundEffectInfoList.removeAt(index);
    _ref.watch(selectedSoundEffectDtoProvider.notifier).state = [...soundEffectInfoList];
  }

  Future<void> pauseAudio() async {
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;
    _ref.watch(playerStatusProvider.notifier).state = "pausing";
    for(int i = 0; i < _insertedSoundPlayerServices.length; i++) {
      _insertedSoundPlayerServices[i].pauseAudio();
    }
    await _storyAudioPlayerService.pauseAudio();
    await _backgroundMusicPlayerService.pauseAudio();
    await _soundEffectPlayerService.pauseAudio();
  }

  void stopAudio() {
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;
    _storyAudioPlayerService.stopAudio();
    _backgroundMusicPlayerService.stopAudio();
    _soundEffectPlayerService.stopAudio();
    _ref.watch(playerStatusProvider.notifier).state = "stop";
  }

  void restartAudio() {
    soundEffectIsPlaying = false;
    backgroundIsPlaying = false;
    _ref.watch(playerStatusProvider.notifier).state = "playing";
    _storyAudioPlayerService.playAudio();
    _backgroundMusicPlayerService.playAudio();
  }

  bool isRecorded() {
    return normalizedWavFilePath != "";
  }

  Future<void> checkAndPlaySoundEffect() async {
    final soundEffectList = _ref.watch(selectedSoundEffectDtoProvider);
    if(soundEffectIsPlaying) {
      return;
    }

    for(int i = 0; i < soundEffectList.length; i++) {
      Duration position = _playerTimerController.getCursor();
      if(soundEffectList[i].checkReached(position)) {
        soundEffectIsPlaying = true;
        _currentSoundEffectDuration = soundEffectList[i].getDuration();
        await _soundEffectPlayerService.seekPosition(_playerTimerController.getCursor().inMilliseconds - soundEffectList[i].startMilliSec, index: i);
        if(_ref.watch(playerStatusProvider) == "playing") {
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
      Duration position = _playerTimerController.getCursor();
      if(backgroundList[i].checkReached(position)) {
        backgroundIsPlaying = true;
        _currentBackgroundDuration = backgroundList[i].getDuration();
        await _backgroundMusicPlayerService.seekPosition(_playerTimerController.getCursor().inMilliseconds - backgroundList[i].startMilliSec, index: i);
        if(_ref.watch(playerStatusProvider) == "playing") {
          _backgroundMusicPlayerService.playAudio();
        }
        return;
      } else {
        backgroundIsPlaying = false;
        _backgroundMusicPlayerService.pauseAudio();
      }
    }
  }
}
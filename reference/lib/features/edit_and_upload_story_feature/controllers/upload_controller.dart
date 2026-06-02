import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/create_audio_res.dart';
import 'package:quick_share_app/apiManagers/audio_library_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/check_capacity_res.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/dto/space_dto.dart';
import 'package:quick_share_app/dto/transition_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../apiManagers/story_api_dto/upload_story_res.dart';
import '../../../apiManagers/story_system_api_manager.dart';
import '../../../apiManagers/upload_system_api_manager.dart';
import '../../../dto/block_info_dto.dart';
import '../../../router.dart';

class UploadController {
  WidgetRef _ref;
  EditTrimPlayController _editTrimPlayController;
  PreviewPlayerController _previewPlayerController;

  UploadController(this._ref, this._editTrimPlayController, this._previewPlayerController);

  Future<void> uploadPersonalAudio(File audioFile, String audioName, String audioType) async {
    GetUploadUrlRes uploadResponse;
    try{
      uploadResponse = await uploadApiManager.uploadAudioLibraryAudio(audioFile);
      if(uploadResponse.data == null) {
        _ref.watch(loadingProvider.notifier).state = false;
        ToastService.showNoticeToast("上傳失敗");
        throw Exception("upload file failed.");
      }
    } catch(e) {
      _ref.watch(loadingProvider.notifier).state = false;
      ToastService.showNoticeToast("上傳失敗");
      throw Exception("upload file failed.");
    }

    CreateAudioRes createResponse = await audioLibraryApiManager.createAudio(audioName, uploadResponse.data!.publicUrl, audioType);
    if(createResponse.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      ToastService.showNoticeToast("上傳失敗");
      throw Exception("upload file failed.");
    }
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> uploadStory() async {
    _ref.watch(loadingProvider.notifier).state = true;
    CheckCapacityRes checkRes = await storyApiManager.checkCapacity(UserService.getUserInfo()!.userId, _ref.watch(totalLengthProvider).inMilliseconds);
    if(checkRes.code != "0000") {
      ToastService.showNoticeToast(checkRes.message);
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    String? contentUrl;
    List<String>? imageUrls;
    try {
      final results = await Future.wait<Object?>([
        uploadImages(_ref),          // returns List<String>
        uploadStoryContent(_ref),    // returns String?
      ]);

      imageUrls  = results[0] as List<String>?;
      contentUrl = results[1] as String?;

      // use imageUrls + contentUrl ...

    } catch (e, st) {
      ToastService.showNoticeToast("上傳失敗");
      rethrow;
    } finally {
      _ref.watch(loadingTextProvider.notifier).state = null;
      _ref.watch(loadingProvider.notifier).state = false;
    }
    if(contentUrl == null || imageUrls == null) {
      _ref.watch(loadingTextProvider.notifier).state = null;
      _ref.watch(loadingProvider.notifier).state = false;
      ToastService.showNoticeToast("上傳失敗");
      throw Exception("upload file failed.");
    }
    String? channelId = getChannelId();
    String? spaceId = getSpaceId();
    _ref.watch(uploadStatusProvider.notifier).state = true;

    if(_ref.watch(transitionSelectedProvider) != null) {
      appendTransition(_ref.watch(transitionSelectedProvider)!);
    }
    UploadStoryRes res = await storyApiManager.uploadStory(
      spaceId?? "",
      channelId?? "",
      contentUrl,
      _ref.watch(storyNameEditingControllerProvider).text,
      _ref.watch(storyDescriptionEditingControllerProvider).text,
      imageUrls,
      _ref.watch(totalLengthProvider).inMilliseconds,
      _ref.watch(extractedPreviewStartPositionProvider).inMilliseconds,
      _ref.watch(extractedPreviewEndPositionProvider).inMilliseconds,
      "enable",
      _ref.watch(podcoinSettingProvider) != 0,
      _ref.watch(collaboratorProvider)?.userId,
      _ref.watch(scheduledProvider)? _ref.watch(scheduleTimeProvider) : null
    );
    _ref.watch(loadingTextProvider.notifier).state = null;

    if(res.code != "0000") {
      ToastService.showNoticeToast("上傳失敗");
      _ref.watch(uploadStatusProvider.notifier).state = false;
    } else {
      ToastService.showSuccessToast("上傳成功");
    }
    _ref.watch(loadingProvider.notifier).state = false;
    _ref.watch(pagePositionProvider.notifier).state = 0;
    _ref.watch(storyImagesProvider.notifier).state = null;
    Duration.zero;
    Duration.zero;
    _ref.watch(blockInfosProvider.notifier).state = [];
    _ref.watch(backgroundMusicLengthProvider.notifier).state = Duration.zero;
    _ref.watch(selectedSoundEffectDtoProvider.notifier).state = [];
    _ref.watch(selectedBackgroundProvider.notifier).state = [];
    _ref.watch(playTimerProvider.notifier).state = Duration.zero;
    _ref.watch(previewStoryProvider.notifier).state = null;
    _ref.watch(extractedPreviewStartPositionProvider.notifier).state = Duration.zero;
    _ref.watch(extractedPreviewEndPositionProvider.notifier).state = Duration.zero;
    _ref.watch(previewPageStoryPlayTimerProvider.notifier).state = Duration.zero;
    _ref.watch(storyNameEditingControllerProvider).text = "";
    _ref.watch(storyDescriptionEditingControllerProvider).text = "";
    _ref.watch(storyImagesProvider.notifier).state = null;
    router.go("/userInfo");
    _ref.watch(mainPageIndexProvider.notifier).state = 4;// user info page index
  }

  Future<List<String>> uploadImages(WidgetRef ref) async {
    List<String> storyImageUrls = await uploadApiManager.uploadStoryImages(ref.watch(storyImagesProvider)!);
    try {
      for(int i = 0; i < ref.watch(storyImagesProvider)!.length; i++) {
        ref.watch(storyImagesProvider)![i].delete();
      }
    } catch(e) {
      print(e);
    }
    return storyImageUrls;
  }

  Future<String?> uploadStoryContent(WidgetRef ref) async {
    String? audioPath;
    if(_previewPlayerController.storyAudioPath!.toLowerCase().endsWith(".m4a") || _previewPlayerController.storyAudioPath!.toLowerCase().endsWith(".mp3")) { // from draft
      audioPath = _previewPlayerController.storyAudioPath!;
    } else {
      ref.watch(loadingTextProvider.notifier).state = "檔案壓縮中...";
      audioPath = await AudioUtils.encodeToM4a(_previewPlayerController.storyAudioPath!);
    }

    if(audioPath == null) {
      return null;
    }
    ref.watch(loadingTextProvider.notifier).state = "檔案上傳中...";
    GetUploadUrlRes res = await uploadApiManager.uploadStoryContent(File(audioPath));
    if(res.code != "0000") {
      return null;
    }
    try {
      if(_editTrimPlayController.originWavFilePath != null) {
        File(_editTrimPlayController.originWavFilePath!).delete();
      }
    } catch(e) {
      print(e);
    }
    try {
      if(_editTrimPlayController.normalizedWavFilePath != null) {
        File(_editTrimPlayController.normalizedWavFilePath!).delete();
      }
    } catch(e) {
      print(e);
    }
    return res.data!.publicUrl;
  }

  bool validateTitleAndDesc() {
    return
      _ref.watch(storyNameEditingControllerProvider).text != "" &&
      _ref.watch(storyDescriptionEditingControllerProvider).text != "" &&
      _ref.watch(channelSelectionProvider) != null &&
      _ref.watch(storyImagesProvider) != null &&
      _ref.watch(spaceSelectionProvider) != null;
  }

  bool validateExtractedPreviewEndPosition() {
    return _ref.watch(extractedPreviewEndPositionProvider) != Duration.zero;
  }

  bool validatePodcoinSetting() {
    return _ref.watch(podcoinSettingProvider) != null;
  }

  String? getChannelId() {
    String channelName = _ref.watch(channelSelectionProvider)!;
    List<ChannelDto> channelList = _ref.watch(channelListProvider);
    for(ChannelDto channelDto in channelList) {
      if(channelDto.channelName == channelName) {
        return channelDto.channelId;
      }
    }
    return null;
  }

  String? getSpaceId() {
    String spaceName = _ref.watch(spaceSelectionProvider)!;
    List<SpaceInfoDto> spaceList = _ref.watch(spaceListProvider);
    for(SpaceInfoDto spaceInfoDto in spaceList) {
      if(spaceInfoDto.name == spaceName) {
        return spaceInfoDto.spaceId;
      }
    }
    return null;
  }

  List<BlockInfoDto> mergeContinuousBlocks(List<BlockInfoDto> blocks) {
    List<BlockInfoDto> mergedBlocks = [blocks.first];

    for(int i = 1; i < blocks.length; i++) {
      if(blocks[i].type == "story" && mergedBlocks.last.type == "story" && mergedBlocks.last.skip == Duration.zero) {
        mergedBlocks.last.to = blocks[i].to;
        mergedBlocks.last.length = blocks[i].to - mergedBlocks.last.from;
        mergedBlocks.last.skip = blocks[i].skip;
        mergedBlocks.last.waveformData = mergedBlocks.last.waveformData + blocks[i].waveformData;
        continue;
      }
      mergedBlocks.add(BlockInfoDto(
        from: blocks[i].from,
        to: blocks[i].to,
        position: blocks[i].position,
        length: blocks[i].length,
        soundIndex: blocks[i].soundIndex,
        volume: blocks[i].volume,
        url: blocks[i].url,
        name: blocks[i].name,
        skip: blocks[i].skip,
        waveformData: blocks[i].waveformData,  // Updated waveform data
        type: blocks[i].type,
        soundType: blocks[i].soundType,
      ));
    }

    return mergedBlocks;
  }

  void appendTransition(TransitionDto transition) {
    List<BlockInfoDto> blockInfos = _ref.watch(blockInfosProvider);
    BlockInfoDto lastBlock = blockInfos.last;
    blockInfos.add(
        BlockInfoDto(
            from: lastBlock.to,
            to: lastBlock.to + Duration(milliseconds: transition.length),
            position: Duration.zero,
            soundIndex: 0,
            length: Duration(milliseconds: transition.length),
            volume: 1,
            url: transition.url,
            name: transition.name,
            waveformData: [],
            skip: Duration.zero,
            type: "sound",
            soundType: "music"
        )
    );
    _ref.watch(blockInfosProvider.notifier).state = [...blockInfos];
  }
}
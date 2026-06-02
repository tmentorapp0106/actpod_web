import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/update_channel_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/update_story_feature/provider.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../../apiManagers/story_api_dto/update_space_res.dart';
import '../../../apiManagers/story_api_dto/update_story_res.dart';
import '../../../apiManagers/upload_api_dto/get_upload_url_res.dart';

class StoryController {
  WidgetRef ref;

  StoryController(this.ref);

  Future<void> getStory(String storyId) async {
    GetOneStoryRes storyRes = await storyApiManager.getOneStory(storyId);
    if(storyRes.code != "0000" || storyRes.story == null) {
      ToastService.showNoticeToast("找不到內容");
      return;
    }
    ref.watch(storyProvider.notifier).state = storyRes.story;
    ref.watch(collaboratorProvider.notifier).state = storyRes.story!.collaboratorId.isNotEmpty? UserInfoDto(
      storyRes.story!.collaboratorId,
      storyRes.story!.collaboratorAvatarUrl,
      "",
      storyRes.story!.collaboratorName,
      "",
      "",
      ""
    ) : null;
  }

  Future<bool> updateStory(
    List<File>? imageFiles,
    String storyId,
    String title,
    String description,
    String? channelName,
    String? spaceName,
    String? collaboratorId
  ) async {
    if(title == "" || description == "") {
      return false;
    }

    List<String> storyImageUrls = ref.watch(storyProvider)!.storyImageUrls;
    if(imageFiles != null) {
      storyImageUrls = await uploadApiManager.uploadStoryImages(imageFiles);
    }

    final spaceList = ref.watch(spaceListProvider);
    final originalSpaceName = spaceList.firstWhere((space) => space.spaceId == ref.watch(storyProvider)!.spaceId).name;
    if(spaceName != originalSpaceName) {
      final spaceId = spaceList.firstWhere((space) => space.name == spaceName).spaceId;
      UpdateSpaceRes updateSpaceRes = await storyApiManager.updateSpace(storyId, spaceId);
      if(updateSpaceRes.code != "0000") {
        ToastService.showNoticeToast("更新空間失敗");
        return false;
      }
    }

    if(channelName != ref.watch(storyProvider)!.channelName) {
      final channelId = ref.watch(channelListProvider).firstWhere((channel) => channel.channelName == channelName).channelId;
      UpdateChannelRes updateChannelRes = await storyApiManager.updateChannel(storyId, channelId);
      if(updateChannelRes.code != "0000") {
        ToastService.showNoticeToast("更新頻道失敗");
        return false;
      }
    }

    UpdateStoryRes updateStoryRes = await storyApiManager.updateStory(
        storyId,
        title,
        description,
        collaboratorId?? "",
        storyImageUrls
    );
    if(updateStoryRes.code != "0000") {
      ToastService.showNoticeToast("更新失敗");
      return false;
    }
    return true;
  }
}
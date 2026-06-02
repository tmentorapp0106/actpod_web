import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_channel_info_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_channel_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/channel_api_dto/delete_channel_res.dart';
import '../../../apiManagers/channel_api_dto/update_channel_res.dart';
import '../../../apiManagers/upload_api_dto/get_upload_url_res.dart';
import '../../../apiManagers/user_api_dto/get_user_info_res.dart';
import '../../../apiManagers/user_api_dto/search_user_res.dart';
import '../../../apiManagers/user_system_api_manager.dart';

class ChannelController {
  final WidgetRef _ref;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  ChannelController(this._ref, this.nameController, this.descriptionController);

  Future<void> getChannelStories(String channelId) async {
    GetChannelStoriesRes response = await storyApiManager.getChannelStories(channelId);
    if(response.code != "0000") {
      return;
    }

    if(response.storyList == null) {
      return;
    }
    List<GetChannelStoriesResItem> storyList = [];
    for(GetChannelStoriesResItem item in response.storyList!) {
      if(item.releaseTime.isAfter(DateTime.now())){
        continue;
      }
      storyList.add(item);
    }
    _ref.watch(channelStoriesProvider.notifier).state = storyList;
  }

  Future<void> getChannelInfo(String channelId) async {
    GetChannelInfoRes response = await channelApiManager.getChannelInfo(channelId);
    if(response.code != "0000") {
      return;
    }

    _ref.watch(channelInfoProvider.notifier).state = response.channelInfo!;
    _ref.watch(editChannelImageUrlProvider.notifier).state = response.channelInfo!.channelImageUrl;
    _ref.watch(selectedChannelImageProvider.notifier).state = null;
    nameController.text = response.channelInfo!.channelName;
    descriptionController.text = response.channelInfo!.channelDescription;

    final List<UserInfoDto> userInfoList = [];
    for(String coOwnerId in response.channelInfo?.coOwners?? []) {
      GetUserInfoRes response = await userApiManager.getOthersUserInfo(coOwnerId);
      if(response.code != "0000") {
        continue;
      }
      userInfoList.add(response.userInfo!);
    }
    _ref.watch(channelCoOwnersProvider.notifier).state = userInfoList;
  }

  Future<void> updateChannelInfo(File? fileImage, String channelId, String name, String description) async {
    String imageUrl = _ref.watch(editChannelImageUrlProvider)!;
    if(fileImage != null) {
      GetUploadUrlRes uploadRes = await uploadApiManager.uploadChannelImage(fileImage);
      if(uploadRes.code != "0000") {
         ToastService.showNoticeToast("圖片上傳失敗");
         return;
      }
      imageUrl = uploadRes.data!.publicUrl;
    }

    UpdateChannelRes updateRes = await channelApiManager.updateChannel(
      channelId,
      name,
      description,
      imageUrl,
      _ref.read(channelCoOwnersProvider).map((user) => user.userId).toList()
    );
    if(updateRes.code != "0000") {
      ToastService.showNoticeToast("頻道更新失敗");
      return;
    }

    await getChannelInfo(channelId);
  }

  Future<void> deleteChannel(String channelId) async {
    _ref.watch(loadingProvider.notifier).state = true;
    DeleteChannelRes res = await channelApiManager.deleteChannel(channelId);
    if(res.code != "0000") {
      ToastService.showNoticeToast("無法刪除頻道");
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    await getChannelInfo(channelId);
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> searchUserList(String nickname) async {
    if(nickname == "") {
      _ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    _ref.watch(searchUserListProvider.notifier).state = null;
    SearchUserRes response = await userApiManager.searchUser(nickname);
    if(response.code != "0000") {
      _ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    _ref.watch(searchUserListProvider.notifier).state = response.userInfoList;
  }
}
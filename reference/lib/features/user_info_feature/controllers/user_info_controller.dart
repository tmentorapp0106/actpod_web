import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/exist_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_member_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_user_info_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../utils/image_utils.dart';

class UserInfoController {
  WidgetRef ref;
  UserInfoController(this.ref);

  Future<void> getUserInfo() async {
    UserInfoDto userInfo = UserService.getUserInfo()!;
    ref.watch(selfUserInfoProvider.notifier).state = userInfo;

    ExistPodcastStoreRes response = await channelApiManager.existPodcastStore(userInfo.userId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(existPodcastStoreProvider.notifier).state = response.exist;
  }

  void clearUserInfo() {
    ref.watch(selfUserInfoProvider.notifier).state = null;
  }
}
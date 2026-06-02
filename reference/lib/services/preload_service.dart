import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../apiManagers/channel_api_dto/get_user_channels_res.dart';
import '../apiManagers/channel_system_api_manager.dart';
import '../apiManagers/purchase_api_dto/get_user_purses_res.dart';
import '../apiManagers/purchase_system_api_manager.dart';
import '../apiManagers/space_api_dto/get_active_boards_res.dart';
import '../apiManagers/space_system_api_manager.dart';
import '../apiManagers/story_api_dto/get_stories_by_userid_res.dart';
import '../apiManagers/story_api_dto/get_story_count_res.dart';
import '../apiManagers/story_system_api_manager.dart';
import '../apiManagers/voice_message_api_dto/get_voice_message_notice.dart';
import '../apiManagers/voice_message_system_api_manager.dart';
import '../dto/user_info_dto.dart';
import '../features/search_page_feature/providers.dart';
import '../features/user_info_feature/providers.dart';
import '../features/voice_message_notice_page_feature/providers.dart';
import '../providers.dart';

class PreloadService {
  static Future<void> loadData(WidgetRef ref) async {
    UserInfoDto userInfo = UserService.getUserInfo()!;
    ref.watch(selfUserInfoProvider.notifier).state = userInfo;

    GetVoiceMessageNoticeRes response = await voiceMessageApiManager.getUserVoiceMessageNotice("story");
    if(response.code != "0000") {
      print(response.message);
    }
    ref.watch(storyVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;
    response = await voiceMessageApiManager.getUserVoiceMessageNotice("listened");
    if(response.code != "0000") {
      print(response.message);
    }
    ref.watch(listenedVoiceMessageNoticeListProvider.notifier).state = response.voiceMessageNoticeList!;

    GetStoriesByUserIdRes result = await storyApiManager.getStoriesByUserId(UserService.getUserInfo()!.userId, filterReviewStatus: false);
    if(result.code != "0000") {
      print(response.message);
    }
    ref.watch(selfStoryListProvider.notifier).state = result.storyList;

    GetStoryCountRes storyCountRes = await storyApiManager.getStoryCount(UserService.getUserInfo()!.userId);
    if(storyCountRes.code != "0000") {
      print(response.message);
    }
    ref.watch(selfStoryCountProvider.notifier).state = storyCountRes.count!;

    GetUserChannelsRes channelResponse = await channelApiManager.getUserChannels(UserService.getUserInfo()!.userId);
    if(channelResponse.code != "0000") {
      print(channelResponse.message);
    }
    ref.watch(selfChannelListProvider.notifier).state = channelResponse.channelInfoList;

    GetActiveSpacesRes spacesResponse = await spaceApiManager.getActiveSpaces();
    if(response.code != "0000") {
      print(spacesResponse.message);
    }
    if(spacesResponse.spaces != null) {
      ref.watch(spacesProvider.notifier).state = spacesResponse.spaces!;
    }

    GetUserPursesRes pursesRes = await purchaseApiManager.getUserPurses();
    if(response.code != "0000") {
      print(pursesRes.message);
    }
    if(pursesRes.purses != null) {
      ref.watch(userPodCoinsProvider.notifier).state =  pursesRes.purses!.coinsPurse.podCoins;
      ref.watch(userPodCashProvider.notifier).state = pursesRes.purses!.cashPurse.podCash;
    }
  }
}
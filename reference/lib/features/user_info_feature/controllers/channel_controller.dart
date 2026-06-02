import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/channel_api_dto/get_user_channels_res.dart';

class ChannelController {
  final WidgetRef _ref;

  ChannelController(this._ref);

  Future<void> getChannels(String userId) async {
    GetUserChannelsRes response = await channelApiManager.getUserChannels(userId);
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    _ref.watch(selfChannelListProvider.notifier).state = response.channelInfoList;
  }

  Future<void> getOthersChannels(String userId) async {
    GetUserChannelsRes response = await channelApiManager.getUserChannels(userId);
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    _ref.watch(otherChannelListProvider.notifier).state = response.channelInfoList;
  }

  Future<void> clearChannels() async {
    _ref.watch(selfChannelListProvider.notifier).state = [];
  }
}
import 'package:actpod_web/api_manager/channel_api_manager.dart';
import 'package:actpod_web/api_manager/channel_dto/get_usr_channels_res.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelController {
  WidgetRef ref;

  ChannelController({required this.ref});

  Future<void> getChannels(String userId) async {
    GetUserChannelsRes response = await channelApiManager.getUserChannels(userId);
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    ref.watch(channelListProvider.notifier).state = response.channelInfoList;
  }
}
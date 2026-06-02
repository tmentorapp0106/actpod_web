import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apiManagers/channel_api_dto/get_user_channels_res.dart';
import '../../../apiManagers/channel_system_api_manager.dart';
import '../../../apiManagers/space_api_dto/get_active_boards_res.dart';
import '../../../apiManagers/space_system_api_manager.dart';
import '../../../apiManagers/user_api_dto/search_user_res.dart';
import '../../../apiManagers/user_system_api_manager.dart';
import '../../../services/user_service.dart';
import '../provider.dart';

class ListController {
  final WidgetRef ref;

  ListController(this.ref);

  Future<void> getSpaces() async {
    GetActiveSpacesRes response = await spaceApiManager.getActiveSpaces();
    if(response.code != "0000") {
      throw Exception(response.message);
    }
    ref.watch(spaceListProvider.notifier).state = response.spaces?? [];
  }

  Future<void> getChannels() async {
    String? userId = UserService.getUserInfo()?.userId;
    if(userId == null) {
      return;
    }
    GetUserChannelsRes response = await channelApiManager.getUserChannels(userId);
    if(response.code != "0000") {
      throw Exception(response.message);
    }
    ref.watch(channelListProvider.notifier).state = response.channelInfoList?? [];
  }

  Future<void> searchUserList(String nickname) async {
    if(nickname == "") {
      ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    ref.watch(searchUserListProvider.notifier).state = null;
    SearchUserRes response = await userApiManager.searchUser(nickname);
    if(response.code != "0000") {
      ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    ref.watch(searchUserListProvider.notifier).state = response.userInfoList;
  }
}
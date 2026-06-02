import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/find_audios_res.dart';
import 'package:quick_share_app/apiManagers/audio_library_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_user_channels_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/space_api_dto/get_active_boards_res.dart';
import 'package:quick_share_app/apiManagers/space_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_background_music_list_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_sound_effect_list_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/search_user_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/story_api_dto/get_ending_list_res.dart';
import '../../../apiManagers/story_api_dto/get_opening_list_res.dart';
import '../providers.dart';

class ListController {
  WidgetRef _ref;

  ListController(this._ref);

  Future<void> getSpaces() async {
    GetActiveSpacesRes response = await spaceApiManager.getActiveSpaces();
    if(response.code != "0000") {
      throw Exception(response.message);
    }
    _ref.watch(spaceListProvider.notifier).state = response.spaces?? [];
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
    _ref.watch(channelListProvider.notifier).state = response.channelInfoList?? [];
    if(response.channelInfoList != null && response.channelInfoList!.isNotEmpty) {
      _ref.watch(channelSelectionProvider.notifier).state = response.channelInfoList![0].channelName;
    }
  }

  Future<void> getPersonalSoundAudios() async {
    FindAudiosRes response = await audioLibraryApiManager.findAudios("sound");
    if(response.code != "0000") {
      throw Exception(response.message);
    }
    _ref.watch(soundAudiosProvider.notifier).state = response.audioList?? [];
  }

  Future<void> getPersonalMusicAudios() async {
    FindAudiosRes response = await audioLibraryApiManager.findAudios("music");
    if(response.code != "0000") {
      throw Exception(response.message);
    }
    _ref.watch(musicAudiosProvider.notifier).state = response.audioList?? [];
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
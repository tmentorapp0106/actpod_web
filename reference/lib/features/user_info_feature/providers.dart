import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/dto/membership_level_info_dto.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/shared_prefs/server_prefs.dart';

import '../../apiManagers/story_api_dto/get_stories_by_userid_res.dart';
import '../../dto/membership_dto.dart';

final selfUserInfoProvider = StateProvider<UserInfoDto?>((ref) => UserService.getUserInfo());
final selfStoryListProvider = StateProvider<List<GetStoriesByUserIdResItem>?>((ref) => null);
final selfChannelListProvider = StateProvider<List<ChannelDto>?>((ref) => null);
final selfStoryCountProvider = StateProvider<int>((ref) => 0);
final selfMembershipProvider = StateProvider<MembershipDto?>((ref) => null);

final membershipLevelInfosProvider = StateProvider<List<MembershipLevelInfoDto>?>((ref) => null);
final membershipPriceProvider = StateProvider<String?>((ref) => null);

final loginStatusProvider = StateProvider.autoDispose<bool>((ref) {
  return UserService.getUserToken() == null || UserService.getUserToken() == ""? false : true;
});
final regionSelectionProvider = StateProvider.autoDispose<String>((ref) => ServerPrefs.getServer()!);

final otherUserInfoProvider = StateProvider<UserInfoDto?>((ref) => null);
final otherStoryListProvider = StateProvider<List<GetStoriesByUserIdResItem>?>((ref) => null);
final otherChannelListProvider = StateProvider<List<ChannelDto>?>((ref) => null);
final otherStoryCountProvider = StateProvider<int>((ref) => 0);

final createChannelImageProvider = StateProvider<File?>((ref) => null);
final createChannelNameProvider = StateProvider<String?>((ref) => null);
final createChannelDescriptionProvider = StateProvider<String?>((ref) => null);
final channelCoOwnersProvider = StateProvider<List<UserInfoDto>>((ref) => []);
final searchUserListProvider = StateProvider.autoDispose<List<UserInfoDto>?>((ref) => []);

final syncProcessingProvider = StateProvider<bool>((ref) => false);

final existPodcastStoreProvider = StateProvider.autoDispose<bool?>((ref) => null);

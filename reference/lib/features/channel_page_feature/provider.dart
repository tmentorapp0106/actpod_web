import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_channel_stories_res.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/podcast_store_dto.dart';

import '../../dto/user_info_dto.dart';

final channelStoriesProvider = StateProvider.autoDispose<List<GetChannelStoriesResItem>>((ref) => []);
final channelInfoProvider = StateProvider.autoDispose<ChannelDto?>((ref) => null);

final channelStoryPreviewIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final channelStoryPreviewPlayStatusProvider = StateProvider.autoDispose<String>((ref) => "paused"); // playing, paused

final editChannelImageUrlProvider = StateProvider<String?>((ref) => null);
final selectedChannelImageProvider = StateProvider<File?>((ref) => null);

final isChannelCardVisibleProvider = StateProvider.autoDispose<bool>((ref) => true);

enum CollectStatus {
  notLogin,
  collected,
  notCollected
}
final isCollectedProvider = StateProvider.autoDispose<CollectStatus?>((ref) => null);
final collectedCountProvider = StateProvider.autoDispose<int?>((ref) => null);

final podcastStoreProvider = StateProvider.autoDispose<PodcastStoreDto?>((ref) => null);

final channelCoOwnersProvider = StateProvider<List<UserInfoDto>>((ref) => []);
final searchUserListProvider = StateProvider.autoDispose<List<UserInfoDto>?>((ref) => []);
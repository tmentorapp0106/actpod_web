import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/dto/short_dto.dart';

import '../../dto/channel_dto.dart';
import '../../dto/space_dto.dart';
import '../../dto/user_info_dto.dart';

final storyProvider = StateProvider.autoDispose<GetOneStoryResItem?>((ref) => null);
final selectedStoryImageProvider = StateProvider.autoDispose<List<File>?>((ref) => null);

final channelListProvider = StateProvider<List<ChannelDto>>((ref) => []);
final channelSelectionProvider = StateProvider.autoDispose<String?>((ref) => null);
final spaceListProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);
final spaceSelectionProvider = StateProvider.autoDispose<String?>((ref) => null);

final collaboratorProvider = StateProvider<UserInfoDto?>((ref) => null);
final searchUserListProvider = StateProvider.autoDispose<List<UserInfoDto>?>((ref) => []);

final storyShortsProvider = StateProvider.autoDispose<List<ShortDto>?>((ref) => null);

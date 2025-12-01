
import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/dto/channel_dto.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userInfoProvider = StateProvider<UserInfoDto?>((ref) => null);
final storyListProvider = StateProvider<List<GetStoriesByUserIdResItem>?>((ref) => null);
final channelListProvider = StateProvider<List<ChannelDto>?>((ref) => null);
final storyCountProvider = StateProvider<int>((ref) => 0);
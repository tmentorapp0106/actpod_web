import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/search_channel_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/search_stories_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/search_user_res.dart';

import '../../dto/space_dto.dart';
import '../../dto/user_info_dto.dart';


final searchPreviewIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final searchPreviewPlayStatusProvider = StateProvider<String>((ref) => "paused"); // playing, paused

final searchStoriesItemListProvider = StateProvider<List<SearchStoriesResItem>?>((ref) => null);
final searchUserItemListProvider = StateProvider<List<UserInfoDto>?>((ref) => null);
final searchChannelItemListProvider = StateProvider<List<SearchChannelItem>?>((ref) => null);
final spacesProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);

final isTextingProvider = StateProvider.autoDispose<bool>((ref) => false);
final searchTextProvider = StateProvider.autoDispose<String>((ref) => "");
final playingIndexProvider = StateProvider.autoDispose<int?>((ref) => null);

final searchTypeProvider = StateProvider<String>((ref) => "story"); // story, channel, podcaster
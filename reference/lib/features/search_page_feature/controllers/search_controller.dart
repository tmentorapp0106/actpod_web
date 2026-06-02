import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/search_channel_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/search_user_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/features/search_page_feature/providers.dart';

import '../../../apiManagers/story_api_dto/search_stories_res.dart';
import '../../../apiManagers/story_system_api_manager.dart';
import '../../../providers.dart';

class SearchItemController {
  WidgetRef _ref;

  SearchItemController(this._ref);

  Future<void> searchStories(String searchString) async {
    _ref.watch(loadingProvider.notifier).state = true;
    _ref.watch(searchStoriesItemListProvider.notifier).state = null;
    SearchStoriesRes response =
        await storyApiManager.searchStories(searchString);
    if (response.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    _ref.watch(searchStoriesItemListProvider.notifier).state = [
      ...?response.storyList
    ];
    _ref.watch(searchUserItemListProvider.notifier).state = [];
    _ref.watch(searchChannelItemListProvider.notifier).state = [];
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> searchUser(String searchString) async {
    _ref.watch(loadingProvider.notifier).state = true;
    _ref.watch(searchUserItemListProvider.notifier).state = null;
    SearchUserRes response = await userApiManager.searchUser(searchString);
    if (response.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    _ref.watch(searchUserItemListProvider.notifier).state = [
      ...?response.userInfoList
    ];
    _ref.watch(searchStoriesItemListProvider.notifier).state = [];
    _ref.watch(searchChannelItemListProvider.notifier).state = [];
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> searchChannel(String searchString) async {
    _ref.watch(loadingProvider.notifier).state = true;
    _ref.watch(searchChannelItemListProvider.notifier).state = null;
    SearchChannelRes response =
        await channelApiManager.searchChannel(searchString);
    if (response.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    _ref.watch(searchStoriesItemListProvider.notifier).state = [];
    _ref.watch(searchUserItemListProvider.notifier).state = [];
    _ref.watch(searchChannelItemListProvider.notifier).state = [
      ...?response.channelInfoList
    ];
    _ref.watch(loadingProvider.notifier).state = false;
  }
}

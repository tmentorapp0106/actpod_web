import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/archive_story_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_story_count_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/is_syncing_res.dart';
import 'package:quick_share_app/apiManagers/sync_system_api_manager.dart';
import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/local_storage/repositories/story_repository.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/story_api_dto/get_stories_by_userid_res.dart';

class StoryController {
  final WidgetRef _ref;

  StoryController(this._ref);

  Future<void> checkSyncing() async {
    if(!UserService.hasLoggedIn()) {
      return;
    }

    IsSyncingRes response = await syncApiManager.isSyncing();
    if(response.code != "0000") {
      return;
    }
    _ref.watch(syncProcessingProvider.notifier).state = response.isSyncing;
  }

  Future<void> getStories(String userId) async {
    GetStoriesByUserIdRes result = await storyApiManager.getStoriesByUserId(userId, filterReviewStatus: false);
    if(result.code != "0000") {
      throw Exception(result.message);
    }
    List<GetStoriesByUserIdResItem> storyList = [];
    for(GetStoriesByUserIdResItem story in result.storyList?? []) {
      if(story.review.status == "processing") {
        storyList.insert(0, story);
      } else {
        storyList.add(story);
      }
    }
    _ref.watch(selfStoryListProvider.notifier).state = storyList;
  }

  Future<void> getStoryCount(String userId) async {
    GetStoryCountRes result = await storyApiManager.getStoryCount(userId);
    if(result.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      throw Exception(result.message);
    }
    _ref.watch(selfStoryCountProvider.notifier).state = result.count!;
  }

  Future<void> getOtherStoryCount(String userId) async {
    GetStoryCountRes result = await storyApiManager.getStoryCount(userId);
    if(result.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      throw Exception(result.message);
    }
    _ref.watch(otherStoryCountProvider.notifier).state = result.count!;
  }

  Future<void> clearStories() async {
    _ref.watch(selfStoryCountProvider.notifier).state = 0;
    _ref.watch(selfStoryListProvider.notifier).state = [];
  }

  Future<void> getOtherUserStories(String userId) async {
    GetStoriesByUserIdRes result = await storyApiManager.getStoriesByUserId(userId, filterReviewStatus: true);
    if(result.code != "0000") {
      throw Exception(result.message);
    }

    if(result.storyList == null) {
      return;
    }
    List<GetStoriesByUserIdResItem> storyList = [];
    for(GetStoriesByUserIdResItem item in result.storyList!) {
      if(item.releaseTime.isAfter(DateTime.now())){
        continue;
      }
      storyList.add(item);
    }
    _ref.watch(otherStoryListProvider.notifier).state = storyList;
  }

  Future<void> archiveStory(String storyId) async {
    _ref.watch(loadingProvider.notifier).state = true;
    ArchiveStoryRes result  = await storyApiManager.archiveStory(storyId);
    if(result.code != "0000") {
      _ref.watch(loadingProvider.notifier).state = false;
      ToastService.showNoticeToast(result.message);
      throw Exception(result.message);
    }

    _ref.watch(selfStoryCountProvider.notifier).state = _ref.watch(selfStoryCountProvider) - 1;
    List<GetStoriesByUserIdResItem> currentStoryList = _ref.watch(selfStoryListProvider)!;
    currentStoryList.removeWhere((story) => story.storyId == storyId);
    _ref.watch(selfStoryListProvider.notifier).state = [...currentStoryList];
    _ref.watch(loadingProvider.notifier).state = false;
  }
}
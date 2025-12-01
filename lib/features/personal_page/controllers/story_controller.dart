import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_story_count_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryController {
  WidgetRef ref;

  StoryController({required this.ref});

  Future<void> getStories(String userId) async {
    GetStoriesByUserIdRes result = await storyApiManager.getStoriesByUserId(userId, filterReviewStatus: false);
    if(result.code != "0000") {
      throw Exception(result.message);
    }
    ref.watch(storyListProvider.notifier).state = result.storyList;
  }

  Future<void> getStoryCount(String userId) async {
    GetStoryCountRes result = await storyApiManager.getStoryCount(userId);
    if(result.code != "0000") {
      throw Exception(result.message);
    }
    ref.watch(storyCountProvider.notifier).state = result.count!;
  }
}

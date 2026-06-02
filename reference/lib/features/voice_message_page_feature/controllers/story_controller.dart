import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/features/voice_message_page_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

class StoryController {
  WidgetRef _ref;

  StoryController(this._ref);

  Future<void> getStoryInfo(String storyId) async {
    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
      print(response.message);
      return;
    }
    _ref.watch(storyInfoProvider.notifier).state = response.story;
  }
}
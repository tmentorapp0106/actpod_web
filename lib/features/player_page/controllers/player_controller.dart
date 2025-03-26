import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerController {
    WidgetRef _ref;

    PlayerController(this._ref);

    Future<void> getStoryInfo(String storyId) async {
        GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
        if(response.code != "0000") {
            return;
        }
        _ref.watch(storyInfoProvider.notifier).state = response.story;
    }
}
import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:actpod_web/api_manager/comment_system_api_manager.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatController {
  WidgetRef _ref;

  StatController(this._ref);

  Future<void> getLikesCount(String storyId) async {
    GetStoryStatRes response = await commentApiManager.getStoryStat(storyId);
    if(response.code != "0000") {
      return;
    }
    _ref.watch(storyStateProvider.notifier).state = response.data;
  }
}
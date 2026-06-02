import 'package:actpod_web/api_manager/recommendation_dto/get_recommendation_res.dart';
import 'package:actpod_web/api_manager/recommendation_system_api_manager.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryController {
  WidgetRef ref;

  StoryController(this.ref);

  Future<void> getRecommendation() async {
    GetRecommendationRes response = await recommendationApiManager.getRecommendationList(1, 20);
    if(response.code != "0000") {
      ToastService.showNoticeToast("找不到內容");
      return;
    }

    List<GetRecommendationResItem>? recommendationList = response.recordList;
    if(recommendationList != null) {
      ref.watch(storiesProvider.notifier).state = StoryInfoDto.fromRecommendationList(recommendationList);
      ref.watch(purchasedStoriesProvider.notifier).state = StoryInfoDto.fromRecommendationList(recommendationList);
    }
  }
}
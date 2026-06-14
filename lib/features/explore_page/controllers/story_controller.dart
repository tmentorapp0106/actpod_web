import 'package:actpod_web/api_manager/purchase_dto/get_purchased_stories.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/api_manager/recommendation_dto/get_recommendation_res.dart';
import 'package:actpod_web/api_manager/recommendation_system_api_manager.dart';
import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryController {
  WidgetRef ref;

  StoryController(this.ref);

  Future<void> init() async {
    GetRecommendationRes recommendationResponse = await recommendationApiManager.getRecommendationList(1, 20);
    if(recommendationResponse.code != "0000") {
      ToastService.showNoticeToast("找不到內容");
      return;
    }

    List<GetRecommendationResItem>? recommendationList = recommendationResponse.recordList;
    if(recommendationList != null) {
      ref.watch(storiesProvider.notifier).state = StoryInfoDto.fromRecommendationList(recommendationList);
    }

    if(AuthService.isLoggedIn()) {
      GetPurchasedStoriesRes purchasedResponse = await storyApiManager.getPurchasedStories();
      if(purchasedResponse.code != "0000") {
        return;
      }
      ref.watch(purchasedStoriesProvider.notifier).state = purchasedResponse.stories;
    } else {
      ref.watch(purchasedStoriesProvider.notifier).state = [];
    }
  }

  Future<void> getPurchasedStories() async {
    GetPurchasedStoriesRes purchasedResponse = await storyApiManager.getPurchasedStories();
      if(purchasedResponse.code != "0000") {
        return;
      }
      ref.watch(purchasedStoriesProvider.notifier).state = purchasedResponse.stories;
  }
}
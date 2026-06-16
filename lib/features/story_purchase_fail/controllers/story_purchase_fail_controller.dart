import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/features/story_purchase_fail/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryPurchaseFailController {
  final WidgetRef ref;

  StoryPurchaseFailController(this.ref);

  Future<void> getStoryInfo(String storyId) async {
    ref.watch(storyPurchaseFailLoadingProvider.notifier).state = true;
    ref.watch(storyPurchaseFailErrorProvider.notifier).state = null;

    try {
      final GetOneStoryRes response =
          await storyApiManager.getOneStory(storyId);
      if (response.code != "0000") {
        ref.watch(storyPurchaseFailErrorProvider.notifier).state =
            response.message;
        ToastService.showNoticeToast("獲取故事資訊失敗");
        return;
      }

      ref.watch(storyPurchaseFailProvider.notifier).state = response.story;
    } catch (e) {
      ref.watch(storyPurchaseFailErrorProvider.notifier).state = e.toString();
      ToastService.showNoticeToast("獲取故事資訊失敗");
    } finally {
      ref.watch(storyPurchaseFailLoadingProvider.notifier).state = false;
    }
  }
}

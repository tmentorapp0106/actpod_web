import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_show_shorts_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/features/shorts_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

class ShortsController {
  WidgetRef ref;

  ShortsController(this.ref);

  Future<void> getShorts() async {
    GetShowShortsRes response = await storyApiManager.getShowShorts();
    if(response.code != "0000") {
      ToastService.showNoticeToast("找不到短片");
      return;
    }
    ref.watch(shortsProvider.notifier).state = response.shorts;
  }
}
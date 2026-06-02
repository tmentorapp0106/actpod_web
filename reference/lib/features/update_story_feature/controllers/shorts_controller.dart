import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/archive_short_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/create_short_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_story_shorts_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/features/update_story_feature/provider.dart';
import 'package:quick_share_app/services/toast_service.dart';

class ShortsController {
  WidgetRef ref;

  ShortsController(this.ref);

  Future<void> getStoryShorts(String storyId) async {
    GetStoryShortsRes storyShortsRes = await storyApiManager.getStoryShorts(storyId);
    if(storyShortsRes.code != "0000") {
      ToastService.showNoticeToast("找不到 shorts");
      return;
    }
    ref.watch(storyShortsProvider.notifier).state = storyShortsRes.shorts;
  }

  Future<void> createStoryShort(String storyId, String videoId) async {
    CreateShortRes createShortRes = await storyApiManager.createShort(storyId, videoId);
    if(createShortRes.code != "0000") {
      ToastService.showNoticeToast("shorts 建立失敗");
      return;
    }
    ToastService.showSuccessToast("成功綁定 shorts");
    getStoryShorts(storyId);
  }

  Future<void> deleteStoryShort(String storyId, String shortId) async {
    ArchiveShortRes archiveShortRes = await storyApiManager.archiveShort(shortId);
    if(archiveShortRes.code != "0000") {
      ToastService.showNoticeToast("shorts 刪除失敗");
      return;
    }
    getStoryShorts(storyId);
  }
}
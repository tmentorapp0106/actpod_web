import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/decrease_likes_res.dart';
import 'package:quick_share_app/apiManagers/comment_system_api_manager.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/comment_api_dto/increase_like_res.dart';
import '../../../apiManagers/comment_api_dto/check_exist_res.dart';
import '../../../apiManagers/comment_api_dto/get_story_stat_res.dart';
import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../providers.dart';

class LikesController {
  WidgetRef _ref;

  LikesController(this._ref);

  Future<void> getCount(String storyId) async {
    GetStoryStatRes response = await commentApiManager.getStoryStat(storyId);
    if(response.code != "0000") {
      _ref.watch(likesCountProvider.notifier).state = 0;
      return;
    }
    _ref.watch(likesCountProvider.notifier).state = response.data.likeCount;
  }

  Future<void> checkExist(String storyId) async {
    if(!UserService.hasLoggedIn()) {
      _ref.watch(likeStatusProvider.notifier).state = false;
      return;
    }
    CheckExistRes response = await commentApiManager.checkLikeExist(storyId, UserService.getUserInfo()!.userId);
    if(response.code != "0000") {
      _ref.watch(likeStatusProvider.notifier).state = false;
    }
    _ref.watch(likeStatusProvider.notifier).state = response.exist;
  }

  Future<void> like(String? storyId, String storyOwnerId) async {
    int count = _ref.watch(likesCountProvider);
    _ref.watch(likeStatusProvider.notifier).state = true;
    _ref.watch(likesCountProvider.notifier).state = count + 1;
    IncreaseLikeRes response = await commentApiManager.increaseLikes(storyId!, UserService.getUserInfo()!.userId, storyOwnerId);
    if(response.code != "0000") {
      _ref.watch(likeStatusProvider.notifier).state = false;
      _ref.watch(likesCountProvider.notifier).state = count;
      ToastService.showNoticeToast(response.code);
    }
  }

  Future<void> withdrawLike(String? storyId) async {
    int count = _ref.watch(likesCountProvider);
    _ref.watch(likeStatusProvider.notifier).state = false;
    _ref.watch(likesCountProvider.notifier).state = count - 1;
    DecreaseLikesRes response = await commentApiManager.decreaseLikes(storyId!, UserService.getUserInfo()!.userId);
    if(response.code != "0000") {
      _ref.watch(likeStatusProvider.notifier).state = true;
      _ref.watch(likesCountProvider.notifier).state = count;
      ToastService.showNoticeToast(response.code);
    }
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/decrease_likes_res.dart';
import 'package:quick_share_app/apiManagers/comment_system_api_manager.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/comment_api_dto/increase_like_res.dart';
import '../../../apiManagers/comment_api_dto/check_exist_res.dart';
import '../../../apiManagers/comment_api_dto/get_story_stat_res.dart';
import '../../../services/user_service.dart';
import '../providers.dart';

class LikesController {
  WidgetRef _ref;
  PlayerItemDto storyInfo;

  LikesController(this._ref, this.storyInfo);

  Future<void> getCount(String storyId) async {
    GetStoryStatRes response = await commentApiManager.getStoryStat(storyId);
    if(response.code != "0000") {
      _ref.watch(storyStateProvider.notifier).state = null;
      return;
    }
    _ref.watch(storyStateProvider.notifier).state = response.data;
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

  Future<void> like(String? storyId) async {
    if(_ref.watch(storyStateProvider) == null) {
      return;
    }
    _ref.watch(likeStatusProvider.notifier).state = true;
    _ref.watch(storyStateProvider.notifier).state = _ref.watch(storyStateProvider)!.copyWith(likeCount: _ref.watch(storyStateProvider)!.likeCount + 1);
    IncreaseLikeRes response = await commentApiManager.increaseLikes(storyId!, UserService.getUserInfo()!.userId, storyInfo.userId);
    if(response.code != "0000") {
      _ref.watch(likeStatusProvider.notifier).state = false;
      ToastService.showNoticeToast(response.code);
    }
  }

  Future<void> withdrawLike(String? storyId) async {
    if(_ref.watch(storyStateProvider) == null) {
      return;
    }
    _ref.watch(likeStatusProvider.notifier).state = false;
    _ref.watch(storyStateProvider.notifier).state = _ref.watch(storyStateProvider)!.copyWith(likeCount: _ref.watch(storyStateProvider)!.likeCount - 1);
    DecreaseLikesRes response = await commentApiManager.decreaseLikes(storyId!, UserService.getUserInfo()!.userId);
    if(response.code != "0000") {
      _ref.watch(likeStatusProvider.notifier).state = true;
      ToastService.showNoticeToast(response.code);
    }
  }
}
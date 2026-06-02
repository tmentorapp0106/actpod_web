import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/space_system_api_manager.dart';
import 'package:quick_share_app/features/space_story_feature/providers.dart';
import 'package:quick_share_app/local_storage/repositories/board_story_repository.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/space_api_dto/get_board_stories_res.dart';
import '../../../dto/space_story_dto.dart';

class SpaceStoryController {
  final WidgetRef _ref;
  int _page = 1;
  bool _noMore = true;
  final _pageSize = 20;

  SpaceStoryController(this._ref);

  Future<void> getSpaceStories(String spaceId) async {
    _ref.watch(loadingProvider.notifier).state = true;
    try {
      GetSpaceStoriesRes response = await spaceApiManager.getSpaceStories(spaceId);
      if(response.code != "0000") {
        ToastService.showNoticeToast(response.message);
        return;
      }

      List<SpaceStoryDto> spaceStoryList = response.spacesInfo;

      if(spaceStoryList.length < _pageSize) {
        _noMore = true;
      } else {
        _noMore = false;
      }
      _ref.watch(spaceStoriesProvider.notifier).state = spaceStoryList;
    } catch(e) {
      print(e);
      _ref.watch(loadingProvider.notifier).state = false;
    }
    _ref.watch(loadingProvider.notifier).state = false;
  }

  Future<void> getMoreSpaceStories(String spaceId) async {
    if(_noMore) {
      return;
    }

    GetSpaceStoriesRes response = await spaceApiManager.getSpaceStories(spaceId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }

    List<SpaceStoryDto> boardStoryList = response.spacesInfo;
    if(boardStoryList.isEmpty) {
      _noMore = true;
      return;
    }
    List<SpaceStoryDto> originList = _ref.watch(spaceStoriesProvider);
    _ref.watch(spaceStoriesProvider.notifier).state = originList + boardStoryList;
  }

  Future<void> syncLocalData(String boardId) async {
    _ref.watch(spaceStoriesProvider.notifier).state = boardStoryRepository.getByBoardId(boardId)?? [];
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/recommendation_system_api_manager.dart';
import 'package:quick_share_app/local_storage/repositories/story_recommendation_repository.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/shared_prefs/dislike_story_prefs.dart';
import 'package:quick_share_app/shared_prefs/hide_prefs.dart';

import '../../../apiManagers/space_system_api_manager.dart';
import '../../../apiManagers/recommendation_api_dto/get_recommendation_res.dart';

import '../../../dto/story_recommendation_dto.dart';
import '../providers.dart';

class RecordWallController {
  WidgetRef ref;
  int _currentRecommendationPage = 1;
  bool hasMoreRecommendations = false;
  final int _pageSize = 20;

  RecordWallController(this.ref);

  Future<void> init() async {
    List<RecommendationItem>? recommendations = storyRecommendationRepository.getAllStoryRecommendations();
    ref.watch(recommendationListProvider.notifier).state = recommendations?? [];
        storyRecommendationRepository.getAllStoryRecommendations()?? [];
  }

  Future<void> getRecords() async {
    GetRecommendationRes recordsRes = await recommendationManager.getRecommendationList(_currentRecommendationPage++, _pageSize);
    if (recordsRes.code != "0000") {
      ToastService.showNoticeToast(recordsRes.message);
    }

    List<RecommendationItem>? recommendationList = recordsRes.recordList
        ?.map((recommendationStory) =>
            RecommendationItem.fromGetRecommendationResItem(
                recommendationStory))
        .toList();

    if(recommendationList == null || recommendationList.length < _pageSize) {
      hasMoreRecommendations = false;
    } else {
      hasMoreRecommendations = true;
    }

    if (recommendationList != null) {
      recommendationList.removeWhere((recommendation) {
        return HidePrefs.contain(recommendation.storyId);
      });
    }
    storyRecommendationRepository.removeAllStoryRecommendations();
    storyRecommendationRepository
        .insertManyStoryRecommendations(recommendationList ?? []);
    if (ref.context.mounted) {
      // async notifier -> prevent using ref after leaving the page
      ref.watch(recommendationListProvider.notifier).state =
          recommendationList ?? [];
    }
  }

  void updateRecommendationVoiceMessageStatus(
      String voiceMessageStatus, int index) {
    List<RecommendationItem> recommendationList =
        ref.watch(recommendationListProvider);
    recommendationList[index].voiceMessageStatus = voiceMessageStatus;
    storyRecommendationRepository.removeAllStoryRecommendations();
    storyRecommendationRepository
        .insertManyStoryRecommendations(recommendationList);
    ref.watch(recommendationListProvider.notifier).state = [
      ...recommendationList
    ];
  }

  //new pagination methods
  Future<void> getMoreRecommendations() async {
    if (!hasMoreRecommendations) {
      return; // Prevent fetching if no more data is available
    }

    GetRecommendationRes recordsRes;
    recordsRes = await recommendationManager
        .getRecommendationList(_currentRecommendationPage++, _pageSize);
    if (recordsRes.code != "0000") {
      ToastService.showNoticeToast(recordsRes.message);
      return;
    }


    List<RecommendationItem>? newRecommendations = recordsRes.recordList
        ?.map((item) => RecommendationItem.fromGetRecommendationResItem(item))
        .toList();

    // Filter out disliked stories, similar to your existing logic
    newRecommendations?.removeWhere((item) =>
        HidePrefs.contain(item.storyId));

    if (newRecommendations != null && newRecommendations.isNotEmpty) {
      // Append new recommendations to existing list
      final existingRecommendations =
          ref.watch(recommendationListProvider.notifier).state;

      // todo: 直接使用 auto play controller 的 audioplayer 的 playlist 去 add
      final updatedList = List<RecommendationItem>.from(existingRecommendations)
        ..addAll(newRecommendations);
      ref.watch(recommendationListProvider.notifier).state = updatedList;
    } else {
      hasMoreRecommendations = false; // No more data to fetch
    }
  }

  Future<void> refreshRecommendations() async {
    _currentRecommendationPage = 1; // Reset to the first page
    hasMoreRecommendations = true; // Assume there are more recommendations to fetch


    GetRecommendationRes recordsRes;
    recordsRes = await recommendationManager
        .getRecommendationList(_currentRecommendationPage++, _pageSize);
    if (recordsRes.code != "0000") {
      ToastService.showNoticeToast(recordsRes.message);
      return;
    }

    List<RecommendationItem>? newRecommendations = recordsRes.recordList
        ?.map((item) => RecommendationItem.fromGetRecommendationResItem(item))
        .toList();

    // Filter out disliked stories, similar to your existing logic
    newRecommendations?.removeWhere((item) =>
    HidePrefs.contain(item.storyId));

    if (newRecommendations != null && newRecommendations.isNotEmpty) {
      ref.watch(recommendationListProvider.notifier).state = newRecommendations;
    } else {
      hasMoreRecommendations = false; // No more data to fetch
    }
  }
}

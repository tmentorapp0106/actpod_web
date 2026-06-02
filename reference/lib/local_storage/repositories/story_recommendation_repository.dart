

import '../../dto/story_recommendation_dto.dart';
import '../../main.dart';
import '../../objectbox.g.dart';

final StoryRecommendationRepository storyRecommendationRepository  = StoryRecommendationRepository(store);

class StoryRecommendationRepository {
  final Store _store;
  Box<RecommendationItem>? _recommendationBox;

  StoryRecommendationRepository(this._store) {
    _recommendationBox = Box<RecommendationItem>(_store);
  }

  int? insertStoryRecommendation(RecommendationItem recommendationItem) {
    return _recommendationBox?.put(recommendationItem);
  }

  List<int>? insertManyStoryRecommendations(List<RecommendationItem> recommendationList) {
    return _recommendationBox?.putMany(recommendationList);
  }


  List<RecommendationItem>? getAllStoryRecommendations() {
    final query = _recommendationBox?.query().order(RecommendationItem_.storyId, flags: Order.descending).build();
    return query?.find();
  }

  int? removeAllStoryRecommendations() {
    return _recommendationBox?.removeAll();
  }

  void updateRecommendationVoiceMessageStatus(String storyId, String voiceMessageStatus) {
    final query = _recommendationBox?.query(RecommendationItem_.storyId.equals(storyId)).build();
    RecommendationItem? recommendationItem = query?.findFirst();
    if(recommendationItem != null) {
      recommendationItem.voiceMessageStatus = voiceMessageStatus;
      _recommendationBox?.put(recommendationItem);
    }
  }

  int? removeByStoryId(String storyId) {
    final query = _recommendationBox?.query(RecommendationItem_.storyId.equals(storyId)).build();
    return query?.remove();
  }
}
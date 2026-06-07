import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExploreRecommendationMode {
  episode,
  package,
}

final storiesProvider =
    StateProvider.autoDispose<List<StoryInfoDto>?>((ref) => null);
final purchasedStoriesProvider =
    StateProvider.autoDispose<List<StoryInfoDto>?>((ref) => null);
final exploreRecommendationModeProvider =
    StateProvider<ExploreRecommendationMode>((ref) {
  return ExploreRecommendationMode.episode;
});

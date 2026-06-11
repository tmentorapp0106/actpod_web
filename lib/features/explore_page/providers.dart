import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExploreRecommendationMode {
  episode,
  package,
}

final storiesProvider =
    StateProvider.autoDispose<List<StoryInfoDto>?>((ref) => null);
final purchasedStoriesProvider =
    StateProvider.autoDispose<List<StoryItem>?>((ref) => null);

final packagesProvider = StateProvider.autoDispose<List<PackageInfoItem>?>((ref) => null);
final exploreRecommendationModeProvider =
    StateProvider<ExploreRecommendationMode>((ref) {
  return ExploreRecommendationMode.episode;
});

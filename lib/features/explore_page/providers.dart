import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storiesProvider = StateProvider.autoDispose<List<StoryInfoDto>?>((ref) => null);
final purchasedStoriesProvider = StateProvider.autoDispose<List<StoryInfoDto>?>((ref) => null);
import 'package:flutter_riverpod/legacy.dart';

import '../../dto/space_story_dto.dart';

final spaceStoriesProvider = StateProvider<List<SpaceStoryDto>>((ref) => []);

final spacePreviewPlayIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final spacePreviewPlayStatusProvider = StateProvider<String>((ref) => "paused"); // playing, paused
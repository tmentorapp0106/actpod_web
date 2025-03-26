import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final likesCountProvider = StateProvider<int>((ref) => 0);
final storyInfoProvider = StateProvider<GetOneStoryResItem?> ((ref) => null);
import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyStateProvider = StateProvider<GetStoryStatResItem?>((ref) => null);
final storyInfoProvider = StateProvider<GetOneStoryResItem?> ((ref) => null);
final playerSpeedTextProvider = StateProvider<String>((ref) => "1.0X");
final audioLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final audioPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final playerStatusProvider = StateProvider<String>((ref) => "preparing");// preparing, ready, playing, paused
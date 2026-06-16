import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyPurchaseFailProvider =
    StateProvider.autoDispose<GetOneStoryResItem?>((ref) => null);
final storyPurchaseFailLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final storyPurchaseFailErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);

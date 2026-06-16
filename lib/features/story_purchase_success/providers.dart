import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyPurchaseSuccessProvider =
    StateProvider.autoDispose<GetOneStoryResItem?>((ref) => null);
final storyPurchaseSuccessLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final storyPurchaseSuccessErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);

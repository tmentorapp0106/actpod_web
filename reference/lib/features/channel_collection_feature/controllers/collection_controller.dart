import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_user_collection_stories_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_user_collections_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/features/channel_collection_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

class CollectionController {
  WidgetRef ref;

  CollectionController(this.ref);

  Future<void> getCollections() async {
    if(!UserService.hasLoggedIn()) {
      ref.watch(collectionListProvider.notifier).state = [];
      return;
    }

    GetUserCollectionRes response = await channelApiManager.getUserCollections();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(collectionListProvider.notifier).state = response.channelCollectionList;
  }

  Future<void> getCollectionStories() async {
    if(!UserService.hasLoggedIn()) {
      ref.watch(collectionStoryListProvider.notifier).state = [];
      return;
    }

    GetUserCollectionStoriesRes response = await channelApiManager.getUserCollectionStories();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(collectionStoryListProvider.notifier).state = response.collectionStoryList;
  }
}
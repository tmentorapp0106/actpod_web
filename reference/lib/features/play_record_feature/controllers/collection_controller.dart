import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apiManagers/channel_api_dto/create_collection_res.dart';
import '../../../apiManagers/channel_api_dto/delete_collection_res.dart';
import '../../../apiManagers/channel_api_dto/exist_collection_res.dart';
import '../../../apiManagers/channel_system_api_manager.dart';
import '../../../services/toast_service.dart';
import '../../../services/user_service.dart';
import '../providers.dart';

class CollectionController {
  WidgetRef ref;

  CollectionController(this.ref);

  Future<void> checkCollected(String channelId) async {
    if(!UserService.hasLoggedIn()) {
      ref.watch(isCollectedProvider.notifier).state = CollectStatus.notLogin;
      return;
    }
    ExistCollectionRes response = await channelApiManager.existChannelCollection(channelId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(isCollectedProvider.notifier).state = response.exist? CollectStatus.collected : CollectStatus.notCollected;
  }

  Future<void> createCollection(String channelId) async {
    ref.watch(isCollectedProvider.notifier).state = null;
    CreateCollectionRes response = await channelApiManager.createChannelCollection(channelId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    checkCollected(channelId);
  }

  Future<void> deleteCollection(String channelId) async {
    ref.watch(isCollectedProvider.notifier).state = null;
    DeleteCollectionRes response = await channelApiManager.deleteChannelCollection(channelId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    checkCollected(channelId);
  }
}
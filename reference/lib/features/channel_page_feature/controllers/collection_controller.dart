import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/create_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/delete_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/exist_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

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
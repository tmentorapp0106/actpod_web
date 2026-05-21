import 'package:actpod_web/api_manager/channel_api_manager.dart';
import 'package:actpod_web/api_manager/channel_dto/create_collection_res.dart';
import 'package:actpod_web/api_manager/channel_dto/delete_collection_res.dart';
import 'package:actpod_web/api_manager/channel_dto/exist_collection_res.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionController {
  WidgetRef ref;

  CollectionController(this.ref);

  Future<void> checkCollected(String channelId) async {
    if(!AuthService.isLoggedIn()) {
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
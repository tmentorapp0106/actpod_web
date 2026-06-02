import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

class PodcastStoreController {
  WidgetRef ref;

  PodcastStoreController(this.ref);

  Future<void> getPodcastStore(String userId) async {
    GetPodcastStoreRes response = await channelApiManager.getPodcastStore(userId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(podcastStoreProvider.notifier).state = response.podcastStoreDto;
  }
}
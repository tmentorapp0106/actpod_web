import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/notification_api_dto/get_active_announcement_res.dart';
import 'package:quick_share_app/apiManagers/notification_system_api_manager.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/shared_prefs/announcement_prefs.dart';

class AnnouncementController {
  final WidgetRef _ref;

  AnnouncementController(this._ref);

  Future<void> init() async {
    List<String> bannerImages = [];
    GetActiveAnnouncementRes response = await notificationApiManager.getActiveAnnouncements();
    if(response.code != "0000") {
      _ref.watch(bannerUrlProvider.notifier).state = [];
    }
    for(int i = 0; i < response.announcements.length; i++) {
      bannerImages.add(response.announcements[i].bannerImageUrl);
    }
    _ref.watch(bannerUrlProvider.notifier).state = bannerImages;
  }
}
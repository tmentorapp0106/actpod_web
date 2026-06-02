import 'package:quick_share_app/apiManagers/notification_api_dto/get_active_announcement_res.dart';
import 'package:quick_share_app/apiManagers/notification_system_api_manager.dart';
import 'package:quick_share_app/shared_prefs/announcement_prefs.dart';

class AnnouncementService {
  static Future<void> loadAnnouncements() async {
    GetActiveAnnouncementRes response = await notificationApiManager.getActiveAnnouncements();
    if(response.code == "0000") {
      List<String>? announcementUrls = response.announcements?.map((announcement) => announcement.bannerImageUrl).toList();
      if(announcementUrls == null || announcementUrls.isEmpty) {
        AnnouncementPrefs.setAnnouncements([]);
        return;
      }
      AnnouncementPrefs.setAnnouncements(announcementUrls);
    }
  }
}
import 'package:dio/dio.dart';

import 'abstractApiManager.dart';
import 'notification_api_dto/get_active_announcement_res.dart';

final notificationApiManager = NotificationApiManager(systemName: "NOTIFICATION_SERVER_URL");

class NotificationApiManager extends AbstractApiManager {

  NotificationApiManager({required String systemName}) : super(systemName: systemName);

  Future<void> insertToken(String userId, String? fcmToken) async {
    if(fcmToken == null) {
      return;
    }
    var postData = {
      "userId": userId,
      "fcmToken": fcmToken
    };

    await handelPostWithUserToken("/notification/fcmToken/insert", postData);
  }

  Future<void> removeToken(String userId, String? fcmToken) async {
    if(fcmToken == null) {
      return;
    }
    var postData = {
      "userId": userId,
      "fcmToken": fcmToken,
    };

    await handelPostWithUserToken("/notification/fcmToken/remove", postData);
  }

  Future<GetActiveAnnouncementRes> getActiveAnnouncements() async {
    Response response = await handelGet("/announcement/active");
    return GetActiveAnnouncementRes.fromJson(response.data);
  }
}
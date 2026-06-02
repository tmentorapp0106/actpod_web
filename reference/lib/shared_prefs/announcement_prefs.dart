import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool?> setAnnouncements(List<String> announcementUrls) async {
    return await prefs?.setStringList("announcementUrls", announcementUrls);
  }

  static List<String>? getAnnouncements() {
    return prefs?.getStringList("announcementUrls");
  }
}
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static String? getTutorialReadStats() {
    return prefs?.getString("tutorialReadStats");
  }

  static Future<bool?> setTutorialReadStats(String tutorialReadStats) async {
    return await prefs?.setString("tutorialReadStats", tutorialReadStats);
  }
}
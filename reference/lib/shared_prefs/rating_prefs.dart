import 'package:shared_preferences/shared_preferences.dart';

class RatingPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static bool? alreadyRated() {
    return prefs?.getBool("alreadyRated");
  }

  static Future<bool?> setRated(bool rated) async {
    return await prefs?.setBool("alreadyRated", rated);
  }
}
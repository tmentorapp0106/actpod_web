import 'package:shared_preferences/shared_preferences.dart';

class DislikeStoryPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static List<String>? getStoryIdList() {
    return prefs?.getStringList("dislikeStoryList");
  }

  static Future<bool?> addStory(String storyId) async {
    List<String>? storyList = prefs?.getStringList("dislikeStoryList");
    if(storyList == null) {
      return await prefs?.setStringList("dislikeStoryList", [storyId]);
    }

    if(!storyList.contains(storyId)) {
      storyList.add(storyId);
    }
    return await prefs?.setStringList("dislikeStoryList", storyList);
  }
}
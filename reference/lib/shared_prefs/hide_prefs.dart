import 'package:shared_preferences/shared_preferences.dart';

class HidePrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static List<String> getHiddenIdList() {
    return prefs?.getStringList("hiddenIdList")?? [];
  }

  static Future<bool?> addId(String id) async {
    List<String>? storyList = prefs?.getStringList("hiddenIdList");
    if(storyList == null) {
      return await prefs?.setStringList("hiddenIdList", [id]);
    }

    if(!storyList.contains(id)) {
      storyList.add(id);
    }
    return await prefs?.setStringList("hiddenIdList", storyList);
  }

  static bool contain(String id) {
    List<String>? idList = prefs?.getStringList("hiddenIdList");
    if(idList == null) {
      return false;
    }
    return idList.contains(id);
  }

  static Future<bool?> removeId(String id) async {
    List<String>? idList = prefs?.getStringList("hiddenIdList");
    if(idList == null) {
      return true;
    }

    if(!idList.contains(id)) {
      return true;
    }
    idList.remove(id);
    return await prefs?.setStringList("hiddenIdList", idList);
  }
}
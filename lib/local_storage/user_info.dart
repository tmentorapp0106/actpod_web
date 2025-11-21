import 'dart:convert';
import 'package:web/web.dart';

import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static SharedPreferences? prefs;
  static const _keyUserInfo = 'userInfo';

  static Future<void> setUserInfo(UserInfoDto? userInfo) async {
    if (userInfo == null) {
      window.localStorage.removeItem(_keyUserInfo);
      return;
    }
    final jsonStr = jsonEncode(userInfo); 
    window.localStorage.setItem(_keyUserInfo, jsonStr);
  }

  static UserInfoDto? getUserInfo() {
    final userInfoJsonStr = window.localStorage.getItem(_keyUserInfo);
    if (userInfoJsonStr == null || userInfoJsonStr.isEmpty) {
      return null;
    }
    return UserInfoDto.fromJson(jsonDecode(userInfoJsonStr));
  }

  static Future<bool?> cleanUser() async {
    window.localStorage.removeItem(_keyUserInfo);
    return true;
  }
}
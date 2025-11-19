import 'dart:convert';

import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static String? getUserToken() {
    return prefs?.getString("userToken");
  }

  static Future<bool?> setUserToken(String userToken) async {
    return await prefs?.setString("userToken", userToken);
  }

  static Future<bool?> setUserInfo(UserInfoDto? userInfo) async {
    return await prefs?.setString("userInfo", jsonEncode(userInfo?? {}));
  }

  static UserInfoDto? getUserInfo() {
    String? userInfoJsonStr = prefs?.getString("userInfo");
    if(userInfoJsonStr == null || userInfoJsonStr == "") {
      return null;
    }

    return UserInfoDto.fromJson(jsonDecode(userInfoJsonStr));
  }

  static Future<bool?> cleanUser() async {
    await prefs?.setString("userInfo", "");
    await prefs?.setString("userToken", "");
    await prefs?.setString("refreshToken", "");
    await prefs?.setString("membership", "");
    return true;
  }
}
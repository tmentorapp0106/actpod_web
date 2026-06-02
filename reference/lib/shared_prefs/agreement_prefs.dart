import 'package:shared_preferences/shared_preferences.dart';

class AgreementPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static bool? getContentPolicyAgreement() {
    return prefs?.getBool("contentPolicyAgreement");
  }

  static Future<bool?> setContentPolicyAgreement(bool agreement) async {
    return await prefs?.setBool("contentPolicyAgreement", agreement);
  }
}
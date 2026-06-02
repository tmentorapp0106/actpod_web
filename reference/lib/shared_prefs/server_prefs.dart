import 'package:shared_preferences/shared_preferences.dart';

class ServerPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static String? getServer() {
    return prefs?.getString("serverConfig");
  }

  static Future<bool?> setServer(ServerOption server) async {
    return await prefs?.setString("serverConfig", server.name);
  }

  static Future<bool?> setServerByServerName(String serverName) async {
    return await prefs?.setString("serverConfig", serverName);
  }
}

enum ServerOption {
  Asia,
  USA
}
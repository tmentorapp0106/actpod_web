import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quick_share_app/shared_prefs/server_prefs.dart';

class EnvService {
  static Future<void> load() async {
    String? serverSetting = ServerPrefs.getServer();
    await dotenv.load(fileName: "config/server_tw.env");

    if(serverSetting == null) {
      await dotenv.load(fileName: "config/server_tw.env");
    }
  }
}
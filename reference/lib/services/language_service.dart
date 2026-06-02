import 'package:flutter/material.dart';

import '../shared_prefs/server_prefs.dart';

class LanguageService {
  static Locale loadLanguage() {
    String? serverSetting = ServerPrefs.getServer();
    if(serverSetting == ServerOption.Asia.name) {
      return const Locale('zh');
    } else {
      return const Locale('en');
    }
  }
}
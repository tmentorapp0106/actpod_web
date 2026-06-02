import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecordBackupPrefs {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static String? getBackupPath() {
    return prefs?.getString("recordBackupPath");
  }

  static List<double>? getBackupWaveformData() {
    final jsonString = prefs?.getString("backupWaveformData");
    if (jsonString == null) return null;

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => e as double).toList();
  }

  static int? getBackupLength() {
    return prefs?.getInt("backupAudioLength");
  }

  static Future<bool?> setBackupPath(String backupPath) async {
    return await prefs?.setString("recordBackupPath", backupPath);
  }

  static Future<bool?> setBackupWaveformData(List<double> waveformData) async {
    final jsonString = jsonEncode(waveformData); // Convert list to JSON string
    return await prefs?.setString("backupWaveformData", jsonString);
  }

  static Future<bool?> setBackupLength(int durationMilliSec) async {
    return await prefs?.setInt("backupAudioLength", durationMilliSec);
  }
}
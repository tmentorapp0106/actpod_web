import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class EnvService {
  static Future<void> load() async {
    await dotenv.load(fileName: "config/server_tw.env");
  }
}
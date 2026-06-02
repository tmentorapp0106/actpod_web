import 'dart:io';

import 'package:flutter/services.dart';
class AudioFixUtil {
  static const MethodChannel _channel = MethodChannel('com.sharevoice/audio');

  static Future<void> resetToMediaVolume() async {
    if(!Platform.isAndroid) {
      return;
    }
    try {
      await _channel.invokeMethod('resetAudioMode');
    } catch (e) {
      print('Failed to reset audio mode: $e');
    }
  }
}
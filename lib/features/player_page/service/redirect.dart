

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web; 

import 'package:url_launcher/url_launcher.dart';

class RedirectService {
  static Future<void> toDownload(String? storyId) async {
    if(storyId == null) {
      return;
    }
    await Future.delayed(const Duration(microseconds: 500));
    String url = "https://actpod-488af.web.app/story/link/$storyId?openExternalBrowser=1";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
    // String url;
    // if (kIsWeb) {
    //   final userAgent = web.window.navigator.userAgent.toLowerCase();
    //   if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
    //     url = 'https://apps.apple.com/tw/app/actpod/id6468426325'; // iOS App Store link
    //   } else if (userAgent.contains('android')) {
    //     url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1'; // Android Play Store
    //   } else {
    //     url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1'; // Fallback for desktop web
    //   }
    // } else {
    //   if (Platform.isIOS) {
    //     url = 'https://apps.apple.com/tw/app/actpod/id6468426325';
    //   } else if (Platform.isAndroid) {
    //     url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1';
    //   } else {
    //     url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1';
    //   }
    // }

    // // Launch the URL
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    // } else {
    //   debugPrint("Could not launch $url");
    // }
  }
}
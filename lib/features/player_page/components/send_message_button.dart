import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/player_controller.dart';
import 'dart:html' as html;

class SendMessageButton extends ConsumerWidget {
  final PlayerController _playerController;

  SendMessageButton(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return InkWell(
      onTap: () async {
        String url;
        if (kIsWeb) {
          final userAgent = html.window.navigator.userAgent.toLowerCase();
          if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
            url = 'https://apps.apple.com/tw/app/actpod/id6468426325'; // iOS App Store link
          } else if (userAgent.contains('android')) {
            url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1'; // Android Play Store
          } else {
            url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1'; // Fallback for desktop web
          }
        } else {
          if (Platform.isIOS) {
            url = 'https://apps.apple.com/tw/app/actpod/id6468426325';
          } else if (Platform.isAndroid) {
            url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1';
          } else {
            url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1';
          }
        }

        // Launch the URL
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      },
      child: Row(
        children: [
          Image.asset(
            "assets/icons/send_voice_message.png",
            width: 20.w,
            height: 20.w,
            fit: BoxFit.fitWidth,
          ),
          Text(
            "傳送留言",
            style: TextStyle(
              fontSize: 12.w
            ),
          )
        ]
      )
    );
  }
}
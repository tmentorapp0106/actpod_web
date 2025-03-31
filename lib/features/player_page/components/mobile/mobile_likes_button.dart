import 'dart:io';

import 'package:actpod_web/components/dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

import '../../providers.dart';


class MobileLikesButton extends ConsumerWidget {
  MobileLikesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
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
          Icon(
            Icons.favorite_border_outlined,
            color: Colors.grey,
            size: 18.w,
          ),
          SizedBox(width: 2.w,),
          Text(
            ref.watch(likesCountProvider).toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.w
            ),
          )
        ]
      )
    );
  }
}
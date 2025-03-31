import 'package:actpod_web/design_system/shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileDownloadBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h, left: 20.w, right: 20.w),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          colors: [
            Color(0xFFfeeabb),
            Color(0xFFfff3d6), // medium blue
            Color(0xFFfef9ec), // darker blue
            Color(0xFFfefefe), // deepest blue
          ],
          stops: [0.0, 0.15, 0.70, 1.0], // 4 color stops
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: DesignShadow.shadow,
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                "下載 APP 收聽更多內容",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h,),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      String url = 'https://apps.apple.com/tw/app/actpod/id6468426325';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        debugPrint("Could not launch $url");
                      }
                    },
                    child: Image.asset(
                      "assets/images/apple_download.png",
                      width: 120.w,
                      fit: BoxFit.fitWidth,
                    )
                  ),
                  SizedBox(width: 40.w,),
                  InkWell(
                    onTap: () async {
                      String url = 'https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        debugPrint("Could not launch $url");
                      }
                    },
                    child: Image.asset(
                      "assets/images/google_download.png",
                      width: 128.w,
                      fit: BoxFit.fitWidth,
                    )
                  )
                ],
              )
            ],
          )
        ]
      )
    );
  }
}
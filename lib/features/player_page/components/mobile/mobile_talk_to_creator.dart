import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/service/redirect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class MobileTalkToCreator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent, // need a Material ancestor for ripples
        child: InkWell(
          borderRadius: BorderRadius.circular(10.w),
          splashFactory: InkRipple.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed)
                ? DesignColor.primary500.withOpacity(0.10)
                : null,
          ),
          onTap: () async {
            RedirectService.toDownload();
          },
          child: Ink( // Ink paints decoration so ripple is clipped correctly
            decoration: BoxDecoration(
              border: Border.all(color: DesignColor.primary500),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/voice_message.svg",
                    color: DesignColor.primary500,
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "跟創作者對話",
                    style: TextStyle(
                      color: DesignColor.primary500,
                      fontSize: 14.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
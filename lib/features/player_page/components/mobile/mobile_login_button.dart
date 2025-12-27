import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/login/provider.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileLoginButton extends ConsumerWidget {
  final PlayerController playerController;

  MobileLoginButton(this.playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userInfoProvider) != null ? userInfo(ref) : loginButton(context, ref );
  }

  Widget userInfo(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(null, ref.watch(userInfoProvider)?.avatarUrl, 20.w),
          SizedBox(width: 2.w,),
          Text(
            ref.watch(userInfoProvider)?.nickname ?? "",
            style: TextStyle(
              fontSize: 12.w,
              color: DesignColor.neutral90
            ),
          )
        ],
      )
    );
  }

  Widget loginButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return LoginScreen();
          }
        );
        if(ref.watch(storyInfoProvider)?.isPremium ?? false) {
          playerController.checkPaid(ref.watch(storyInfoProvider)!.storyId);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          "登入",
          style: TextStyle(
            fontSize: 12.w,
            color: DesignColor.primary50
          ),
        )
      ),
    );
  }
}
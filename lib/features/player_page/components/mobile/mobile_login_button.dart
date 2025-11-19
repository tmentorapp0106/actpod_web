import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UserPrefs.getUserInfo() != null ? userInfo() : loginButton(context);
  }

  Widget userInfo() {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(null, UserPrefs.getUserInfo()?.avatarUrl, 20.w),
          SizedBox(width: 2.w,),
          Text(
            UserPrefs.getUserInfo()?.nickname ?? "",
            style: TextStyle(
              fontSize: 12.w,
              color: DesignColor.neutral90
            ),
          )
        ],
      )
    );
  }

  Widget loginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return LoginScreen();
          }
        );
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
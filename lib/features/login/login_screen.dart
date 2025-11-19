import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/login/provider.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(20.w)
        )
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 15.h),
                  Text(
                    "ActPod 為您締造聲音的連結",
                    style: TextStyle(
                      fontSize: 14.sp
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  ref.watch(loginLoadingProvider)? CircularProgressIndicator(color: DesignColor.primary50,) : loginButton(ref, context),
                  SizedBox(height: 15.h),
                ]
              )
            ]
          ),
          Positioned(
            top: 10.h,
            left: 10.w,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close_rounded
              )
            ),
          )
        ],
      )
    );
  }

  Widget loginButton(WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: ref.watch(loginLoadingProvider)? null : () async {
            ref.watch(loginLoadingProvider.notifier).state = true;
            await AuthService().signInWithGoogle();
            ref.watch(loginLoadingProvider.notifier).state = false;
            if(context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: 240.w,
            padding: EdgeInsets.only(top: 9.h, bottom: 9.h),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(20.w),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/google-logo.png",
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(width: 15.w,),
                Text(
                  "Google 登入",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
          )
        ),
        SizedBox(height: 10.h,),
        InkWell(
          onTap: () {
            // _handleAppleLogIn();
          },
          child: Container(
            width: 240.w,
            padding: EdgeInsets.only(top: 9.h, bottom: 9.h),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(20.w),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/apple-logo.png",
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(width: 15.w,),
                Text(
                  "Apple 登入",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
          )
        ),
      ],
    );
  }
}
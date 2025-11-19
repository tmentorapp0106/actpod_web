import 'package:actpod_web/api_manager/user_api_manager.dart';
import 'package:actpod_web/features/login/provider.dart';
import 'package:actpod_web/router.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isPhone? mobile() : web(ref)
    );
  }

  Widget web(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            width: 140.w,
          ),
          SizedBox(height: 20.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/apple_download.png",
                width: 60.w,
              ),
              SizedBox(width: 12.w,),
              Image.asset(
                "assets/images/google_download.png",
                width: 66.w,
              ),
              InkWell(
                onTap: () async {
                  ref.watch(loginLoadingProvider.notifier).state = true;
                  await AuthService().signInWithGoogle();
                  ref.watch(loginLoadingProvider.notifier).state = false;
                },
                child: Text("google login"),
              ),
              InkWell(
                onTap: () async {
                  final cred = await AuthService().signInWithApple();
                  final idToken = await cred?.user?.getIdToken();
                  // await userApiManager.thirdPartyCreateUserOrLogin(idToken, "", "");
                  // myRouter.go("/story");
                },
                child: Text("apple login"),
              )
            ],
          )
        ]
      )
    );
  }

  Widget mobile() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            width: 260.w,
          ),
          SizedBox(height: 12.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/apple_download.png",
                width: 100.w,
              ),
              SizedBox(width: 12.w,),
              Image.asset(
                "assets/images/google_download.png",
                width: 108.w,
              ),
            ],
          )
        ]
      )
    );
  }
}
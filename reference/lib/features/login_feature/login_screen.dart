import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quick_share_app/apiManagers/notification_system_api_manager.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/providers.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../apiManagers/purchase_system_api_manager.dart';
import '../../services/preload_service.dart';
import '../../services/user_service.dart';
import '../user_info_feature/providers.dart';

class LoginPageScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPageScreen> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends ConsumerState<LoginPageScreen> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  Future<void> _handleGoogleSignIn() async {
    ref.watch(loadingProvider.notifier).state = true;
    try {
      final account = await googleSignIn.signIn();
      if(account != null) {
        String nickname = account.displayName?? account.email.split("@")[0];
        final googleAuth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken
        );
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await userCredential.user?.getIdToken();
        loginInfo = await UserService.thirdPartyCreateUserOrLogin(idToken?? "", account.email, nickname);
        ref.watch(loginStatusProvider.notifier).state = true;
        await UserService.loadUserInfo(ref);

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        notificationApiManager.insertToken(UserService.getUserInfo()!.userId, fcmToken);
        PurchaseSystemApi.login(UserService.getUserInfo()!.userId);
        await PreloadService.loadData(ref);
        ref.watch(loadingProvider.notifier).state = false;
        Navigator.of(context).pop();
      }
      ref.watch(loadingProvider.notifier).state = false;
    } catch (error) {
      ref.watch(loadingProvider.notifier).state = false;
      print("Google sign in failed: $error");
    }
  }

  Future<void> _handleAppleLogIn() async {
    ref.watch(loadingProvider.notifier).state = true;
    /// Can find in the following link: https://developer.apple.com/account/resources/identifiers/list/serviceId (put service id -> identifier)
    try {
      String clientID = 'app.actpod';
      String redirectURL = 'https://applelogin.actpodapp.com/callbacks/sign_in_with_apple';

      final rawNonce = _generateNonce();

      /// We are convering that rawNonce into SHA256 for security purposes
      /// In our login.
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(

        /// Scopes are the values that you are requiring from
        /// Apple Server.
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: Platform.isIOS ? nonce : null,

        /// We are providing Web Authentication for Android Login,
        /// Android uses web browser based login for Apple.
        webAuthenticationOptions: Platform.isIOS
            ? null
            : WebAuthenticationOptions(
          clientId: clientID,
          redirectUri: Uri.parse(redirectURL),
        ),
      );

      final AuthCredential appleAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: Platform.isIOS ? rawNonce : null,
        accessToken: Platform.isIOS ? appleCredential.authorizationCode : appleCredential.authorizationCode,
      );

      /// Once you are successful in generating Apple Credentials,
      /// We pass them into the Firebase function to finally sign in.
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(appleAuthCredential);
      if(userCredential.user != null) {
        ref.watch(loadingProvider.notifier).state = true;
        String nickname = userCredential.user!.displayName?? userCredential.user!.email!.split("@")[0];
        String? idToken = await userCredential.user!.getIdToken();
        loginInfo = await UserService.thirdPartyCreateUserOrLogin(idToken?? "", userCredential.user!.email, nickname);
        await UserService.loadUserInfo(ref);
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        notificationApiManager.insertToken(UserService.getUserInfo()!.userId, fcmToken);
        PurchaseSystemApi.login(UserService.getUserInfo()!.userId);
        await PreloadService.loadData(ref);
        ref.watch(loginStatusProvider.notifier).state = true;
        ref.watch(loadingProvider.notifier).state = false;
        Navigator.of(context).pop();
      }
      ref.watch(loadingProvider.notifier).state = false;
    } catch(e) {
      ref.watch(loadingProvider.notifier).state = false;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) =>
    charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
        // contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
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
                    InkWell(
                      onTap: () {
                        _handleGoogleSignIn();
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
                        _handleAppleLogIn();
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
      )
    );
  }

}
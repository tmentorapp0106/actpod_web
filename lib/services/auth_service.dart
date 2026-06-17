import 'package:actpod_web/api_manager/user_api_manager.dart';
import 'package:actpod_web/api_manager/user_dto/create_login.dart';
import 'package:actpod_web/api_manager/user_dto/get_user_info.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  bool get _shouldUseRedirect {
    if (!kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  Future<UserInfoDto?> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..addScope('email'); // optional

    try {
      if (_shouldUseRedirect) {
        await _auth.signInWithRedirect(provider);
        return null;
      }

      // best UX on web
      final userCredential = await _auth.signInWithPopup(provider);
      return syncFirebaseUser(userCredential.user);
    } catch (_) {}
    return null;
  }

  Future<UserInfoDto?> signInWithApple() async {
    final provider = OAuthProvider('apple.com')
      ..addScope('name')
      ..addScope('email');

    try {
      if (_shouldUseRedirect) {
        await _auth.signInWithRedirect(provider);
        return null;
      }

      final userCredential = await _auth.signInWithPopup(provider);
      return syncFirebaseUser(userCredential.user);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<UserInfoDto?> syncFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }

    CreateNewUserRes res = await userApiManager.thirdPartyCreateUserOrLogin(
      await firebaseUser.getIdToken(),
      firebaseUser.email,
      firebaseUser.displayName,
    );
    if (res.code != "0000") {
      throw (res.message);
    }
    CookieUtils.setCookie(
      "userToken",
      res.data?.userToken ?? "",
      expires: DateTime.now().add(const Duration(hours: 6)),
    );

    GetUserInfoRes userInfoRes = await userApiManager.getUserInfo();
    if (userInfoRes.code != "0000") {
      throw (userInfoRes.message);
    }

    UserPrefs.setUserInfo(userInfoRes.userInfo);
    return userInfoRes.userInfo;
  }

  static Future<UserInfoDto?> restoreFirebaseLogin() async {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

    try {
      await FirebaseAuth.instance.getRedirectResult();
    } catch (_) {}

    await FirebaseAuth.instance.authStateChanges().first;
    return syncFirebaseUser(FirebaseAuth.instance.currentUser);
  }

  static bool isLoggedIn() {
    String? userToken = CookieUtils.getCookie("userToken");
    if (userToken != null && userToken != "") {
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await UserPrefs.cleanUser();
    await FirebaseAuth.instance.signOut();
    CookieUtils.deleteCookie("userToken");
  }
}

import 'package:actpod_web/api_manager/user_api_manager.dart';
import 'package:actpod_web/api_manager/user_dto/create_login.dart';
import 'package:actpod_web/api_manager/user_dto/get_user_info.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserInfoDto?> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email'); // optional

    try {
      // best UX on web
      final userCredential = await _auth.signInWithPopup(provider);
      CreateNewUserRes res = await userApiManager.thirdPartyCreateUserOrLogin(
        await userCredential.user?.getIdToken(), 
        userCredential.user?.email, 
        userCredential.user?.displayName,
      );
      if(res.code != "0000") {
        throw(res.message);
      }
      CookieUtils.setCookie("userToken", res.data?.userToken?? "", expires: DateTime.now().add(const Duration(hours: 6)));

      GetUserInfoRes userInfoRes = await userApiManager.getUserInfo();
      if(userInfoRes.code != "0000") {
        throw(userInfoRes.message);
      } else {
        UserPrefs.setUserInfo(userInfoRes.userInfo);
        return userInfoRes.userInfo;
      }
    } catch (_) {
    }
    return null;
  }

  Future<UserInfoDto?> signInWithApple() async {
    final provider = OAuthProvider('apple.com')
      ..addScope('name')..addScope('email');

    try {
      final userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      CreateNewUserRes res = await userApiManager.thirdPartyCreateUserOrLogin(
        await userCredential.user?.getIdToken(), 
        userCredential.user?.email, 
        userCredential.user?.displayName,
      );
      if(res.code != "0000") {
        throw(res.message);
      }
      CookieUtils.setCookie("userToken", res.data?.userToken?? "", expires: DateTime.now().add(const Duration(hours: 6)));

      GetUserInfoRes userInfoRes = await userApiManager.getUserInfo();
      if(userInfoRes.code != "0000") {
        throw(userInfoRes.message);
      } else {
        UserPrefs.setUserInfo(userInfoRes.userInfo);
        return userInfoRes.userInfo;
      }
    } catch (e) {
      print(e);
    }
  }
}
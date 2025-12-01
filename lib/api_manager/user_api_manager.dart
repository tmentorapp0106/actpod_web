import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/user_dto/create_login.dart';
import 'package:actpod_web/api_manager/user_dto/get_user_info.dart';
import 'package:dio/dio.dart';

final userApiManager = UserApiManager(systemName: "USER_SERVER_URL");

class UserApiManager extends AbstractApiManager {
  UserApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateNewUserRes> thirdPartyCreateUserOrLogin(String? firebaseToken, String? email, String? nickname) async {
    var postData = {
      "firebaseToken": firebaseToken?? "",
      "thirdPartyEmail": email?? "",
      "thirdPartyNickname": nickname?? ""
    };

    Response response = await handelPost("/signupOrLoginWithThirdParty/v2", postData);

    return CreateNewUserRes.fromJson(response.data);
  }

  Future<GetUserInfoRes> getUserInfo() async {
    Response response = await handelGetWithUserToken("");
    return GetUserInfoRes.fromJson(response.data);
  }

  Future<GetUserInfoRes> getOthersUserInfo(String userId) async {
    Response response = await handelGet("/$userId");
    return GetUserInfoRes.fromJson(response.data);
  }
}
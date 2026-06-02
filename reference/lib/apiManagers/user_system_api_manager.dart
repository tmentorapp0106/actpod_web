import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/report_api_dto/create_report_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/block_user_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/create_new_user_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_app_version_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_block_users_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_member_level_infos_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_member_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_union_code_by_code_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_union_code_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_user_info_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/remove_account_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/remove_block_user_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/search_user_res.dart';

import '../services/user_service.dart';
import 'abstractApiManager.dart';

final userApiManager = UserApiManager(systemName: "USER_SERVER_URL");

class UserApiManager extends AbstractApiManager {

  UserApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateNewUserRes> thirdPartyCreateUserOrLogin(String firebaseToken, String? email, String nickname) async {
    var postData = {
      "firebaseToken": firebaseToken,
      "thirdPartyEmail": email,
      "thirdPartyNickname": nickname
    };

    Response response = await handelPost("/signupOrLoginWithThirdParty/v2", postData);

    return CreateNewUserRes.fromJson(response.data);
  }

  Future<CreateNewUserRes> emailSignup(String email, String password, String nickname) async {
    var postData = {
      "email": email,
      "password": password,
      "nickname": nickname
    };

    Response response = await handelPost("/signupWithEmail", postData);

    return CreateNewUserRes.fromJson(response.data);
  }

  Future<CreateNewUserRes> emailLogin(String email, String password) async {
    var postData = {
      "email": email,
      "password": password
    };

    Response response = await handelPost("/loginByEmail", postData);

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

  Future<void> changeUserAvatar(File imageFile) async {
    String userId = UserService.getUserInfo()!.userId;
    var formData = FormData.fromMap({"userAvatar": await MultipartFile.fromFile(imageFile.path)});
    var resp = await handelPatchWithUserToken("/$userId/avatar", formData);
  }

  Future<void> editUserInfo(String username, String nickname, String email, String gender, String selfDescription) async {
    String userId = UserService.getUserInfo()!.userId;
    var postData = {
      "username": username,
      "nickname": nickname,
      "gender": gender,
      "email": email,
      "selfDescription": selfDescription
    };

    await handelPatchWithUserToken("/$userId", postData);
  }

  Future<RemoveAccountRes> removeAccount() async {
    var postData = {
      "userId": UserService.getUserInfo()!.userId
    };

    Response response = await handelPost("/archive/", postData);
    return RemoveAccountRes.fromJson(response.data);
  }

  Future<GetAppVersionRes> getAppVersion() async {
    Response response = await handelGet("/appVersion/");
    return GetAppVersionRes.fromJson(response.data);
  }

  Future<SearchUserRes> searchUser(String nickname) async {
    var postData = {
      "nickname": nickname,
    };

    Response response = await handelPost("/search", postData);
    return SearchUserRes.fromJson(response.data);
  }

  Future<GetMemberRes> getMembership() async {
    Response response = await handelGetWithUserToken("/membership");
    return GetMemberRes.fromJson(response.data);
  }

  Future<GetMemberLevelInfosRes> getMembershipLevelInfos() async {
    Response response = await handelGet("/membership/level/info");
    return GetMemberLevelInfosRes.fromJson(response.data);
  }
  
  Future<GetUnionCodeRes> getUnionCode() async {
    Response response = await handelGetWithUserToken("/membership/unionCode");
    return GetUnionCodeRes.fromJson(response.data);
  }

  Future<GetUnionCodeByCodeRes> getUnionCodeByCode(String code) async {
    Response response = await handelGet("/membership/unionCode/code/$code");
    return GetUnionCodeByCodeRes.fromJson(response.data);
  }

  Future<CreateReportRes> createReport(String targetName, String email, String reason, String desc) async {
    var postData = {
      "targetName": targetName,
      "reportingUserEmail": email,
      "reason": reason,
      "description": desc
    };

    Response response = await handelPostWithUserToken("/report", postData);

    return CreateReportRes.fromJson(response.data);
  }
  
  Future<BlockUserRes> blockUser(String blockedUserId) async {
    var data = {
      "blockedUserId": blockedUserId
    };
    Response response = await handelPostWithUserToken("/blockUser", data);
    return BlockUserRes.fromJson(response.data);
  }

  Future<RemoveBlockUserRes> removeBlockUser(String blockedUserId) async {
    var data = {
      "blockedUserId": blockedUserId
    };
    Response response = await handelPostWithUserToken("/blockUser/remove", data);
    return RemoveBlockUserRes.fromJson(response.data);
  }
  
  Future<GetBlockUsersRes> getBlockedUsers() async {
    Response response = await handelGetWithUserToken("/blockUser");
    return GetBlockUsersRes.fromJson(response.data);
  }
}
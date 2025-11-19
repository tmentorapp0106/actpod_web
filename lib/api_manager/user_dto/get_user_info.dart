

import 'package:actpod_web/dto/user_info_dto.dart';

class GetUserInfoRes {
  String code;
  String message;
  UserInfoDto? userInfo;

  GetUserInfoRes(this.code, this.message, this.userInfo);

  factory GetUserInfoRes.fromJson(Map<String, dynamic> json) {
    UserInfoDto? userInfo = json["code"] == "0000"? UserInfoDto.fromJson(json["data"]) : null;
    return GetUserInfoRes(json["code"], json["message"], userInfo);
  }
}
import '../../dto/user_info_dto.dart';

class GetBlockUsersRes {
  String code;
  String message;
  List<UserInfoDto> userInfoList;

  GetBlockUsersRes(this.code, this.message, this.userInfoList);

  factory GetBlockUsersRes.fromJson(Map<String, dynamic> json) {
    return GetBlockUsersRes(json["code"], json["message"], (json["data"] as List).map((item) => UserInfoDto.fromJson(item)).toList());
  }
}
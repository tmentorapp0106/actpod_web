import '../../dto/user_info_dto.dart';

class SearchUserRes {
  String code;
  String message;
  List<UserInfoDto>? userInfoList;

  SearchUserRes(this.code, this.message, this.userInfoList);

  factory SearchUserRes.fromJson(Map<String, dynamic> json) {
    List<UserInfoDto>? userInfoList = json["code"] == "0000" && json["data"] != null
        ? (json["data"] as List).map((e) => UserInfoDto.fromJson(e)).toList()
        : null;

    return SearchUserRes(json["code"], json["message"], userInfoList);
  }
}
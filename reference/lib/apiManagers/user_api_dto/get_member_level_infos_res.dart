import 'package:quick_share_app/dto/membership_level_info_dto.dart';

class GetMemberLevelInfosRes {
  String code;
  String message;
  List<MembershipLevelInfoDto>? membershipLevelInfo;

  GetMemberLevelInfosRes(this.code, this.message, this.membershipLevelInfo);

  factory GetMemberLevelInfosRes.fromJson(Map<String, dynamic> json) {
    List<MembershipLevelInfoDto>? membershipLevelInfo = json["code"] == "0000"
        ? (json["data"] as List).map((item) => MembershipLevelInfoDto.fromJson(item)).toList()
        : null;

    return GetMemberLevelInfosRes(
      json["code"] ?? "",
      json["message"] ?? "",
      membershipLevelInfo,
    );
  }
}
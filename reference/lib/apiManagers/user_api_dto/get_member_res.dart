import '../../dto/membership_dto.dart';

class GetMemberRes {
  String code;
  String message;
  MembershipDto? memberInfo;

  GetMemberRes(this.code, this.message, this.memberInfo);

  factory GetMemberRes.fromJson(Map<String, dynamic> json) {
    MembershipDto? memberInfo = json["code"] == "0000"
        ? MembershipDto.fromJson(json["data"])
        : null;
    return GetMemberRes(
      json["code"] ?? "",
      json["message"] ?? "",
      memberInfo,
    );
  }
}
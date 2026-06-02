import 'package:quick_share_app/dto/union_code_dto.dart';

class GetUnionCodeByCodeRes {
  String code;
  String message;
  UnionCodeDto? unionCodeDto;

  GetUnionCodeByCodeRes(this.code, this.message, this.unionCodeDto);

  factory GetUnionCodeByCodeRes.fromJson(Map<String, dynamic> json) {
    UnionCodeDto? unionCode = json["code"] == "0000"
        ? UnionCodeDto.fromJson(json["data"])
        : null;
    return GetUnionCodeByCodeRes(
      json["code"] ?? "",
      json["message"] ?? "",
      unionCode,
    );
  }
}
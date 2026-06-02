import '../../dto/union_code_dto.dart';

class GetUnionCodeRes {
  String code;
  String message;
  UnionCodeDto? unionCodeDto;

  GetUnionCodeRes(this.code, this.message, this.unionCodeDto);

  factory GetUnionCodeRes.fromJson(Map<String, dynamic> json) {
    UnionCodeDto? unionCode = json["code"] == "0000"
        ? UnionCodeDto.fromJson(json["data"])
        : null;
    return GetUnionCodeRes(
      json["code"] ?? "",
      json["message"] ?? "",
      unionCode,
    );
  }
}
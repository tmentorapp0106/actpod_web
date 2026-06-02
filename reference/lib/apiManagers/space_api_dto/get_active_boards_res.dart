import '../../dto/space_dto.dart';

class GetActiveSpacesRes {
  String code;
  String message;
  List<SpaceInfoDto>? spaces;

  GetActiveSpacesRes(this.code, this.message, this.spaces);

  factory GetActiveSpacesRes.fromJson(Map<String, dynamic> json) {
    return GetActiveSpacesRes(
      json["code"],
      json["message"],
      json["data"]?.map<SpaceInfoDto>((json) => SpaceInfoDto.fromJson(json)).toList()
    );
  }
}
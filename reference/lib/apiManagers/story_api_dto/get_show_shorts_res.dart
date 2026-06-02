import 'package:quick_share_app/dto/short_dto.dart';

class GetShowShortsRes {
  String code;
  String message;
  List<ShowShortDto> shorts;

  GetShowShortsRes(this.code, this.message, this.shorts);

  factory GetShowShortsRes.fromJson(Map<String, dynamic> json) {
    List<ShowShortDto> shorts = json["data"] == null? [] : json["data"]?.map<ShowShortDto>((json) => ShowShortDto.fromJson(json)).toList();
    return GetShowShortsRes(json["code"], json["message"], shorts);
  }
}
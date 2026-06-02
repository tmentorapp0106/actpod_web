import 'package:quick_share_app/dto/short_dto.dart';

class GetStoryShortsRes {
  String code;
  String message;
  List<ShortDto> shorts;

  GetStoryShortsRes(this.code, this.message, this.shorts);

  factory GetStoryShortsRes.fromJson(Map<String, dynamic> json) {
    List<ShortDto> shorts = json["data"] == null? [] : json["data"]?.map<ShortDto>((json) => ShortDto.fromJson(json)).toList();
    return GetStoryShortsRes(json["code"], json["message"], shorts);
  }
}
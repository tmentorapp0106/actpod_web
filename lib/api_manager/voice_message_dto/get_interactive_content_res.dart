import 'package:actpod_web/dto/interactive_content_dto.dart';

class GetInteractiveContentRes {
  String code;
  String message;
  GetInteractiveContentResData? data;

  GetInteractiveContentRes(this.code, this.message, this.data);

  factory GetInteractiveContentRes.fromJson(Map<String, dynamic> json) {
    return GetInteractiveContentRes(json["code"], json["message"], GetInteractiveContentResData.fromJson(json["data"]));
  }
}

class GetInteractiveContentResData {
  bool exist;
  InteractiveContentDto? interactiveContentDto;

  GetInteractiveContentResData(
    this.exist,
    this.interactiveContentDto
  );

  factory GetInteractiveContentResData.fromJson(Map<String, dynamic> json) {
    return GetInteractiveContentResData(
      json["exist"],
      json["exist"]? InteractiveContentDto.fromJson(json["interactiveContent"]) : null
    );
  }
}
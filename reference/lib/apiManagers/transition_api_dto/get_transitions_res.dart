import 'package:quick_share_app/dto/transition_dto.dart';

class GetTransitionListRes {
  String code;
  String message;
  List<TransitionDto> transitionList;

  GetTransitionListRes(
      this.code,
      this.message,
      this.transitionList
  );

  factory GetTransitionListRes.fromJson(Map<String, dynamic> json) {
    return GetTransitionListRes(
      json["code"],
      json["message"],
      (json["data"] as List<dynamic>?)
          ?.map((item) => TransitionDto.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
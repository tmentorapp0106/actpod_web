import '../../dto/draft_dto.dart';

class GetUserDraftRes {
  String code;
  String message;
  List<DraftDto>? drafts;

  GetUserDraftRes(this.code, this.message, this.drafts);

  factory GetUserDraftRes.fromJson(Map<String, dynamic> json) {
    return GetUserDraftRes(json["code"], json["message"], json["data"] != null
        ? (json["data"] as List<dynamic>)
        .map((item) => DraftDto.fromJson(item))
        .toList()
        : null);
  }
}

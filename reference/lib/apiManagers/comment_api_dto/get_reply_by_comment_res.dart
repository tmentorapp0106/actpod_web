import 'package:quick_share_app/dto/reply_dto.dart';

class GetReplyByCommentRes {
  String code;
  String message;
  List<ReplyInfoDto>? replyList;

  GetReplyByCommentRes(this.code, this.message, this.replyList);

  factory GetReplyByCommentRes.fromJson(Map<String, dynamic> json) {
    List<ReplyInfoDto> replyList = json["data"] == null? [] : json["data"].map<ReplyInfoDto>( (json) => ReplyInfoDto.fromJson(json) ).toList();
    return GetReplyByCommentRes(json["code"], json["message"], replyList);
  }
}

class GetInstantReplyByCommentRes {
  String code;
  String message;
  List<InstantReplyInfoDto>? replyList;

  GetInstantReplyByCommentRes(this.code, this.message, this.replyList);

  factory GetInstantReplyByCommentRes.fromJson(Map<String, dynamic> json) {
    List<InstantReplyInfoDto> replyList = json["data"] == null? [] : json["data"].map<InstantReplyInfoDto>( (json) => InstantReplyInfoDto.fromJson(json) ).toList();
    return GetInstantReplyByCommentRes(json["code"], json["message"], replyList);
  }
}
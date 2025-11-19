import 'package:actpod_web/dto/reply_dto.dart';

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
import 'package:actpod_web/dto/comment_dto.dart';

class GetCommentListRes {
  String code;
  String message;
  GetCommentListResData? commentInfo;

  GetCommentListRes(this.code, this.message, this.commentInfo);

  factory GetCommentListRes.fromJson(Map<String, dynamic> json) {
    if(json["data"] == null) {
      return GetCommentListRes(json["code"], json["message"], null);
    } else {
      return GetCommentListRes(json["code"], json["message"], GetCommentListResData.fromJson(json["data"]));
    }
  }
}

class GetCommentListResData {
  List<CommentInfoDto> commentList;
  int totalCount;

  GetCommentListResData(this.commentList, this.totalCount);

  factory GetCommentListResData.fromJson(Map<String, dynamic> json) {
    List<CommentInfoDto> commentList = json["commentList"] == null? [] : json["commentList"].map<CommentInfoDto>( (json) => CommentInfoDto.fromJson(json) ).toList();
    return GetCommentListResData(commentList, json["totalCount"]);
  }
}

class GetInstantCommentListRes {
  String code;
  String message;
  GetInstantCommentListResData? commentInfo;

  GetInstantCommentListRes(this.code, this.message, this.commentInfo);

  factory GetInstantCommentListRes.fromJson(Map<String, dynamic> json) {
    if(json["data"] == null) {
      return GetInstantCommentListRes(json["code"], json["message"], null);
    } else {
      return GetInstantCommentListRes(json["code"], json["message"], GetInstantCommentListResData.fromJson(json["data"]));
    }
  }
}

class GetInstantCommentListResData {
  List<InstantCommentInfoDto> commentList;
  int totalCount;

  GetInstantCommentListResData(this.commentList, this.totalCount);

  factory GetInstantCommentListResData.fromJson(Map<String, dynamic> json) {
    List<InstantCommentInfoDto> commentList = json["commentList"] == null? [] : json["commentList"].map<InstantCommentInfoDto>( (json) => InstantCommentInfoDto.fromJson(json) ).toList();
    return GetInstantCommentListResData(commentList, json["totalCount"]);
  }
}
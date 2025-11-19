import 'package:actpod_web/dto/comment_dto.dart';

class GetStoryStatRes {
  String code;
  String message;
  GetStoryStatResItem data;

  GetStoryStatRes(this.code, this.message, this.data);

  factory GetStoryStatRes.fromJson(Map<String, dynamic> json) {
    return GetStoryStatRes(
        json["code"],
        json["message"],
        GetStoryStatResItem.fromJson(json["data"])
    );
  }
}

class GetStoryStatResItem {
  String storyId;
  String userId;
  int instantCommentCount;
  int commentCount;
  int likeCount;
  CommentInfoDto? showedComment;

  GetStoryStatResItem(this.storyId, this.userId, this.instantCommentCount, this.commentCount, this.likeCount, this.showedComment);

  factory GetStoryStatResItem.fromJson(Map<String, dynamic> json) {
    return GetStoryStatResItem(
      json["storyId"],
      json["userId"],
      json["instantCommentCount"],
      json["commentCount"],
      json["likeCount"],
      json["showedComment"] == null? null : CommentInfoDto.fromJson(json["showedComment"])
    );
  }

  static const Object _sentinel = Object();

  GetStoryStatResItem copyWith({
    String? storyId,
    String? userId,
    int? instantCommentCount,
    int? commentCount,
    int? likeCount,
    Object? showedComment = _sentinel, // pass null to clear, omit to keep
  }) {
    return GetStoryStatResItem(
      storyId ?? this.storyId,
      userId ?? this.userId,
      instantCommentCount ?? this.instantCommentCount,
      commentCount ?? this.commentCount,
      likeCount ?? this.likeCount,
      showedComment == _sentinel
          ? this.showedComment
          : showedComment as CommentInfoDto?, // allows explicit null
    );
  }
}
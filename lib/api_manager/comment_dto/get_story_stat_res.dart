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
  int commentCount;
  int likeCount;
  CommentInfoDto? showedComment;

  GetStoryStatResItem(this.storyId, this.userId, this.commentCount, this.likeCount, this.showedComment);

  factory GetStoryStatResItem.fromJson(Map<String, dynamic> json) {
    return GetStoryStatResItem(
      json["storyId"],
      json["userId"],
      json["commentCount"],
      json["likeCount"],
      json["showedComment"] == null? null : CommentInfoDto.fromJson(json["showedComment"])
    );
  }
}

class CommentInfoDto {
  String commentId;
  String userId;
  String content;
  int replyCount;
  int sendTiming;
  DateTime commentTime;
  String commentType;
  String stickerUrl;
  String avatarUrl;
  String username;
  String nickname;
  String gender;
  String email;
  String selfDescription;
  int podcoins;

  CommentInfoDto(
      this.commentId,
      this.userId,
      this.content,
      this.replyCount,
      this.sendTiming,
      this.commentTime,
      this.commentType,
      this.stickerUrl,
      this.avatarUrl,
      this.username,
      this.nickname,
      this.gender,
      this.email,
      this.selfDescription,
      this.podcoins
      );

  factory CommentInfoDto.fromJson(Map<String, dynamic> json) {
    return CommentInfoDto(
        json["commentInfo"]["commentId"],
        json["commentInfo"]["userId"],
        json["commentInfo"]["content"],
        json["commentInfo"]["replyCount"],
        json["commentInfo"]["sendTiming"],
        DateTime.parse(json["commentInfo"]["commentTime"]),
        json["commentInfo"]["commentType"],
        json["commentInfo"]["stickerUrl"],
        json["userInfo"]["avatarUrl"],
        json["userInfo"]["username"],
        json["userInfo"]["nickname"],
        json["userInfo"]["gender"],
        json["userInfo"]["email"],
        json["userInfo"]["selfDescription"],
      json["commentInfo"]["podcoins"]?? 0
    );
  }
}
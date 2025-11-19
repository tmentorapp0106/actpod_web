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

class InstantCommentInfoDto {
  String commentId;
  String userId;
  String content;
  int replyCount;
  int sendSecond;
  int podcoins;
  String avatarUrl;
  String username;
  String nickname;
  String gender;
  String email;
  String selfDescription;

  InstantCommentInfoDto(
    this.commentId,
    this.userId,
    this.content,
    this.replyCount,
    this.sendSecond,
    this.podcoins,
    this.avatarUrl,
    this.username,
    this.nickname,
    this.gender,
    this.email,
    this.selfDescription
  );

  factory InstantCommentInfoDto.fromJson(Map<String, dynamic> json) {
    return InstantCommentInfoDto(
      json["commentInfo"]["commentId"],
      json["commentInfo"]["userId"],
      json["commentInfo"]["content"],
      json["commentInfo"]["replyCount"],
      json["commentInfo"]["sendSecond"],
      json["commentInfo"]["podcoins"]?? 0,
      json["userInfo"]["avatarUrl"],
      json["userInfo"]["username"],
      json["userInfo"]["nickname"],
      json["userInfo"]["gender"],
      json["userInfo"]["email"],
      json["userInfo"]["selfDescription"]
    );
  }
}
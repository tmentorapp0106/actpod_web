class ReplyInfoDto {
  String replyId;
  String commentId;
  String userId;
  String replyType;
  String content;
  DateTime replyTime;
  String avatarUrl;
  String username;
  String nickname;
  String gender;
  String email;
  String selfDescription;

  ReplyInfoDto(
    this.replyId,
    this.commentId,
    this.userId,
    this.replyType,
    this.content,
    this.replyTime,
    this.avatarUrl,
    this.username,
    this.nickname,
    this.gender,
    this.email,
    this.selfDescription
  );

  factory ReplyInfoDto.fromJson(Map<String, dynamic> json) {
    return ReplyInfoDto(
      json["replyInfo"]["replyId"],
      json["replyInfo"]["commentId"],
      json["replyInfo"]["userId"],
      json["replyInfo"]["replyType"],
      json["replyInfo"]["content"],
      DateTime.parse(json["replyInfo"]["replyTime"]),
      json["userInfo"]["avatarUrl"],
      json["userInfo"]["username"],
      json["userInfo"]["nickname"],
      json["userInfo"]["gender"],
      json["userInfo"]["email"],
      json["userInfo"]["selfDescription"]
    );
  }
}
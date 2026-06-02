class CreateReplyRes {
  String code;
  String message;

  CreateReplyRes(this.code, this.message);

  factory CreateReplyRes.fromJson(Map<String, dynamic> json) {
    return CreateReplyRes(
        json["code"],
        json["message"]
    );
  }
}

class CreateInstantReplyRes {
  String code;
  String message;
  String? replyId;

  CreateInstantReplyRes(this.code, this.message, this.replyId);

  factory CreateInstantReplyRes.fromJson(Map<String, dynamic> json) {
    return CreateInstantReplyRes(
      json["code"],
      json["message"],
      json["replyId"]
    );
  }
}
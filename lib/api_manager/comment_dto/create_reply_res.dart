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
class CreateCommentRes {
  String code;
  String message;
  String commentId;

  CreateCommentRes(this.code, this.message, this.commentId);

  factory CreateCommentRes.fromJson(Map<String, dynamic> json) {
    return CreateCommentRes(json["code"], json["message"], json["data"]);
  }
}
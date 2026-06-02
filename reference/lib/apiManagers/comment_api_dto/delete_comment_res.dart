class DeleteCommentRes {
  String code;
  String message;

  DeleteCommentRes(this.code, this.message);

  factory DeleteCommentRes.fromJson(Map<String, dynamic> json) {
    return DeleteCommentRes(
        json["code"],
        json["message"]
    );
  }
}
class DeleteTransitionRes {
  String code;
  String message;

  DeleteTransitionRes(this.code, this.message);

  factory DeleteTransitionRes.fromJson(Map<String, dynamic> json) {
    return DeleteTransitionRes(json["code"], json["message"]);
  }
}
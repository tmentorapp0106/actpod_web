class DeleteDraftRes {
  String code;
  String message;

  DeleteDraftRes(this.code, this.message);

  factory DeleteDraftRes.fromJson(Map<String, dynamic> json) {
    return DeleteDraftRes(json["code"], json["message"]);
  }
}
class CreateDraftRes {
  String code;
  String message;

  CreateDraftRes(this.code, this.message);

  factory CreateDraftRes.fromJson(Map<String, dynamic> json) {
    return CreateDraftRes(json["code"], json["message"]);
  }
}
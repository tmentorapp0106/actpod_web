class CreateShortRes {
  String code;
  String message;

  CreateShortRes(this.code, this.message);

  factory CreateShortRes.fromJson(Map<String, dynamic> json) {
    return CreateShortRes(json["code"], json["message"]);
  }
}
class UpdateSpaceRes {
  String code;
  String message;

  UpdateSpaceRes(this.code, this.message);

  factory UpdateSpaceRes.fromJson(Map<String, dynamic> json) {
    return UpdateSpaceRes(json["code"], json["message"]);
  }
}
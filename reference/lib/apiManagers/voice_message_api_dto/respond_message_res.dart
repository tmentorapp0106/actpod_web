class RespondMessageRes {
  String code;
  String message;
  String responseContentUrl;

  RespondMessageRes(this.code, this.message, this.responseContentUrl);

  factory RespondMessageRes.fromJson(Map<String, dynamic> json) {
    return RespondMessageRes(json["code"], json["message"], json["data"]);
  }
}
class UpdateChannelRes {
  String code;
  String message;

  UpdateChannelRes(this.code, this.message);

  factory UpdateChannelRes.fromJson(Map<String, dynamic> json) {
    return UpdateChannelRes(json["code"], json["message"]);
  }
}
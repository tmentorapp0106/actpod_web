class DeleteChannelRes {
  String code;
  String message;

  DeleteChannelRes(this.code, this.message);

  factory DeleteChannelRes.fromJson(Map<String, dynamic> json) {
    return DeleteChannelRes(json["code"], json["message"]);
  }
}
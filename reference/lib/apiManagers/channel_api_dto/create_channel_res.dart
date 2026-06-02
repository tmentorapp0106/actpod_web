class CreateChannelRes {
  String code;
  String message;
  String channelId;

  CreateChannelRes(this.code, this.message, this.channelId);

  factory CreateChannelRes.fromJson(Map<String, dynamic> json) {
    return CreateChannelRes(json["code"], json["message"], json["data"] ?? "");
  }
}
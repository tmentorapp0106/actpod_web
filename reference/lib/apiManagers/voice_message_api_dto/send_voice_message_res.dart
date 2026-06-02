class SendVoiceMessageRes {
  String code;
  String message;
  String messageId;

  SendVoiceMessageRes(this.code, this.message, this.messageId);

  factory SendVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    return SendVoiceMessageRes(json["code"], json["message"], json["data"]);
  }
}
class UpdateVoiceMessageStatus {
  String code;
  String message;

  UpdateVoiceMessageStatus(this.code, this.message);

  factory UpdateVoiceMessageStatus.fromJson(Map<String, dynamic> json) {
    return UpdateVoiceMessageStatus(json["code"], json["message"]);
  }
}
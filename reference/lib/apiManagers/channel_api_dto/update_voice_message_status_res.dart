class UpdateVoiceMessageStatusRes {
  String code;
  String message;

  UpdateVoiceMessageStatusRes(this.code, this.message);

  factory UpdateVoiceMessageStatusRes.fromJson(Map<String, dynamic> json) {
    return UpdateVoiceMessageStatusRes(json["code"], json["message"]);
  }
}
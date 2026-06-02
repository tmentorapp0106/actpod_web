class UpdateVoiceMessageStatRes {
  String code;
  String message;

  UpdateVoiceMessageStatRes(this.code, this.message);

  factory UpdateVoiceMessageStatRes.fromJson(Map<String, dynamic> json) {
    return UpdateVoiceMessageStatRes(json["code"], json["message"]);
  }
}
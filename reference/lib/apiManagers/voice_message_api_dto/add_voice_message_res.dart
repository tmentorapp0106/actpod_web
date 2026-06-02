class AddVoiceMessageRes {
  String code;
  String message;

  AddVoiceMessageRes(this.code, this.message);

  factory AddVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    return AddVoiceMessageRes(json["code"], json["message"]);
  }
}
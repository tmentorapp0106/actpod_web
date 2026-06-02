class TranscribeVoiceMessageRes {
  String code;
  String message;
  String text;

  TranscribeVoiceMessageRes(this.code, this.message, this.text);

  factory TranscribeVoiceMessageRes.fromJson(Map<String, dynamic> json) {
    return TranscribeVoiceMessageRes(json["code"], json["message"], json["data"]);
  }
}
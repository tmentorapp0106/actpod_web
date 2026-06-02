class CreateAudioRes {
  String code;
  String message;

  CreateAudioRes(this.code, this.message);

  factory CreateAudioRes.fromJson(Map<String, dynamic> json) {
    return CreateAudioRes(json["code"], json["message"]);
  }
}
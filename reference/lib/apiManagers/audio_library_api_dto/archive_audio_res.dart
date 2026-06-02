class ArchiveAudioRes {
  String code;
  String message;

  ArchiveAudioRes(this.code, this.message);

  factory ArchiveAudioRes.fromJson(Map<String, dynamic> json) {
    return ArchiveAudioRes(json["code"], json["message"]);
  }
}
class ArchiveStoryRes {
  String code;
  String message;

  ArchiveStoryRes(this.code, this.message);

  factory ArchiveStoryRes.fromJson(Map<String, dynamic> json) {
    return ArchiveStoryRes(json["code"], json["message"]);
  }
}
class ArchiveShortRes {
  String code;
  String message;

  ArchiveShortRes(this.code, this.message);

  factory ArchiveShortRes.fromJson(Map<String, dynamic> json) {
    return ArchiveShortRes(json["code"], json["message"]);
  }
}
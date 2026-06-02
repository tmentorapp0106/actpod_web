class UploadByRssFeedRes {
  String code;
  String message;

  UploadByRssFeedRes(this.code, this.message);

  factory UploadByRssFeedRes.fromJson(Map<String, dynamic> json) {
    return UploadByRssFeedRes(json["code"], json["message"]);
  }
}
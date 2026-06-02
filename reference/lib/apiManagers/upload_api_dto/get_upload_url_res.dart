class GetUploadUrlRes {
  String code;
  String message;
  UploadUrl? data;

  GetUploadUrlRes(this.code, this.message, [this.data]);

  factory GetUploadUrlRes.fromJson(Map<String, dynamic> json) {
    return GetUploadUrlRes(
      json["code"] as String,
      json["message"] as String,
      json["data"] != null ? UploadUrl.fromJson(json["data"]) : null,
    );
  }
}

class UploadUrl {
  String signedUrl;
  String publicUrl;

  UploadUrl(this.signedUrl, this.publicUrl);

  factory UploadUrl.fromJson(Map<String, dynamic> json) {
    return UploadUrl(
      json["signedUrl"] as String,
      json["publicUrl"] as String,
    );
  }
}
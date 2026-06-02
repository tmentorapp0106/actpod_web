class ShareRes {
  String code;
  String message;

  ShareRes(this.code, this.message);

  factory ShareRes.fromJson(Map<String, dynamic> json) {
    return ShareRes(json["code"], json["message"]);
  }
}
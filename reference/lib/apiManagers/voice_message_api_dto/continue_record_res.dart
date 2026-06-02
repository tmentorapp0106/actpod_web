class ContinueRecordRes {
  String code;
  String message;

  ContinueRecordRes(this.code, this.message);

  factory ContinueRecordRes.fromJson(Map<String, dynamic> json) {
    return ContinueRecordRes(json["code"], json["message"]);
  }
}
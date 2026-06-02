class ManualSyncRes {
  String code;
  String message;

  ManualSyncRes(this.code, this.message);

  factory ManualSyncRes.fromJson(Map<String, dynamic> json) {
    return ManualSyncRes(json["code"], json["message"]);
  }
}
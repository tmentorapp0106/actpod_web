class FirstSyncRes {
  String code;
  String message;

  FirstSyncRes(this.code, this.message);

  factory FirstSyncRes.fromJson(Map<String, dynamic> json) {
    return FirstSyncRes(json["code"], json["message"]);
  }
}
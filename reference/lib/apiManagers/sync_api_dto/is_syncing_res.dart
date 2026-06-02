class IsSyncingRes {
  String code;
  String message;
  bool isSyncing;

  IsSyncingRes(this.code, this.message, this.isSyncing);

  factory IsSyncingRes.fromJson(Map<String, dynamic> json) {
    return IsSyncingRes(json["code"], json["message"], json["data"]);
  }
}
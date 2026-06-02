class ExistSyncSettingRes {
  String code;
  String message;
  bool? data;

  ExistSyncSettingRes(this.code, this.message, this.data);

  factory ExistSyncSettingRes.fromJson(Map<String, dynamic> json) {
    return ExistSyncSettingRes(json["code"], json["message"], json["data"]?? true);
  }
}
class UpdateSyncSettingRes {
  String code;
  String message;

  UpdateSyncSettingRes(this.code, this.message);

  factory UpdateSyncSettingRes.fromJson(Map<String, dynamic> json) {
    return UpdateSyncSettingRes(json["code"], json["message"]);
  }
}
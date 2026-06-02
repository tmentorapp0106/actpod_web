class RemoveSyncSettingRes {
  String code;
  String message;

  RemoveSyncSettingRes(this.code, this.message);

  factory RemoveSyncSettingRes.fromJson(Map<String, dynamic> json) {
    return RemoveSyncSettingRes(json["code"], json["message"]);
  }
}
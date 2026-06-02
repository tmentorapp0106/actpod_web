import 'package:quick_share_app/dto/sync_setting.dart';

class GetSyncSettingRes {
  String code;
  String message;
  SyncSettingDto? syncSetting;

  GetSyncSettingRes(this.code, this.message, this.syncSetting);

  factory GetSyncSettingRes.fromJson(Map<String, dynamic> json) {
    return GetSyncSettingRes(
      json["code"], 
      json["message"],
      json["data"] == null? null : SyncSettingDto.fromJson(json["data"])
    );
  }
}
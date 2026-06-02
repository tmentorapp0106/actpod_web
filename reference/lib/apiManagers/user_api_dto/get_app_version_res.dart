class GetAppVersionRes {
  String code;
  String message;
  AppVersion? version;

  GetAppVersionRes(this.code, this.message, this.version);

  factory GetAppVersionRes.fromJson(Map<String, dynamic> json) {
    return GetAppVersionRes(json["code"], json["message"], json["data"] == null? null : AppVersion.fromJson(json["data"]));
  }
}

class AppVersion {
  String androidAppVersion;
  String iosAppVersion;

  AppVersion(this.androidAppVersion, this.iosAppVersion);

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(json["androidAppVersion"], json["iosAppVersion"]);
  }
}
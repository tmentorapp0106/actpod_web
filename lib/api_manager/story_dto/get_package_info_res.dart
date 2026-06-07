import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/dto/package_dto.dart';

class GetPackageInfoRes {
  String code;
  String message;
  PackageInfoWithStoriesItem packageInfo;

  GetPackageInfoRes(this.code, this.message, this.packageInfo);

  factory GetPackageInfoRes.fromJson(Map<String, dynamic> json) {
    return GetPackageInfoRes(
      json["code"],
      json["message"],
      PackageInfoWithStoriesItem.fromJson(json["data"]),
    );
  }
}
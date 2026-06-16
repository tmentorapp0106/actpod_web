import 'package:actpod_web/dto/package_dto.dart';

class FindUserPurchaseRecordsRes {
  String code;
  String message;
  List<PurchaseRecordInfoItem> records;

  FindUserPurchaseRecordsRes(this.code, this.message, this.records);

  factory FindUserPurchaseRecordsRes.fromJson(Map<String, dynamic> json) {
    return FindUserPurchaseRecordsRes(
      _string(json["code"]),
      _string(json["message"]),
      (json["data"] as List<dynamic>?)
              ?.map((e) => PurchaseRecordInfoItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PurchaseRecordInfoItem {
  PackageInfoWithStoriesItem? packageInfo;
  StoryInfoItem? storyInfo;

  PurchaseRecordInfoItem(
    this.packageInfo,
    this.storyInfo,
  );

  factory PurchaseRecordInfoItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return PurchaseRecordInfoItem(
      json["packageInfo"] == null
          ? null
          : PackageInfoWithStoriesItem.fromJson(json["packageInfo"]),
      json["storyInfo"] == null
          ? null
          : StoryInfoItem.fromJson(json["storyInfo"]),
    );
  }
}

String _string(dynamic value) {
  if (value == null) return "";
  return value.toString();
}

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

class PurchaseRecordInfoItem extends PurchaseRecordItem {
  PurchaseRecordPackageInfoItem? packageInfo;
  StoryInfoItem? storyInfo;

  PurchaseRecordInfoItem(
    super.userId,
    super.packageId,
    super.storyId,
    super.priceId,
    super.archive,
    super.updateTime,
    super.createTime,
    this.packageInfo,
    this.storyInfo,
  );

  factory PurchaseRecordInfoItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return PurchaseRecordInfoItem(
      _string(json["userId"]),
      _string(json["packageId"]),
      _string(json["storyId"]),
      _string(json["priceId"]),
      _bool(json["archive"]),
      _dateTime(json["updateTime"]),
      _dateTime(json["createTime"]),
      json["packageInfo"] == null
          ? null
          : PurchaseRecordPackageInfoItem.fromJson(json["packageInfo"]),
      json["storyInfo"] == null
          ? null
          : StoryInfoItem.fromJson(json["storyInfo"]),
    );
  }
}

class PurchaseRecordItem {
  String userId;
  String packageId;
  String storyId;
  String priceId;
  bool archive;
  DateTime updateTime;
  DateTime createTime;

  PurchaseRecordItem(
    this.userId,
    this.packageId,
    this.storyId,
    this.priceId,
    this.archive,
    this.updateTime,
    this.createTime,
  );
}

class PurchaseRecordPackageInfoItem {
  String packageId;
  String userId;
  String packageName;
  String packageDescription;
  String packageImageUrl;
  DateTime createTime;
  DateTime updateTime;
  String nickname;
  String avatarUrl;
  PackagePriceItem? price;
  List<StoryInfoItem> stories;

  PurchaseRecordPackageInfoItem(
    this.packageId,
    this.userId,
    this.packageName,
    this.packageDescription,
    this.packageImageUrl,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.avatarUrl,
    this.price,
    this.stories,
  );

  factory PurchaseRecordPackageInfoItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return PurchaseRecordPackageInfoItem(
      _string(json["packageId"]),
      _string(json["userId"]),
      _string(json["packageName"]),
      _string(json["packageDescription"]),
      _string(json["packageImageUrl"]),
      _dateTime(json["createTime"]),
      _dateTime(json["updateTime"]),
      _string(json["nickname"]),
      _string(json["avatarUrl"]),
      json["price"] == null ? null : PackagePriceItem.fromJson(json["price"]),
      (json["stories"] as List<dynamic>?)
              ?.map((e) => StoryInfoItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

String _string(dynamic value) {
  if (value == null) return "";
  return value.toString();
}

int _int(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _bool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == "true";
  if (value is int) return value == 1;
  return false;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

DateTime _dateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

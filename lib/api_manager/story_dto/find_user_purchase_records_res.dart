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
  PurchaseRecordStoryInfoItem? storyInfo;

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
          : PurchaseRecordStoryInfoItem.fromJson(json["storyInfo"]),
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
  Price? price;
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
      json["price"] == null ? null : Price.fromJson(json["price"]),
      (json["stories"] as List<dynamic>?)
              ?.map((e) => StoryInfoItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PurchaseRecordStoryInfoItem {
  String userName;
  String collaboratorName;
  String storyId;
  String spaceName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  int voiceMessageCount;
  int likesCount;
  int commentCount;
  int instantCommentCount;
  String userId;
  String collaboratorId;
  String userAvatarUrl;
  String collaboratorAvatarUrl;
  String storyUrl;
  String previewUrl;
  String storyName;
  String storyDescription;
  int storyLength;
  int totalLength;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  int count;
  PurchaseRecordReviewItem review;
  bool locked;
  bool isPremium;
  int price;
  DateTime releaseTime;

  PurchaseRecordStoryInfoItem(
    this.userName,
    this.collaboratorName,
    this.storyId,
    this.spaceName,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.voiceMessageStatus,
    this.voiceMessageCount,
    this.likesCount,
    this.commentCount,
    this.instantCommentCount,
    this.userId,
    this.collaboratorId,
    this.userAvatarUrl,
    this.collaboratorAvatarUrl,
    this.storyUrl,
    this.previewUrl,
    this.storyName,
    this.storyDescription,
    this.storyLength,
    this.totalLength,
    this.storyImageUrls,
    this.storyUploadTime,
    this.count,
    this.review,
    this.locked,
    this.isPremium,
    this.price,
    this.releaseTime,
  );

  factory PurchaseRecordStoryInfoItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return PurchaseRecordStoryInfoItem(
      _string(json["userName"]),
      _string(json["collaboratorName"]),
      _string(json["storyId"]),
      _string(json["spaceName"]),
      _string(json["channelId"]),
      _string(json["channelName"]),
      _string(json["channelImageUrl"]),
      _string(json["voiceMessageStatus"]),
      _int(json["voiceMessageCount"]),
      _int(json["likesCount"]),
      _int(json["commentCount"]),
      _int(json["instantCommentCount"]),
      _string(json["userId"]),
      _string(json["collaboratorId"]),
      _string(json["userAvatarUrl"]),
      _string(json["collaboratorAvatarUrl"]),
      _string(json["storyUrl"]),
      _string(json["previewUrl"]),
      _string(json["storyName"]),
      _string(json["storyDescription"]),
      _int(json["storyLength"]),
      _int(json["totalLength"]),
      _stringList(json["storyImageUrls"]),
      _dateTime(json["storyUploadTime"]),
      _int(json["count"]),
      PurchaseRecordReviewItem.fromJson(json["review"]),
      _bool(json["locked"]),
      _bool(json["isPremium"]),
      _int(json["price"]),
      _dateTime(json["releaseTime"]),
    );
  }
}

class PurchaseRecordReviewItem {
  String status;
  String reason;

  PurchaseRecordReviewItem(this.status, this.reason);

  factory PurchaseRecordReviewItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return PurchaseRecordReviewItem(
      _string(json["status"]),
      _string(json["reason"] ?? json["comment"]),
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

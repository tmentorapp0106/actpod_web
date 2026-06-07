import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';

class PackageInfoItem {
  String packageId;
  String userId;
  String packageName;
  String packageDescription;
  String packageImageUrl;
  String channelId;
  String spaceId;
  String packageType;
  List<PackagePriceItem> packagePrices;
  DateTime createTime;
  DateTime updateTime;
  String nickname;
  String avatarUrl;
  String channelName;
  String channelImageUrl;
  String spaceName;

  PackageInfoItem(
    this.packageId,
    this.userId,
    this.packageName,
    this.packageDescription,
    this.packageImageUrl,
    this.channelId,
    this.spaceId,
    this.packageType,
    this.packagePrices,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.avatarUrl,
    this.channelName,
    this.channelImageUrl,
    this.spaceName,
  );

  factory PackageInfoItem.fromJson(Map<String, dynamic> json) {
    return PackageInfoItem(
      json["packageId"],
      json["userId"],
      json["packageName"],
      json["packageDescription"],
      json["packageImageUrl"],
      json["channelId"],
      json["spaceId"],
      json["packageType"],
      (json["packagePrices"] as List<dynamic>?)
              ?.map((e) => PackagePriceItem.fromJson(e))
              .toList() ??
          [],
      DateTime.parse(json["createTime"]),
      DateTime.parse(json["updateTime"]),
      json["nickname"] ?? "",
      json["avatarUrl"] ?? "",
      json["channelName"] ?? "",
      json["channelImageUrl"] ?? "",
      json["spaceName"] ?? "",
    );
  }
}

class PackagePriceItem {
  String packagePriceId;
  String priceType;
  String lable;
  int podcoins;
  int twd;
  bool isActive;

  PackagePriceItem(
    this.packagePriceId,
    this.priceType,
    this.lable,
    this.podcoins,
    this.twd,
    this.isActive,
  );

  factory PackagePriceItem.fromJson(Map<String, dynamic> json) {
    return PackagePriceItem(
      json["packagePriceId"],
      json["priceType"],
      json["lable"],
      json["podcoins"],
      json["twd"],
      json["isActive"] ?? false,
    );
  }
}

class PackageInfoWithStoriesItem extends PackageInfoItem {
  List<PackageStoryInfoItem> stories;

  PackageInfoWithStoriesItem(
    super.packageId,
    super.userId,
    super.packageName,
    super.packageDescription,
    super.packageImageUrl,
    super.channelId,
    super.spaceId,
    super.packageType,
    super.packagePrices,
    super.createTime,
    super.updateTime,
    super.nickname,
    super.avatarUrl,
    super.channelName,
    super.channelImageUrl,
    super.spaceName,
    this.stories,
  );

  factory PackageInfoWithStoriesItem.fromJson(Map<String, dynamic> json) {
    return PackageInfoWithStoriesItem(
      json["packageId"],
      json["userId"],
      json["packageName"],
      json["packageDescription"],
      json["packageImageUrl"],
      json["channelId"],
      json["spaceId"],
      json["packageType"],
      (json["packagePrices"] as List<dynamic>?)
              ?.map((e) => PackagePriceItem.fromJson(e))
              .toList() ??
          [],
      DateTime.parse(json["createTime"]),
      DateTime.parse(json["updateTime"]),
      json["nickname"] ?? "",
      json["avatarUrl"] ?? "",
      json["channelName"] ?? "",
      json["channelImageUrl"] ?? "",
      json["spaceName"] ?? "",
      (json["stories"] as List<dynamic>?)
              ?.map((e) => PackageStoryInfoItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PackageStoryInfoItem {
  String storyId;
  String userId;
  String collaborator;
  String spaceId;
  String channelId;
  String storyUrl;
  int previewStartFrom;
  int previewEndAt;
  String previewUrl;
  String storyName;
  String storyDescription;
  List<String> storyImageUrls;
  int storyLength;
  DateTime storyUploadTime;
  int count;
  bool isPremium;
  String packageId;
  String packageNote;
  String storyStatus;
  Review review;
  bool locked;
  bool archive;
  DateTime updateTime;
  DateTime releaseTime;
  String nickname;
  String avatarUrl;
  String collaboratorName;
  String collaboratorAvatarUrl;
  String channelName;
  String channelImageUrl;
  String spaceName;

  PackageStoryInfoItem(
    this.storyId,
    this.userId,
    this.collaborator,
    this.spaceId,
    this.channelId,
    this.storyUrl,
    this.previewStartFrom,
    this.previewEndAt,
    this.previewUrl,
    this.storyName,
    this.storyDescription,
    this.storyImageUrls,
    this.storyLength,
    this.storyUploadTime,
    this.count,
    this.isPremium,
    this.packageId,
    this.packageNote,
    this.storyStatus,
    this.review,
    this.locked,
    this.archive,
    this.updateTime,
    this.releaseTime,
    this.nickname,
    this.avatarUrl,
    this.collaboratorName,
    this.collaboratorAvatarUrl,
    this.channelName,
    this.channelImageUrl,
    this.spaceName,
  );

  factory PackageStoryInfoItem.fromJson(Map<String, dynamic> json) {
    return PackageStoryInfoItem(
      json["storyId"],
      json["userId"],
      json["collaborator"] ?? "",
      json["spaceId"],
      json["channelId"],
      json["storyUrl"],
      json["previewStartFrom"] ?? 0,
      json["previewEndAt"] ?? 0,
      json["previewUrl"] ?? "",
      json["storyName"],
      json["storyDescription"],
      (json["storyImageUrls"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      json["storyLength"],
      DateTime.parse(json["storyUploadTime"]),
      json["count"] ?? 0,
      json["isPremium"] ?? false,
      json["packageId"] ?? "",
      json["packageNote"] ?? "",
      json["storyStatus"] ?? "",
      Review.fromJson(json["review"]),
      json["locked"] ?? false,
      json["archive"] ?? false,
      DateTime.parse(json["updateTime"]),
      DateTime.parse(json["releaseTime"]),
      json["nickname"] ?? "",
      json["avatarUrl"] ?? "",
      json["collaboratorName"] ?? "",
      json["collaboratorAvatarUrl"] ?? "",
      json["channelName"] ?? "",
      json["channelImageUrl"] ?? "",
      json["spaceName"] ?? "",
    );
  }
}

import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';

class PackageInfoItem {
  String packageId;
  String userId;
  String packageName;
  String packageDescription;
  String packageImageUrl;
  Price? packagePrice;
  DateTime createTime;
  DateTime updateTime;
  String nickname;
  String avatarUrl;

  PackageInfoItem(
    this.packageId,
    this.userId,
    this.packageName,
    this.packageDescription,
    this.packageImageUrl,
    this.packagePrice,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.avatarUrl,
  );

  factory PackageInfoItem.fromJson(Map<String, dynamic> json) {
    return PackageInfoItem(
      json["packageId"],
      json["userId"],
      json["packageName"],
      json["packageDescription"],
      json["packageImageUrl"],
      json["price"] != null? Price.fromJson(json["price"]) : null,
      DateTime.parse(json["createTime"]),
      DateTime.parse(json["updateTime"]),
      json["nickname"] ?? "",
      json["avatarUrl"] ?? "",
    );
  }
}

class Price {
  String packagePriceId;
  String priceType;
  String lable;
  int podcoins;
  int twd;
  bool isActive;

  Price(
    this.packagePriceId,
    this.priceType,
    this.lable,
    this.podcoins,
    this.twd,
    this.isActive,
  );

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      json["priceId"],
      json["priceType"],
      json["lable"],
      json["podcoins"],
      json["twd"],
      json["isActive"] ?? false,
    );
  }
}

class PackageInfoWithStoriesItem extends PackageInfoItem {
  List<StoryInfoItem> stories;

  PackageInfoWithStoriesItem(
    super.packageId,
    super.userId,
    super.packageName,
    super.packageDescription,
    super.packageImageUrl,
    super.packagePrices,
    super.createTime,
    super.updateTime,
    super.nickname,
    super.avatarUrl,
    this.stories,
  );

  factory PackageInfoWithStoriesItem.fromJson(Map<String, dynamic> json) {
    return PackageInfoWithStoriesItem(
      json["packageId"],
      json["userId"],
      json["packageName"],
      json["packageDescription"],
      json["packageImageUrl"],
      Price.fromJson(json["price"]),
      DateTime.parse(json["createTime"]),
      DateTime.parse(json["updateTime"]),
      json["nickname"] ?? "",
      json["avatarUrl"] ?? "",
      (json["stories"] as List<dynamic>?)
              ?.map((e) => StoryInfoItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StoryInfoItem {
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

  StoryInfoItem(
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

  factory StoryInfoItem.fromJson(Map<String, dynamic> json) {
    return StoryInfoItem(
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

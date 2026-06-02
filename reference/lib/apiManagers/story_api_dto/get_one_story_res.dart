import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';

class GetOneStoryRes {
  String code;
  String message;
  GetOneStoryResItem? story;

  GetOneStoryRes(this.code, this.message, this.story);

  factory GetOneStoryRes.fromJson(Map<String, dynamic> json) {
    return GetOneStoryRes(
        json["code"],
        json["message"],
        GetOneStoryResItem.fromJson(json["data"])
    );
  }
}

class GetOneStoryResItem {
  String storyId;
  String userId;
  String collaboratorId;
  String spaceId;
  String spaceName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  String storyUrl;
  String storyName;
  String storyDescription;
  String storyImageUrl;
  List<String> storyImageUrls;
  int storyLength;
  int totalLength;
  DateTime storyUploadTime;
  String openingUrl;
  String endingUrl;
  String avatarUrl;
  String collaboratorAvatarUrl;
  String nickname;
  String collaboratorName;
  bool isPremium;
  int price;
  int count;

  GetOneStoryResItem(
    this.storyId,
    this.userId,
    this.collaboratorId,
    this.spaceId,
    this.spaceName,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.voiceMessageStatus,
    this.storyUrl,
    this.storyName,
    this.storyDescription,
    this.storyImageUrl,
    this.storyImageUrls,
    this.storyLength,
    this.totalLength,
    this.storyUploadTime,
    this.openingUrl,
    this.endingUrl,
    this.avatarUrl,
    this.collaboratorAvatarUrl,
    this.nickname,
    this.collaboratorName,
    this.isPremium,
    this.price,
    this.count
  );

  factory GetOneStoryResItem.fromJson(Map<String, dynamic> json) {
    return GetOneStoryResItem(
      json["storyId"],
      json["userId"],
      json["collaboratorId"]?? "",
      json["spaceId"],
      json["spaceName"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["voiceMessageStatus"],
      json["storyUrl"],
      json["storyName"],
      json["storyDescription"],
      json["storyImageUrl"],
      (json["storyImageUrls"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
          ?? [],
      json["storyLength"],
      json["totalLength"],
      DateTime.parse(json["storyUploadTime"]),
      json["openingUrl"],
      json["endingUrl"],
      json["avatarUrl"],
      json["collaboratorAvatarUrl"],
      json["nickname"],
      json["collaboratorName"],
      json["isPremium"]?? false,
      json["price"]?? 0,
      json["count"]?? 0
    );
  }
}
import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:quick_share_app/dto/story_dto.dart';

import '../apiManagers/recommendation_api_dto/get_recommendation_res.dart';

@Entity()
class RecommendationItem {
  int id = 0;
  String storyId;
  String spaceId;
  String spaceName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String userId;
  String collaboratorId;
  String username;
  String collaboratorName;
  String userAvatarUrl;
  String collaboratorAvatarUrl;
  String storyUrl;
  String previewUrl;
  String backgroundMusicUrl;
  double backgroundMusicVolume;
  String storyName;
  String storyDescription;
  String storyImageUrl;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  String voiceMessageStatus;
  int voiceMessageCount;
  int storyLength;
  int totalLength;
  @Transient()
  List<SoundEffectDto>? soundEffectList;
  String openingUrl;
  String endingUrl;
  int commentCount;
  int instantCommentCount;
  int likesCount;
  int count;
  bool isPremium;
  int price;
  DateTime releaseTime;

  List<String>? get soundEffectListDbData => soundEffectList?.map((soundEffect) => jsonEncode(soundEffect.toJson())).toList();
  set soundEffectListDbData(List<String>? jsonList) => soundEffectList = jsonList?.map((jsonString) => SoundEffectDto.fromJson(jsonDecode(jsonString))).toList();

  RecommendationItem(
      this.storyId,
      this.spaceId,
      this.spaceName,
      this.channelId,
      this.channelName,
      this.channelImageUrl,
      this.userId,
      this.collaboratorId,
      this.username,
      this.collaboratorName,
      this.userAvatarUrl,
      this.collaboratorAvatarUrl,
      this.storyUrl,
      this.previewUrl,
      this.backgroundMusicUrl,
      this.backgroundMusicVolume,
      this.storyName,
      this.storyDescription,
      this.storyImageUrl,
      this.storyImageUrls,
      this.storyUploadTime,
      this.voiceMessageStatus,
      this.voiceMessageCount,
      this.storyLength,
      this.totalLength,
      this.commentCount,
      this.instantCommentCount,
      this.likesCount,
      this.openingUrl,
      this.endingUrl,
      this.count,
      this.isPremium,
      this.price,
      this.releaseTime,
      {this.soundEffectList});

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      json["storyId"],
      json["spaceId"],
      json["spaceName"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["userId"],
      json["collaboratorId"]?? "",
      json["userName"],
      json["collaboratorName"]?? "",
      json["userAvatarUrl"],
      json["collaboratorAvatarUrl"]?? "",
      json["storyUrl"],
      json["previewUrl"],
      json["backgroundMusicUrl"]?? "",
      double.tryParse(json["backgroundMusicVolume"].toString())?? 0.0,
      json["storyName"],
      json["storyDescription"],
      json["storyImageUrls"][0],
      (json["storyImageUrls"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
          ?? [],
      DateTime.parse(json["storyUploadTime"]),
      json["voiceMessageStatus"],
      json["voiceMessageCount"],
      json["storyLength"],
      json["totalLength"],
      json["commentCount"]?? 0,
      json["instantCommentCount"]?? 0,
      json["likesCount"]?? 0,
      json["openingUrl"],
      json["endingUrl"],
      json["count"]?? 0,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
    );
  }

  factory RecommendationItem.fromGetRecommendationResItem(
      GetRecommendationResItem getRecommendationResItem) {
    return RecommendationItem(
      getRecommendationResItem.storyId,
      getRecommendationResItem.spaceId,
      getRecommendationResItem.spaceName,
      getRecommendationResItem.channelId,
      getRecommendationResItem.channelName,
      getRecommendationResItem.channelImageUrl,
      getRecommendationResItem.userId,
      getRecommendationResItem.collaboratorId,
      getRecommendationResItem.username,
      getRecommendationResItem.collaboratorName,
      getRecommendationResItem.userAvatarUrl,
      getRecommendationResItem.collaboratorAvatarUrl,
      getRecommendationResItem.storyUrl,
      getRecommendationResItem.previewUrl,
      getRecommendationResItem.backgroundMusicUrl,
      getRecommendationResItem.backgroundMusicVolume,
      getRecommendationResItem.storyName,
      getRecommendationResItem.storyDescription,
      getRecommendationResItem.storyImageUrl,
      getRecommendationResItem.storyImageUrls,
      getRecommendationResItem.storyUploadTime,
      getRecommendationResItem.voiceMessageStatus,
      getRecommendationResItem.voiceMessageCount,
      getRecommendationResItem.storyLength,
      getRecommendationResItem.totalLength,
      getRecommendationResItem.commentCount,
      getRecommendationResItem.instantCommentCount,
      getRecommendationResItem.likesCount,
      getRecommendationResItem.openingUrl,
      getRecommendationResItem.endingUrl,
      getRecommendationResItem.count,
      getRecommendationResItem.isPremium,
      getRecommendationResItem.price,
      getRecommendationResItem.releaseTime,
      soundEffectList: getRecommendationResItem.soundEffectList
    );
  }
}

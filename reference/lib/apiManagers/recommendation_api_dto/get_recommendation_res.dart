import '../../dto/story_dto.dart';

class GetRecommendationRes {
  String code;
  String message;
  List<GetRecommendationResItem>? recordList;

  GetRecommendationRes(this.code, this.message, this.recordList);

  factory GetRecommendationRes.fromJson(Map<String, dynamic> json) {
    List<GetRecommendationResItem> updatedRecordList = json["data"] == null? [] : json["data"]
        .map<GetRecommendationResItem>(
            (json) => GetRecommendationResItem.fromJson(json))
        .toList();
    return GetRecommendationRes(
        json["code"], json["message"], updatedRecordList);
  }
}

class GetRecommendationResItem {
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
  List<SoundEffectDto> soundEffectList;
  String openingUrl;
  String endingUrl;
  int commentCount;
  int likesCount;
  int instantCommentCount;
  int count;
  bool isPremium;
  int price;
  DateTime releaseTime;


  GetRecommendationResItem(
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
      this.soundEffectList,
      this.openingUrl,
      this.endingUrl,
      this.commentCount,
      this.likesCount,
      this.instantCommentCount,
      this.count,
      this.isPremium,
      this.price,
      this.releaseTime
    );

  factory GetRecommendationResItem.fromJson(Map<String, dynamic> json) {
    return GetRecommendationResItem(
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
      json["storyImageUrl"],
      (json["storyImageUrls"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
          ?? [],
      DateTime.parse(json["storyUploadTime"]),
      json["voiceMessageStatus"],
      json["voiceMessageCount"],
      json["storyLength"],
      json["totalLength"],
      json["soundEffectList"] == null? [] : json["soundEffectList"].map<SoundEffectDto>((json) => SoundEffectDto.fromJson(json)).toList(),
      json["openingUrl"],
      json["endingUrl"],
      json["commentCount"]?? 0,
      json["likesCount"],
      json["instantCommentCount"]?? 0,
      json["count"]?? 0,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
    );
  }
}

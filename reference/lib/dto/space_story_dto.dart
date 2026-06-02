import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:quick_share_app/dto/story_dto.dart';

@Entity()
class SpaceStoryDto {
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
  String openingUrl;
  String endingUrl;
  int commentCount;
  int instantCommentCount;
  int likesCount;
  int count;
  bool isPremium;
  int price;
  DateTime releaseTime;
  @Transient()
  List<SoundEffectDto>? soundEffectList;

  List<String>? get soundEffectListDbData => soundEffectList?.map((soundEffect) => jsonEncode(soundEffect.toJson())).toList();
  set soundEffectListDbData(List<String>? jsonList) => soundEffectList = jsonList?.map((jsonString) => SoundEffectDto.fromJson(jsonDecode(jsonString))).toList();

  SpaceStoryDto(
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
    this.openingUrl,
    this.endingUrl,
    this.commentCount,
    this.instantCommentCount,
    this.likesCount,
    this.count,
    this.isPremium,
    this.price,
    this.releaseTime,
    {this.soundEffectList}
  );

  factory SpaceStoryDto.fromJson(Map<String, dynamic> json) {
    return SpaceStoryDto(
      json["storyId"],
      json["spaceId"],
      json["spaceName"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["userId"],
      json["collaboratorId"]?? "",
      json["userName"],
      json["collaboratorName"],
      json["userAvatarUrl"],
      json["collaboratorAvatarUrl"],
      json["storyUrl"],
      json["previewUrl"],
      json["backgroundMusicUrl"],
      0,
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
      json["openingUrl"],
      json["endingUrl"],
      json["commentCount"]?? 0,
      json["instantCommentCount"]?? 0,
      json["likesCount"]?? 0,
      json["count"]?? 0,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
      soundEffectList: json["soundEffectList"]?.map<SoundEffectDto>((json) => SoundEffectDto.fromJson(json)).toList()
    );
  }
}
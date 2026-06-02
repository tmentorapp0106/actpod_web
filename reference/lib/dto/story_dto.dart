import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../apiManagers/story_api_dto/get_stories_by_userid_res.dart';

@Entity()
class SoundEffectDto {
  int id = 0;
  String url;
  String soundEffectName;
  int startMilliSec; // Store start as an integer (milliseconds)
  int endMilliSec;   // Store end as an integer (milliseconds)

  SoundEffectDto({
    required this.url,
    required this.soundEffectName,
    required this.startMilliSec,
    required this.endMilliSec
  });


  factory SoundEffectDto.fromJson(Map<String, dynamic> json) {
    return SoundEffectDto(
      url: json["url"],
      soundEffectName: json["soundEffectName"]?? "",
      startMilliSec: json["startMillis"]?? 0,
      endMilliSec: json["endMillis"]?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "soundEffectName": soundEffectName,
      "startMilliSec": startMilliSec,
      "endMilliSec": endMilliSec,
    };
  }

  bool checkReached(Duration duration) {
    return duration.inMilliseconds >= startMilliSec && duration.inMilliseconds <= endMilliSec;
  }

  Duration getDuration() {
    return Duration(milliseconds: endMilliSec) - Duration(milliseconds: startMilliSec);
  }

  bool checkEnded(Duration duration) {
    return duration > Duration(milliseconds: endMilliSec);
  }
}

@Entity()
class StoryDto {
  int id = 0;
  @Unique()
  String storyId;
  String boardId;
  String userId;
  String audioContentId;
  String audioUrl;
  String backgroundMusicUrl;
  double backgroundMusicVolume;
  String storyName;
  String storyDescription;
  String storyImageUrl;
  List<String> storyImageUrls;
  int storyLength;
  int totalLength;
  String collectionId;
  DateTime storyUploadTime;
  String storyStatus;
  String voiceMessageStatus;
  int count;

  @Transient()
  List<SoundEffectDto>? soundEffectList;

  List<String>? get soundEffectListDbData => soundEffectList?.map((soundEffect) => jsonEncode(soundEffect.toJson())).toList();
  set soundEffectListDbData(List<String>? jsonList) => soundEffectList = jsonList?.map((jsonString) => SoundEffectDto.fromJson(jsonDecode(jsonString))).toList();

  StoryDto(
    this.storyId,
    this.boardId,
    this.userId,
    this.audioContentId,
    this.audioUrl,
    this.backgroundMusicUrl,
    this.backgroundMusicVolume,
    this.storyName,
    this.storyDescription,
    this.storyImageUrl,
    this.storyImageUrls,
    this.storyLength,
    this.totalLength,
    this.collectionId,
    this.storyUploadTime,
    this.storyStatus,
    this.voiceMessageStatus,
    this.count,
    {this.soundEffectList}
  );

  factory StoryDto.fromJson(Map<String, dynamic> json) {
    return StoryDto(
        json["storyId"],
        json["boardId"]??"",
        json["userId"],
        json["audioContentId"],
        json["audioUrl"],
        json["backgroundMusicUrl"]?? "",
        double.tryParse(json["backgroundMusicVolume"].toString())?? 0.0,
        json["storyName"],
        json["storyDescription"],
        json["storyImageUrl"],
        (json["storyImageUrls"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList()
            ?? [],
        json["storyLength"],
        json["totalLength"],
        json["collectionId"],
        DateTime.parse(json["storyUploadTime"]),
        json["storyStatus"],
        json["voiceMessageStatus"]?? "disable",
        json["count"]?? 0,
        soundEffectList: json["soundEffectList"]?.map<SoundEffectDto>((json) => SoundEffectDto.fromJson(json)).toList()
    );
  }

  factory StoryDto.fromGetStoriesByUserIdResItem(GetStoriesByUserIdResItem getStoriesByUserIdResItem) {
    return StoryDto(
      getStoriesByUserIdResItem.storyId,
      "",
      getStoriesByUserIdResItem.userId,
      "",
      "",
      "",
      0,
      getStoriesByUserIdResItem.storyName,
      getStoriesByUserIdResItem.storyDescription,
      getStoriesByUserIdResItem.storyImageUrl,
      [getStoriesByUserIdResItem.storyImageUrl],
      0,
      0,
      "",
      getStoriesByUserIdResItem.storyUploadTime,
      "",
      getStoriesByUserIdResItem.voiceMessageStatus,
      getStoriesByUserIdResItem.count,
      soundEffectList: []
    );
  }
}
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
  String spaceId;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  String storyUrl;
  String storyName;
  String storyDescription;
  String storyImageUrl;
  int storyLength;
  int totalLength;
  DateTime storyEditTime;
  DateTime storyUploadTime;
  String openingUrl;
  String endingUrl;
  String avatarUrl;
  String nickname;
  int count;

  GetOneStoryResItem(
    this.storyId,
    this.userId,
    this.spaceId,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.voiceMessageStatus,
    this.storyUrl,
    this.storyName,
    this.storyDescription,
    this.storyImageUrl,
    this.storyLength,
    this.totalLength,
    this.storyEditTime,
    this.storyUploadTime,
    this.openingUrl,
    this.endingUrl,
    this.avatarUrl,
    this.nickname,
    this.count,
  );

  factory GetOneStoryResItem.fromJson(Map<String, dynamic> json) {
    return GetOneStoryResItem(
      json["storyId"],
      json["userId"],
      json["spaceId"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["voiceMessageStatus"],
      json["storyUrl"],
      json["storyName"],
      json["storyDescription"],
      json["storyImageUrl"],
      json["storyLength"],
      json["totalLength"],
      DateTime.parse(json["storyEditTime"]),
      DateTime.parse(json["storyUploadTime"]),
      json["openingUrl"],
      json["endingUrl"],
      json["avatarUrl"],
      json["nickname"],
      json["count"]
    );
  }
}
class GetUserPremiumStoriesRes {
  String code;
  String message;
  List<GetUserPremiumStoriesItem>? storyList;

  GetUserPremiumStoriesRes(this.code, this.message, this.storyList);

  factory GetUserPremiumStoriesRes.fromJson(Map<String, dynamic> json) {
    return GetUserPremiumStoriesRes(
        json["code"],
        json["message"],
        json["data"]?.map<GetUserPremiumStoriesItem>((json) => GetUserPremiumStoriesItem.fromJson(json)).toList()
    );
  }
}

class GetUserPremiumStoriesItem {
  String username;
  String collaboratorName;
  String storyId;
  String spaceName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  int voiceMessageCount;
  int likesCount;
  String userId;
  String collaboratorId;
  String userAvatarUrl;
  String collaboratorAvatarUrl;
  String storyUrl;
  String storyName;
  String storyDescription;
  int storyLength;
  int totalLength;
  String storyImageUrl;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  int count;
  bool locked;
  bool isPremium;
  int price;
  DateTime releaseTime;


  GetUserPremiumStoriesItem(
      this.username,
      this.collaboratorName,
      this.storyId,
      this.spaceName,
      this.channelId,
      this.channelName,
      this.channelImageUrl,
      this.voiceMessageStatus,
      this.voiceMessageCount,
      this.likesCount,
      this.userId,
      this.collaboratorId,
      this.userAvatarUrl,
      this.collaboratorAvatarUrl,
      this.storyUrl,
      this.storyName,
      this.storyDescription,
      this.storyLength,
      this.totalLength,
      this.storyImageUrl,
      this.storyImageUrls,
      this.storyUploadTime,
      this.count,
      this.locked,
      this.isPremium,
      this.price,
      this.releaseTime
      );

  factory GetUserPremiumStoriesItem.fromJson(Map<String, dynamic> json) {
    return GetUserPremiumStoriesItem(
      json["userName"],
      json["collaboratorName"]?? "",
      json["storyId"],
      json["spaceName"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"],
      json["voiceMessageStatus"],
      json["voiceMessageCount"],
      json["likesCount"],
      json["userId"],
      json["collaboratorId"]?? "",
      json["userAvatarUrl"],
      json["collaboratorAvatarUrl"]?? "",
      json["storyUrl"],
      json["storyName"],
      json["storyDescription"],
      json["storyLength"],
      json["totalLength"],
      json["storyImageUrl"],
      (json["storyImageUrls"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
          ?? [],
      DateTime.parse(json["storyUploadTime"]),
      json["count"]?? 0,
      json["locked"]?? false,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
    );
  }
}
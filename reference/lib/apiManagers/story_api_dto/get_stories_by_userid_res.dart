class GetStoriesByUserIdRes {
  String code;
  String message;
  List<GetStoriesByUserIdResItem>? storyList;

  GetStoriesByUserIdRes(this.code, this.message, this.storyList);

  factory GetStoriesByUserIdRes.fromJson(Map<String, dynamic> json) {
    return GetStoriesByUserIdRes(
      json["code"],
      json["message"],
      json["data"]?.map<GetStoriesByUserIdResItem>((json) => GetStoriesByUserIdResItem.fromJson(json)).toList()
    );
  }
}

class GetStoriesByUserIdResItem {
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
  Review review;
  int count;
  bool locked;
  bool isPremium;
  int price;
  DateTime releaseTime;


  GetStoriesByUserIdResItem(
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
      this.review,
      this.count,
      this.locked,
      this.isPremium,
      this.price,
      this.releaseTime
    );

  factory GetStoriesByUserIdResItem.fromJson(Map<String, dynamic> json) {
    return GetStoriesByUserIdResItem(
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
      Review.fromJson(json["review"]),
      json["count"]?? 0,
      json["locked"]?? false,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
    );
  }
}

class Review {
  String status;
  String reason;

  Review(this.status, this.reason);

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
        json["status"],
        json["reason"],
    );
  }
}
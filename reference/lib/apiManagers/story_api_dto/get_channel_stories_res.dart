import 'get_stories_by_userid_res.dart';

class GetChannelStoriesRes {
  String code;
  String message;
  List<GetChannelStoriesResItem>? storyList;

  GetChannelStoriesRes(this.code, this.message, this.storyList);

  factory GetChannelStoriesRes.fromJson(Map<String, dynamic> json) {
    return GetChannelStoriesRes(
        json["code"],
        json["message"],
        json["data"]?.map<GetChannelStoriesResItem>((json) => GetChannelStoriesResItem.fromJson(json)).toList()
    );
  }
}

class GetChannelStoriesResItem {
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
  String previewUrl;
  String storyName;
  String storyDescription;
  int storyLength;
  int totalLength;
  String storyImageUrl;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  Review review;
  int count;
  int commentCount;
  int instantCommentCount;
  bool isPremium;
  int price;
  DateTime releaseTime;


  GetChannelStoriesResItem(
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
    this.previewUrl,
    this.storyName,
    this.storyDescription,
    this.storyLength,
    this.totalLength,
    this.storyImageUrl,
    this.storyImageUrls,
    this.storyUploadTime,
    this.review,
    this.count,
    this.commentCount,
    this.instantCommentCount,
    this.isPremium,
    this.price,
    this.releaseTime,
  );

  factory GetChannelStoriesResItem.fromJson(Map<String, dynamic> json) {
    return GetChannelStoriesResItem(
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
      json["previewUrl"],
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
      json["commentCount"]?? 0,
      json["instantCommentCount"]?? 0,
      json["isPremium"]?? false,
      json["price"]?? 0,
      DateTime.parse(json["releaseTime"]),
    );
  }
}
import '../../dto/story_recommendation_dto.dart';

class SearchStoriesRes {
  String code;
  String message;
  List<SearchStoriesResItem>? storyList;

  SearchStoriesRes(this.code, this.message, this.storyList);

  factory SearchStoriesRes.fromJson(Map<String, dynamic> json) {
    return SearchStoriesRes(
        json["code"],
        json["message"],
        json["data"]?.map<SearchStoriesResItem>((json) => SearchStoriesResItem.fromJson(json)).toList()
    );
  }
}

class SearchStoriesResItem {
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
  DateTime storyUploadTime;
  bool isPremium;
  int price;
  int count;


  SearchStoriesResItem(
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
      this.storyUploadTime,
      this.isPremium,
      this.price,
      this.count
    );

  factory SearchStoriesResItem.fromJson(Map<String, dynamic> json) {
    return SearchStoriesResItem(
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
        DateTime.parse(json["storyUploadTime"]),
        json["isPremium"]?? false,
        json["price"]?? 0,
        json["count"]?? 0
    );
  }

  factory SearchStoriesResItem.fromRecommendationItem(RecommendationItem recommendationItem) {
    return SearchStoriesResItem(
        recommendationItem.username,
        recommendationItem.collaboratorName,
        recommendationItem.storyId,
        recommendationItem.spaceName,
        recommendationItem.channelId,
        recommendationItem.channelName,
        recommendationItem.channelImageUrl,
        recommendationItem.voiceMessageStatus,
        recommendationItem.voiceMessageCount,
        recommendationItem.likesCount,
        recommendationItem.userId,
        recommendationItem.collaboratorId,
        recommendationItem.userAvatarUrl,
        recommendationItem.collaboratorAvatarUrl,
        recommendationItem.storyUrl,
        recommendationItem.previewUrl,
        recommendationItem.storyName,
        recommendationItem.storyDescription,
        recommendationItem.storyLength,
        recommendationItem.totalLength,
        recommendationItem.storyImageUrl,
        recommendationItem.storyUploadTime,
        recommendationItem.isPremium,
        recommendationItem.price,
        recommendationItem.count
    );
  }
}
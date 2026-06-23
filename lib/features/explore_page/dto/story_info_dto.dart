import 'package:actpod_web/api_manager/recommendation_dto/get_recommendation_res.dart';

class StoryInfoDto {
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
  String storyName;
  String storyDescription;
  String storyImageUrl;
  List<String> storyImageUrls;
  DateTime storyUploadTime;
  String voiceMessageStatus;
  int voiceMessageCount;
  int storyLength;
  int totalLength;
  int commentCount;
  int likesCount;
  int instantCommentCount;
  int count;
  bool isPremium;
  int price;
  String contentRating;
  DateTime releaseTime;

  StoryInfoDto(
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
      this.likesCount,
      this.instantCommentCount,
      this.count,
      this.isPremium,
      this.price,
      this.contentRating,
      this.releaseTime);

  factory StoryInfoDto.fromRecommendationItem(
    GetRecommendationResItem item,
  ) {
    return StoryInfoDto(
      item.storyId,
      item.spaceId,
      item.spaceName,
      item.channelId,
      item.channelName,
      item.channelImageUrl,
      item.userId,
      item.collaboratorId,
      item.username,
      item.collaboratorName,
      item.userAvatarUrl,
      item.collaboratorAvatarUrl,
      item.storyUrl,
      item.previewUrl,
      item.storyName,
      item.storyDescription,
      item.storyImageUrl,
      item.storyImageUrls,
      item.storyUploadTime,
      item.voiceMessageStatus,
      item.voiceMessageCount,
      item.storyLength,
      item.totalLength,
      item.commentCount,
      item.likesCount,
      item.instantCommentCount,
      item.count,
      item.isPremium,
      item.price,
      item.contentRating,
      item.releaseTime,
    );
  }

  static List<StoryInfoDto> fromRecommendationList(
    List<GetRecommendationResItem>? items,
  ) {
    return items
            ?.map((item) => StoryInfoDto.fromRecommendationItem(item))
            .toList() ??
        [];
  }
}

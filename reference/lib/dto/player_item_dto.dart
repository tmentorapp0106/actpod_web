import 'package:quick_share_app/apiManagers/story_api_dto/get_channel_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_user_premium_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/search_stories_res.dart';
import 'package:quick_share_app/dto/space_story_dto.dart';
import 'package:quick_share_app/dto/story_recommendation_dto.dart';

import '../apiManagers/story_api_dto/get_one_story_res.dart';
import '../apiManagers/story_api_dto/get_stories_by_userid_res.dart';

class PlayerItemDto {
  String storyId;
  String storyUrl;
  String storyName;
  String storyDescription;
  List<String> storyImageUrls;
  String userId;
  String collaboratorId;
  String userName;
  String collaboratorName;
  String channelId;
  String channelName;
  String channelImageUrl;
  String voiceMessageStatus;
  String userAvatar;
  String collaboratorAvatarUrl;
  int storyLength;
  int totalLength;
  DateTime storyUploadTime;
  Review? review;
  bool isPremium;
  int price;
  String spaceName;
  int count;


  PlayerItemDto(
      this.storyId,
      this.storyUrl,
      this.storyName,
      this.storyDescription,
      this.storyImageUrls,
      this.userId,
      this.collaboratorId,
      this.userName,
      this.collaboratorName,
      this.channelId,
      this.channelName,
      this.channelImageUrl,
      this.voiceMessageStatus,
      this.userAvatar,
      this.collaboratorAvatarUrl,
      this.storyLength,
      this.totalLength,
      this.storyUploadTime,
      this.review,
      this.isPremium,
      this.price,
      this.spaceName,
      this.count
  );

  factory PlayerItemDto.fromGetStoriesByUserIdResItem(GetStoriesByUserIdResItem userStoryItem) {
    return PlayerItemDto(
      userStoryItem.storyId,
      userStoryItem.storyUrl,
      userStoryItem.storyName,
      userStoryItem.storyDescription,
      userStoryItem.storyImageUrls,
      userStoryItem.userId,
      userStoryItem.collaboratorId,
      userStoryItem.username,
      userStoryItem.collaboratorName,
      userStoryItem.channelId,
      userStoryItem.channelName,
      userStoryItem.channelImageUrl,
      userStoryItem.voiceMessageStatus,
      userStoryItem.userAvatarUrl,
      userStoryItem.collaboratorAvatarUrl,
      userStoryItem.storyLength,
      userStoryItem.totalLength,
      userStoryItem.releaseTime,
      userStoryItem.review,
      userStoryItem.isPremium,
      userStoryItem.price,
      userStoryItem.spaceName,
      userStoryItem.count
    );
  }

  factory PlayerItemDto.fromGetUserPremiumStoriesResItem(GetUserPremiumStoriesItem userStoryItem) {
    return PlayerItemDto(
        userStoryItem.storyId,
        userStoryItem.storyUrl,
        userStoryItem.storyName,
        userStoryItem.storyDescription,
        userStoryItem.storyImageUrls,
        userStoryItem.userId,
        userStoryItem.collaboratorId,
        userStoryItem.username,
        userStoryItem.collaboratorName,
        userStoryItem.channelId,
        userStoryItem.channelName,
        userStoryItem.channelImageUrl,
        userStoryItem.voiceMessageStatus,
        userStoryItem.userAvatarUrl,
        userStoryItem.collaboratorAvatarUrl,
        userStoryItem.storyLength,
        userStoryItem.totalLength,
        userStoryItem.releaseTime,
        null,
        userStoryItem.isPremium,
        userStoryItem.price,
        userStoryItem.spaceName,
        userStoryItem.count
    );
  }

  factory PlayerItemDto.fromGetOneStoryResItem(GetOneStoryResItem storyItem) {
    return PlayerItemDto(
      storyItem.storyId,
      storyItem.storyUrl,
      storyItem.storyName,
      storyItem.storyDescription,
      storyItem.storyImageUrls,
      storyItem.userId,
      storyItem.collaboratorId,
      storyItem.nickname,
      storyItem.collaboratorName,
      storyItem.channelId,
      storyItem.channelName,
      storyItem.channelImageUrl,
      storyItem.voiceMessageStatus,
      storyItem.avatarUrl,
      storyItem.collaboratorAvatarUrl,
      storyItem.storyLength,
      storyItem.totalLength,
      storyItem.storyUploadTime,
      null,
      storyItem.isPremium,
      storyItem.price,
      storyItem.spaceName,
      storyItem.count
    );
  }

  factory PlayerItemDto.fromRecommendationItem(RecommendationItem recommendationItem) {
    return PlayerItemDto(
      recommendationItem.storyId,
      recommendationItem.storyUrl,
      recommendationItem.storyName,
      recommendationItem.storyDescription,
      recommendationItem.storyImageUrls,
      recommendationItem.userId,
      recommendationItem.collaboratorId,
      recommendationItem.username,
      recommendationItem.collaboratorName,
      recommendationItem.channelId,
      recommendationItem.channelName,
      recommendationItem.channelImageUrl,
      recommendationItem.voiceMessageStatus,
      recommendationItem.userAvatarUrl,
      recommendationItem.collaboratorAvatarUrl,
      recommendationItem.storyLength,
      recommendationItem.totalLength,
      recommendationItem.releaseTime,
      null,
      recommendationItem.isPremium,
      recommendationItem.price,
      recommendationItem.spaceName,
      recommendationItem.count
    );
  }

  factory PlayerItemDto.fromGetChannelStoriesResItem(GetChannelStoriesResItem getChannelStoriesResItem) {
    return PlayerItemDto(
        getChannelStoriesResItem.storyId,
        getChannelStoriesResItem.storyUrl,
        getChannelStoriesResItem.storyName,
        getChannelStoriesResItem.storyDescription,
        getChannelStoriesResItem.storyImageUrls,
        getChannelStoriesResItem.userId,
        getChannelStoriesResItem.collaboratorId,
        getChannelStoriesResItem.username,
        getChannelStoriesResItem.collaboratorName,
        getChannelStoriesResItem.channelId,
        getChannelStoriesResItem.channelName,
        getChannelStoriesResItem.channelImageUrl,
        getChannelStoriesResItem.voiceMessageStatus,
        getChannelStoriesResItem.userAvatarUrl,
        getChannelStoriesResItem.collaboratorAvatarUrl,
        getChannelStoriesResItem.storyLength,
        getChannelStoriesResItem.totalLength,
        getChannelStoriesResItem.releaseTime,
        null,
        getChannelStoriesResItem.isPremium,
        getChannelStoriesResItem.price,
        getChannelStoriesResItem.spaceName,
        getChannelStoriesResItem.count
    );
  }

  factory PlayerItemDto.fromSearchStoriesResItem(SearchStoriesResItem searchStoriesResItem) {
    return PlayerItemDto(
        searchStoriesResItem.storyId,
        searchStoriesResItem.storyUrl,
        searchStoriesResItem.storyName,
        searchStoriesResItem.storyDescription,
        [searchStoriesResItem.storyImageUrl],
        searchStoriesResItem.userId,
        searchStoriesResItem.collaboratorId,
        searchStoriesResItem.username,
        searchStoriesResItem.collaboratorName,
        searchStoriesResItem.channelId,
        searchStoriesResItem.channelName,
        searchStoriesResItem.channelImageUrl,
        searchStoriesResItem.voiceMessageStatus,
        searchStoriesResItem.userAvatarUrl,
        searchStoriesResItem.collaboratorAvatarUrl,
        searchStoriesResItem.storyLength,
        searchStoriesResItem.totalLength,
        searchStoriesResItem.storyUploadTime,
        null,
        searchStoriesResItem.isPremium,
        searchStoriesResItem.price,
      searchStoriesResItem.spaceName,
      searchStoriesResItem.count
    );
  }

  factory PlayerItemDto.fromSpaceStoryDto(SpaceStoryDto spaceStoryDto) {
    return PlayerItemDto(
      spaceStoryDto.storyId,
      spaceStoryDto.storyUrl,
      spaceStoryDto.storyName,
      spaceStoryDto.storyDescription,
      spaceStoryDto.storyImageUrls,
      spaceStoryDto.userId,
      spaceStoryDto.collaboratorId,
      spaceStoryDto.username,
      spaceStoryDto.collaboratorName,
      spaceStoryDto.channelId,
      spaceStoryDto.channelName,
      spaceStoryDto.channelImageUrl,
      spaceStoryDto.voiceMessageStatus,
      spaceStoryDto.userAvatarUrl,
      spaceStoryDto.collaboratorAvatarUrl,
      spaceStoryDto.storyLength,
      spaceStoryDto.totalLength,
      spaceStoryDto.releaseTime,
      null,
      spaceStoryDto.isPremium,
      spaceStoryDto.price,
      spaceStoryDto.spaceName,
      spaceStoryDto.count
    );
  }
}
import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/check_capacity_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/archive_short_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/buy_premium_story.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/create_draft_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/create_short_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/delete_draft_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_background_music_list_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_channel_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_ending_list_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_opening_list_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_show_shorts_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_sound_effect_list_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_stories_by_userid_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_story_count_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_story_shorts_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_user_premium_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/listen_story_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/read_rss_feed_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/archive_story_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/search_stories_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/signed_url_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/update_space_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/update_story_res.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/update_voice_message_status.dart';
import 'package:quick_share_app/dto/background_music_dto.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../dto/block_info_dto.dart';
import '../dto/story_dto.dart';
import 'channel_api_dto/update_channel_res.dart';
import 'story_api_dto/upload_story_res.dart';
import 'abstractApiManager.dart';

final storyApiManager = StoryApiManager(systemName: "STORY_SERVER_URL");

class SoundEffectReq {
  String url;
  int effectSecond;

  SoundEffectReq(this.url, this.effectSecond);

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "effectSecond": effectSecond
    };
  }
}

class StoryApiManager extends AbstractApiManager {
  StoryApiManager({required String systemName}) : super(systemName: systemName);

  Future<CheckCapacityRes> checkCapacity(String userId, int storyLength) async {
    var data = {
      "userId": userId,
      "currentStoryLength": storyLength
    };

    Response response = await handelPostWithUserToken("/story/checkCapacity", data);
    return CheckCapacityRes.fromJson(response.data);
  }

  Future<UploadStoryRes> uploadStory(
      String spaceId,
      String channelId,
      String contentUrl,
      String storyName,
      String storyDescription,
      List<String> storyImageUrls,
      int storyMilliSec,
      int previewStartFrom,
      int previewEndAt,
      String voiceMessageStatus,
      bool isPremium,
      String? collaboratorId,
      DateTime? releaseTime
    ) async {
    var data = {
      "userId": UserService.getUserInfo()!.userId,
      "contentUrl": contentUrl,
      "spaceId": spaceId,
      "channelId": channelId,
      "storyName": storyName,
      "storyDescription": storyDescription,
      "storyImageUrls": storyImageUrls,
      "storyMilliSec": storyMilliSec,
      "previewStartFrom": previewStartFrom,
      "previewEndAt": previewEndAt,
      "voiceMessageStatus": voiceMessageStatus,
      "isPremium": isPremium,
      "collaboratorId": collaboratorId == null || collaboratorId == "" || collaboratorId == UserService.getUserInfo()!.userId? "" : collaboratorId,
      "releaseTime": releaseTime?.toUtc().toIso8601String(),
    };

    Response response = await handelPostWithUserToken("/story/", data);
    return UploadStoryRes.fromJson(response.data);
  }

  Future<SignedUrlRes> signedUrl(String storyId) async {
    var data = {
      "storyId": storyId
    };
    
    Response response = await handelPostWithUserToken("/story/premium/signed", data);
    return SignedUrlRes.fromJson(response.data);
  }
  
  Future<BuyPremiumStoryRes> buyPremiumStory(String storyId) async {
    var data = {
      "storyId": storyId
    };
    
    Response response = await handelPostWithUserToken("/story/premium/buy", data);
    return BuyPremiumStoryRes.fromJson(response.data);
  }

  Future<UpdateStoryRes> updateStory(
      String storyId,
      String storyName,
      String storyDescription,
      String collaboratorId,
      List<String> storyImageUrls,
  ) async {
    var data = {
      "storyId": storyId,
      "storyName": storyName,
      "storyDescription": storyDescription,
      "storyImageUrls": storyImageUrls,
      "collaboratorId": collaboratorId
    };
    
    Response response = await handelPostWithUserToken("/story/update", data);
    return UpdateStoryRes.fromJson(response.data);
  }

  Future<UpdateSpaceRes> updateSpace(String storyId, String spaceId) async {
    var data = {
      "storyId": storyId,
      "spaceId": spaceId
    };
    
    Response response = await handelPostWithUserToken("/story/space/update", data);
    return UpdateSpaceRes.fromJson(response.data);
  }

  Future<UpdateChannelRes> updateChannel(String storyId, String channelId) async {
    var data = {
      "storyId": storyId,
      "channelId": channelId
    };

    Response response = await handelPostWithUserToken("/story/channel/update", data);
    return UpdateChannelRes.fromJson(response.data);
  }

  Future<GetStoriesByUserIdRes> getStoriesByUserId(String userId, {bool filterReviewStatus = true}) async {
    String queryParam = "?filterReviewStatus=${filterReviewStatus.toString()}";
    Response response = await handelGet("/story/user/$userId$queryParam");
    return GetStoriesByUserIdRes.fromJson(response.data);
  }

  Future<GetUserPremiumStoriesRes> getUserPremiumStories(String userId) async {
    Response response = await handelGet("/story/user/$userId/premium");
    return GetUserPremiumStoriesRes.fromJson(response.data);
  }

  Future<GetChannelStoriesRes> getChannelStories(String channelId) async {
    Response response = await handelGet("/story/channel/$channelId");
    return GetChannelStoriesRes.fromJson(response.data);
  }

  Future<UpdateVoiceMessageStatus> updateVoiceMessageStatus(String storyId, bool voiceMessageStatus) async {
    var data = {
      "storyId": storyId,
      "voiceMessageStatus": voiceMessageStatus? "enable" : "disable"
    };

    Response response = await handelPostWithUserToken("/voiceMessageStatus/update", data);
    return UpdateVoiceMessageStatus.fromJson(response.data);
  }

  Future<SearchStoriesRes> searchStories(String searchString) async {
    var data = {
      "storyName": searchString
    };

    Response response = await handelPost("/story/search", data);
    return SearchStoriesRes.fromJson(response.data);
  }

  Future<GetOneStoryRes> getOneStory(String storyId) async {
    Response response = await handelGet("/story/$storyId");
    return GetOneStoryRes.fromJson(response.data);
  }

  Future<GetStoryCountRes> getStoryCount(String userId) async {
    Response response = await handelGet("/story/user/$userId/count");
    return GetStoryCountRes.fromJson(response.data);
  }

  Future<ArchiveStoryRes> removeStory(String storyId) async {
    var data = {
      "storyId": storyId,
    };

    Response response = await handelPost("/delete", data);
    return ArchiveStoryRes.fromJson(response.data);
  }

  Future<GetOpeningListRes> getOpeningList() async {
    Response response = await handelGet("/list/opening");
    return GetOpeningListRes.fromJson(response.data);
  }

  Future<GetEndingListRes> getEndingList() async {
    Response response = await handelGet("/list/ending");
    return GetEndingListRes.fromJson(response.data);
  }

  Future<ReadRssFeedRes> readRssFeed(String rssFeed) async {
    var data = {
      "rssFeedUrl": rssFeed,
    };

    Response response = await handelPost("/rssFeed/read", data);
    return ReadRssFeedRes.fromJson(response.data);
  }
  
  Future<ArchiveStoryRes> archiveStory(String storyId) async {
    Response response = await handelPostWithUserToken("/story/$storyId/archive", {});
    return ArchiveStoryRes.fromJson(response.data);
  }

  Future<ListenStoryRes> listenStory(String storyId, String deviceId) async {
    Response response = await handelPost("/story/$storyId/device/$deviceId/listen", {});
    return ListenStoryRes.fromJson(response.data);
  }

  Future<CreateShortRes> createShort(String storyId, String videoId) async {
    var data = {
      "storyId": storyId,
      "videoId": videoId
    };

    Response response = await handelPostWithUserToken("/story/shorts", data);
    return CreateShortRes.fromJson(response.data);
  }

  Future<ArchiveShortRes> archiveShort(String shortId) async {
    Response response = await handelPostWithUserToken("/story/shorts/$shortId/archive", null);
    return ArchiveShortRes.fromJson(response.data);
  }

  Future<GetStoryShortsRes> getStoryShorts(String storyId) async {
    Response response = await handelGet("/story/shorts/$storyId");
    return GetStoryShortsRes.fromJson(response.data);
  }

  Future<GetShowShortsRes> getShowShorts() async {
    Response response = await handelGet("/story/shorts/show");
    return GetShowShortsRes.fromJson(response.data);
  }
}
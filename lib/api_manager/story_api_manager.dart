import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:dio/dio.dart';

final storyApiManager = StoryApiManager(systemName: "STORY_SERVER_URL");

class StoryApiManager extends AbstractApiManager {
  StoryApiManager({required String systemName}) : super(systemName: systemName);

  // Future<GetStoriesByUserIdRes> getStoriesByUserId(String userId, {bool filterReviewStatus = true}) async {
  //   String queryParam = "?filterReviewStatus=${filterReviewStatus.toString()}";
  //   Response response = await handelGet("/story/user/$userId$queryParam");
  //   return GetStoriesByUserIdRes.fromJson(response.data);
  // }

  // Future<GetChannelStoriesRes> getChannelStories(String channelId) async {
  //   Response response = await handelGet("/story/channel/$channelId");
  //   return GetChannelStoriesRes.fromJson(response.data);
  // }

  // Future<GetStoriesByUserIdRes> getStoriesByCollectionId(String collectionId) async {
  //   Response response = await handelGet("/outer/collections/collectionId?collectionId=$collectionId");
  //   return GetStoriesByUserIdRes.fromJson(response.data);
  // }

  // Future<GetVoiceMessageStatusRes> getStoryVoiceMessageStatus(String storyId) async {
  //   Response response = await handelGet("/voiceMessageStatus/find?storyId=$storyId");
  //   return GetVoiceMessageStatusRes.fromJson(response.data);
  // }

  Future<GetOneStoryRes> getOneStory(String storyId) async {
    Response response = await handelGet("/story/$storyId");
    return GetOneStoryRes.fromJson(response.data);
  }

  // Future<ListenStoryRes> listenStory(String storyId, String deviceId) async {
  //   Response response = await handelPost("/story/$storyId/device/$deviceId/listen", {});
  //   return ListenStoryRes.fromJson(response.data);
  // }
}
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
    // Response response = await handelGet("/story/$storyId");
    // return GetOneStoryRes.fromJson(response.data);
    return GetOneStoryRes(
      "0000",
      "ok",
      GetOneStoryResItem(
        "67dc24ec69734f0001aa7d1c",
        "6703eec019da7f00015be711",
        "6733739e64268700011f8a29",
        "671b7bb0c16fc0000133272b",
        "channelName",
        "https://story.actpodapp.com/story/image/67dc24eca07180000121b0a4.jpg",
        "enable",
        "https://story.actpodapp.com/story/story_audio/67dc24ee9a0d6d0001549c25",
        "storyName",
        "story description",
        "https://story.actpodapp.com/story/image/67dc24eca07180000121b0a4.jpg",
        4660,
        4660,
        DateTime.now(),
        DateTime.now(),
        "",
        "",
        "https://story.actpodapp.com/story/image/67dc24eca07180000121b0a4.jpg",
        "nickname"
      ),
    );
  }

  // Future<ListenStoryRes> listenStory(String storyId, String deviceId) async {
  //   Response response = await handelPost("/story/$storyId/device/$deviceId/listen", {});
  //   return ListenStoryRes.fromJson(response.data);
  // }
}
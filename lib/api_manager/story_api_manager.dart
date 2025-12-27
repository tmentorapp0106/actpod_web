import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_story_count_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';
import 'package:actpod_web/api_manager/story_dto/signed_url_res.dart';
import 'package:dio/dio.dart';

import 'story_dto/listen_story_res.dart';

final storyApiManager = StoryApiManager(systemName: "STORY_SERVER_URL");

class StoryApiManager extends AbstractApiManager {
  StoryApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetOneStoryRes> getOneStory(String storyId) async {
    Response response = await handelGet("/story/$storyId");
    return GetOneStoryRes.fromJson(response.data);
  }

  Future<ListenStoryRes> listenStory(String storyId, String deviceId) async {
    Response response = await handelPost("/story/$storyId/device/$deviceId/listen", {});
    return ListenStoryRes.fromJson(response.data);
  }

  Future<GetStoriesByUserIdRes> getStoriesByUserId(String userId, {bool filterReviewStatus = true}) async {
    String queryParam = "?filterReviewStatus=${filterReviewStatus.toString()}";
    Response response = await handelGet("/story/user/$userId$queryParam");
    return GetStoriesByUserIdRes.fromJson(response.data);
  }

  Future<GetStoryCountRes> getStoryCount(String userId) async {
    Response response = await handelGet("/story/user/$userId/count");
    return GetStoryCountRes.fromJson(response.data);
  }

  Future<SignedUrlRes> signedUrl(String storyId) async {
    var data = {
      "storyId": storyId
    };
    
    Response response = await handelPostWithUserToken("/story/premium/signed", data);
    return SignedUrlRes.fromJson(response.data);
  }
}
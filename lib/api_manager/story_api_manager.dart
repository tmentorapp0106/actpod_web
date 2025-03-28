import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
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
}
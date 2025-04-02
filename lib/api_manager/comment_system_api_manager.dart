import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:dio/dio.dart';

import 'abstractApiManager.dart';

final commentApiManager = CommentApiManager(systemName: "COMMENT_SERVER_URL");

class CommentApiManager extends AbstractApiManager {

  CommentApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetStoryStatRes> getStoryStat(String storyId) async {
    Response response = await handelGet("/comment/storyStat/story/$storyId");
    return GetStoryStatRes.fromJson(response.data);
  }
}
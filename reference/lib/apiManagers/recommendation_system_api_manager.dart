import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/recommendation_api_dto/get_recommendation_res.dart';
import 'package:quick_share_app/apiManagers/recommendation_api_dto/share_res.dart';

import 'abstractApiManager.dart';

final recommendationManager =
    RecommendationManager(systemName: "RECOMMEND_SERVER_URL");

class RecommendationManager extends AbstractApiManager {
  RecommendationManager({required String systemName}) : super(systemName: systemName);

  Future<GetRecommendationRes> getRecommendationList(
      int page, int pageSize) async {
    Response response = await handelGet(
        "/general?page=${page.toString()}&pageSize=${pageSize.toString()}");
    return GetRecommendationRes.fromJson(response.data);
  }

  Future<ShareRes> share(String userId, String storyId) async {
    var data = {
      "userId": userId,
      "storyId": storyId,
    };

    Response response = await handelPostWithUserToken("/share/new", data);
    return ShareRes.fromJson(response.data);
  }
}

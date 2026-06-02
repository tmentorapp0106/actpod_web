import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/recommendation_dto/get_recommendation_res.dart';
import 'package:dio/dio.dart';

final recommendationApiManager = RecommendationApiManager(systemName: "RECOMMENDATION_SERVER_URL");

class RecommendationApiManager extends AbstractApiManager {

  RecommendationApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetRecommendationRes> getRecommendationList(int page, int pageSize) async {
    Response response = await handelGet(
        "/general?page=${page.toString()}&pageSize=${pageSize.toString()}");
    return GetRecommendationRes.fromJson(response.data);
  }
}
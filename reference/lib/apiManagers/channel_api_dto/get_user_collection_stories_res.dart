import 'package:quick_share_app/dto/story_recommendation_dto.dart';

class GetUserCollectionStoriesRes {
  String code;
  String message;
  List<RecommendationItem>? collectionStoryList;

  GetUserCollectionStoriesRes(this.code, this.message, this.collectionStoryList);

  factory GetUserCollectionStoriesRes.fromJson(Map<String, dynamic> json) {
    return GetUserCollectionStoriesRes(
        json["code"],
        json["message"],
        json["data"]?.map<RecommendationItem>((json) => RecommendationItem.fromJson(json)).toList()
    );
  }
}
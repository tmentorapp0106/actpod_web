import 'package:actpod_web/api_manager/story_dto/get_user_stories_res.dart';

class GetPurchasedStoriesRes {
  String code;
  String message;
  List<StoryItem>? stories;

  GetPurchasedStoriesRes(this.code, this.message, this.stories);

  factory GetPurchasedStoriesRes.fromJson(Map<String, dynamic> json) {
    return GetPurchasedStoriesRes(
      json["code"] as String,
      json["message"] as String,
      json["data"]?.map<StoryItem>( (json) => StoryItem.fromJson(json) ).toList(), // Handle null case
    );
  }
}
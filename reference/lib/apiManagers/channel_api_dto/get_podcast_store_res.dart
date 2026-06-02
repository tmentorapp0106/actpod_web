import 'package:quick_share_app/dto/podcast_store_dto.dart';

class GetPodcastStoreRes {
  String code;
  String message;
  PodcastStoreDto? podcastStoreDto;

  GetPodcastStoreRes(this.code, this.message, this.podcastStoreDto);

  factory GetPodcastStoreRes.fromJson(Map<String, dynamic> json) {
    return GetPodcastStoreRes(
        json["code"],
        json["message"],
        json["data"] == null? null : PodcastStoreDto.fromJson(json["data"])
    );
  }
}
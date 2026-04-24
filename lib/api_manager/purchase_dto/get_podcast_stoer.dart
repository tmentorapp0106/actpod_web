import 'package:actpod_web/features/podcast_store_page/dto/podcast_store.dart';

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
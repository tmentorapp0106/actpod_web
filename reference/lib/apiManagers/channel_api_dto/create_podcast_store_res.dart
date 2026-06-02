class CreatePodcastStoreRes {
  String code;
  String message;

  CreatePodcastStoreRes(this.code, this.message);

  factory CreatePodcastStoreRes.fromJson(Map<String, dynamic> json) {
    return CreatePodcastStoreRes(json["code"], json["message"]);
  }
}
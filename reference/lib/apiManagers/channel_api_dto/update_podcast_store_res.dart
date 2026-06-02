class UpdatePodcastStoreRes {
  String code;
  String message;

  UpdatePodcastStoreRes(this.code, this.message);

  factory UpdatePodcastStoreRes.fromJson(Map<String, dynamic> json) {
    return UpdatePodcastStoreRes(json["code"], json["message"]);
  }
}
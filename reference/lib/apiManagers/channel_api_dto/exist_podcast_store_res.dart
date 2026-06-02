class ExistPodcastStoreRes {
  String code;
  String message;
  bool exist;

  ExistPodcastStoreRes(this.code, this.message, this.exist);

  factory ExistPodcastStoreRes.fromJson(Map<String, dynamic> json) {
    return ExistPodcastStoreRes(json["code"], json["message"], json["data"]);
  }
}
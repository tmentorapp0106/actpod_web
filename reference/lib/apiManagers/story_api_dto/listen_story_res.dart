class ListenStoryRes {
  String code;
  String message;

  ListenStoryRes(this.code, this.message);

  factory ListenStoryRes.fromJson(Map<String, dynamic> json) {
    return ListenStoryRes(json["code"], json["message"]);
  }
}
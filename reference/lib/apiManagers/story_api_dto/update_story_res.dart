class UpdateStoryRes {
  String code;
  String message;

  UpdateStoryRes(this.code, this.message);

  factory UpdateStoryRes.fromJson(Map<String, dynamic> json) {
    return UpdateStoryRes(json["code"], json["message"]);
  }
}
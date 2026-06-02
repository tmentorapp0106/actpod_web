class UploadStoryRes {
  String code;
  String message;
  String? storyId;

  UploadStoryRes(this.code, this.message, this.storyId);

  factory UploadStoryRes.fromJson(Map<String, dynamic> json) {
    return UploadStoryRes(json["code"], json["message"], json["data"]);
  }
}
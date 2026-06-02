class CreateBackgroundMusicRes {
  String code;
  String message;

  CreateBackgroundMusicRes(this.code, this.message);

  factory CreateBackgroundMusicRes.fromJson(Map<String, dynamic> json) {
    return CreateBackgroundMusicRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
    );
  }
}
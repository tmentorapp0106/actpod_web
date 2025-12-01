class GetStoryCountRes {
  String code;
  String message;
  int? count;

  GetStoryCountRes(
    this.code,
    this.message,
    this.count
  );

  factory GetStoryCountRes.fromJson(Map<String, dynamic> json) {
    return GetStoryCountRes(
        json["code"],
        json["message"],
        json["data"]
    );
  }
}
class GetStoryStatRes {
  String code;
  String message;
  GetStoryStatResItem data;

  GetStoryStatRes(this.code, this.message, this.data);

  factory GetStoryStatRes.fromJson(Map<String, dynamic> json) {
    return GetStoryStatRes(
        json["code"],
        json["message"],
        GetStoryStatResItem.fromJson(json["data"])
    );
  }
}

class GetStoryStatResItem {
  String storyId;
  String userId;
  int commentCount;
  int likeCount;

  GetStoryStatResItem(this.storyId, this.userId, this.commentCount, this.likeCount);

  factory GetStoryStatResItem.fromJson(Map<String, dynamic> json) {
    return GetStoryStatResItem(
      json["storyId"],
      json["userId"],
      json["commentCount"],
      json["likeCount"]
    );
  }
}
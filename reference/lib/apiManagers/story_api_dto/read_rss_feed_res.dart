class ReadRssFeedRes {
  String code;
  String message;
  List<ReadRssFeedResItem> data;

  ReadRssFeedRes(this.code, this.message, this.data);

  factory ReadRssFeedRes.fromJson(Map<String, dynamic> json) {
    return ReadRssFeedRes(
      json["code"],
      json["message"],
      json["data"] == null? [] : json["data"]?.map<ReadRssFeedResItem>((json) => ReadRssFeedResItem.fromJson(json)).toList());
  }
}

class ReadRssFeedResItem {
  String storyName;
  String storyDescription;
  String storyImageUrl;
  String audioUrl;
  int storyLength;

  ReadRssFeedResItem(this.storyName, this.storyDescription, this.storyImageUrl, this.audioUrl, this.storyLength);

  factory ReadRssFeedResItem.fromJson(Map<String, dynamic> json) {
    return ReadRssFeedResItem(
      json["storyName"],
      json["storyDescription"],
      json["storyImageUrl"],
      json["audioUrl"],
      json["storyLength"]
    );
  }
}
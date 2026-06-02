class SearchChannelRes {
  String code;
  String message;
  List<SearchChannelItem>? channelInfoList;

  SearchChannelRes(this.code, this.message, this.channelInfoList);

  factory SearchChannelRes.fromJson(Map<String, dynamic> json) {
    List<SearchChannelItem>? channelInfoList = json["data"] != null
        ? (json["data"] as List)
        .map((e) => SearchChannelItem.fromJson(e))
        .toList()
        : null;

    return SearchChannelRes(json["code"], json["message"], channelInfoList);
  }
}

class SearchChannelItem {
  String channelId;
  String userId;
  String nickname;
  String channelDescription;
  String channelName;
  String channelImageUrl;
  int storyCount;
  DateTime createTime;

  SearchChannelItem(
    this.channelId,
    this.userId,
    this.nickname,
    this.channelDescription,
    this.channelName,
    this.channelImageUrl,
    this.storyCount,
    this.createTime
  );

  factory SearchChannelItem.fromJson(Map<String, dynamic> json) {
    return SearchChannelItem(
      json["channelId"],
      json["userId"],
      json["nickname"],
      json["channelDescription"],
      json["channelName"],
      json["channelImageUrl"],
      json["storyCount"],
      DateTime.parse(json["createTime"])
    );
  }
}
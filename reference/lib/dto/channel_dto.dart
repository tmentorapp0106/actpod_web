class ChannelDto {
  String channelId;
  String userId;
  List<String> coOwners;
  String nickname;
  String userAvatarUrl;
  String channelDescription;
  String channelName;
  String channelImageUrl;
  int storyCount;
  DateTime createTime;

  ChannelDto(
    this.channelId,
    this.userId,
    this.coOwners,
    this.nickname,
    this.userAvatarUrl,
    this.channelDescription,
    this.channelName,
    this.channelImageUrl,
    this.storyCount,
    this.createTime
  );

  factory ChannelDto.fromJson(Map<String, dynamic> json) {
    return ChannelDto(
      json["channelId"],
      json["userId"],
      List<String>.from(json["coOwners"] ?? []),
      json["nickname"],
      json["userAvatarUrl"],
      json["channelDescription"],
      json["channelName"],
      json["channelImageUrl"],
      json["storyCount"],
      DateTime.parse(json["createTime"])
    );
  }
}
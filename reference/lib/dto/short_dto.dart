class ShortDto {
  String shortId;
  String storyId;
  String videoId;

  ShortDto(this.shortId, this.storyId, this.videoId);

  factory ShortDto.fromJson(Map<String, dynamic> json) {
    return ShortDto(
      json["shortId"],
      json["storyId"],
      json["videoId"]
    );
  }
}

class ShowShortDto {
  String shortId;
  String storyId;
  String videoId;
  String storyName;
  String storyImageUrl;
  String channelId;
  String channelName;
  String channelImageUrl;

  ShowShortDto(
    this.shortId,
    this.storyId,
    this.videoId,
    this.storyName,
    this.storyImageUrl,
    this.channelId,
    this.channelName,
    this.channelImageUrl
  );

  factory ShowShortDto.fromJson(Map<String, dynamic> json) {
    return ShowShortDto(
      json["shortId"],
      json["storyId"],
      json["videoId"],
      json["storyName"],
      json["storyImageUrl"],
      json["channelId"],
      json["channelName"],
      json["channelImageUrl"]
    );
  }
}
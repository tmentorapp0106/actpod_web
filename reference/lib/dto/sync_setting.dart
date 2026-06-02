class SyncSettingDto {
  String userId;
  String feed;
  DateTime lastPubDate;
  bool autoSync;
  String channelId;
  String channelName;
  String spaceId;
  String spaceName;

  SyncSettingDto(
    this.userId,
    this.feed,
    this.lastPubDate,
    this.autoSync,
    this.channelId,
    this.channelName,
    this.spaceId,
    this.spaceName
  );

  factory SyncSettingDto.fromJson(Map<String, dynamic> json) {
    return SyncSettingDto(
      json["userId"],
      json["feed"],
      DateTime.parse(json["lastPubDate"]),
      json["autoSync"],
      json["channelId"],
      json["channelName"],
      json["spaceId"],
      json["spaceName"],
    );
  }
}
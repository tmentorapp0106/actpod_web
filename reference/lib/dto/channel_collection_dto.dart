class ChannelCollectionDto {
  String collectionId;
  String channelId;
  String channelName;
  String channelDescription;
  String channelImageUrl;
  DateTime createTime;

  ChannelCollectionDto({
    required this.collectionId,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.channelImageUrl,
    required this.createTime,
  });

  factory ChannelCollectionDto.fromJson(Map<String, dynamic> json) {
    return ChannelCollectionDto(
      collectionId: json["collectionId"],
      channelId: json["channelId"],
      channelName: json["channelName"],
      channelDescription: json["channelDescription"],
      channelImageUrl: json["channelImageUrl"],
      createTime: DateTime.parse(json["createTime"])
    );
  }
}
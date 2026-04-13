class LiveRoomDto {
  String playingUrl;
  String playerStatus;
  String roomId;
  String roomType;
  String title;
  String storyId;
  String storyName;
  List<String> storyImages;
  String hostId;
  String hostName;
  String hostAvatarUrl;
  String channelId;
  String channelName;
  String channelImageUrl;
  int capacity;
  int memberCount;
  DateTime createTime;

  LiveRoomDto(
    this.playingUrl,
    this.playerStatus,
    this.roomId,
    this.roomType,
    this.title,
    this.storyId,
    this.storyName,
    this.storyImages,
    this.hostId,
    this.hostName,
    this.hostAvatarUrl,
    this.channelId,
    this.channelName,
    this.channelImageUrl,
    this.capacity,
    this.memberCount,
    this.createTime
  );

  factory LiveRoomDto.fromJson(Map<String, dynamic> json) {
    return LiveRoomDto(
      (json['playingUrl'] ?? '') as String,
      (json['playerStatus'] ?? '') as String,
      (json['roomId'] ?? '') as String,
      (json['roomType'] ?? '') as String,
      (json['title'] ?? '') as String,
      (json['storyId'] ?? '') as String,
      (json['storyName'] ?? '') as String,
      (json['storyImages'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      (json['hostId'] ?? '') as String,
      (json['hostName'] ?? '') as String,
      (json['hostAvatarUrl'] ?? '') as String,
      (json['channelId'] ?? '') as String,
      (json['channelName'] ?? '') as String,
      (json['channelImageUrl'] ?? '') as String,
      (json['capacity'] ?? 0) as int,
      (json['memberCount'] ?? 0) as int,
      DateTime.parse((json['createTime'] ?? '') as String), // ISO8601
    );
  }
}
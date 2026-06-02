class LiveRoomBackgroundMusicDto {
  String backgroundMusicId;
  String userId;
  String name;
  String mp3Url;
  String oggUrl;

  LiveRoomBackgroundMusicDto({
    required this.backgroundMusicId,
    required this.userId,
    required this.name,
    required this.mp3Url,
    required this.oggUrl,
  });

  factory LiveRoomBackgroundMusicDto.fromJson(Map<String, dynamic> json) {
    return LiveRoomBackgroundMusicDto(
      backgroundMusicId: json['backgroundMusicId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mp3Url: json['mp3Url'] as String? ?? '',
      oggUrl: json['oggUrl'] as String? ?? '',
    );
  }
}
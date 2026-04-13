class LiveRoomPlayerDto {
  String playerStatus;
  int position;
  String backgroundMusicUrl;
  double backgroundMusicVolume;

  LiveRoomPlayerDto({
    required this.playerStatus,
    required this.position,
    required this.backgroundMusicUrl,
    required this.backgroundMusicVolume
  });

  factory LiveRoomPlayerDto.fromJson(Map<String, dynamic> json) {
    return LiveRoomPlayerDto(
      playerStatus: json['playerStatus'] ?? '',
      position: json['position'] ?? 0,
      backgroundMusicUrl: json['backgroundMusicUrl'] ?? '',
      backgroundMusicVolume:
      (json['backgroundMusicVolume'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
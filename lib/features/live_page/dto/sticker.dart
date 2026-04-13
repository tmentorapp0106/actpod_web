class LiveRoomStickerDto {
  String stickerId;
  String url;
  String name;

  LiveRoomStickerDto(
    this.stickerId,
    this.url,
    this.name,
  );

  factory LiveRoomStickerDto.fromJson(Map<String, dynamic> json) {
    return LiveRoomStickerDto(
      (json['stickerId'] ?? '') as String,
      (json['url'] ?? '') as String,
      (json['name'] ?? '') as String,
    );
  }
}
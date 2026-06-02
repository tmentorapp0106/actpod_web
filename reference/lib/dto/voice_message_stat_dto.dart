class VoiceMessageStatDto {
  String storyId;
  String userId;
  String status;
  int count;

  VoiceMessageStatDto(
    this.storyId,
    this.userId,
    this.status,
    this.count
  );

  factory VoiceMessageStatDto.fromJson(Map<String, dynamic> json) {
    return VoiceMessageStatDto(
      json["storyId"],
      json["userId"],
      json["status"],
      json["count"]
    );
  }
}
import 'dart:convert';

class LiveRoomMemberDto {
  String userId;
  String nickname;
  String avatarUrl;
  bool isHandsUp;
  bool isSpeaking;

  LiveRoomMemberDto(
    this.userId,
    this.nickname,
    this.avatarUrl,
    this.isHandsUp,
    this.isSpeaking
  );

  factory LiveRoomMemberDto.fromJson(Map<String, dynamic> json) {
    return LiveRoomMemberDto(
      (json['userId'] ?? '') as String,
      (json['nickname'] ?? '') as String,
      (json['avatarUrl'] ?? '') as String,
      (json['isHandsUp'] ?? false) as bool,
      (json['isSpeaking'] ?? false) as bool,
    );
  }

  factory LiveRoomMemberDto.fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected a JSON object (Map), got ${decoded.runtimeType}');
    }

    return LiveRoomMemberDto.fromJson(decoded);
  }
}
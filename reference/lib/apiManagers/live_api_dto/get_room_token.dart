class GetRoomTokenRes {
  final String wsUrl;
  final String token;

  GetRoomTokenRes(this.wsUrl, this.token);

  factory GetRoomTokenRes.fromJson(Map<String, dynamic> json) {
    return GetRoomTokenRes(
      (json['data']['wsUrl'] ?? '') as String,
      (json['data']['token'] ?? '') as String,
    );
  }
}
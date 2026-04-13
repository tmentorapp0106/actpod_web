import 'package:actpod_web/features/live_page/dto/player.dart';

class GetRoomPlayerRes {
  String code;
  String message;
  LiveRoomPlayerDto player;

  GetRoomPlayerRes(this.code, this.message, this.player);

  factory GetRoomPlayerRes.fromJson(Map<String, dynamic> json) {
    return GetRoomPlayerRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      LiveRoomPlayerDto.fromJson(
        (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}
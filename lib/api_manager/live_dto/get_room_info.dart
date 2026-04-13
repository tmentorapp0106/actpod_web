import 'package:actpod_web/features/live_page/dto/live_room.dart';

class GetRoomInfoRes {
  String code;
  String message;
  LiveRoomDto room;

  GetRoomInfoRes(this.code, this.message, this.room);

  factory GetRoomInfoRes.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] ?? json['room']);

    // 期待是一個 Map
    final roomJson = raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    return GetRoomInfoRes(
      (json['code'] ?? '').toString(),
      (json['message'] ?? '').toString(),
      LiveRoomDto.fromJson(roomJson),
    );
  }
}
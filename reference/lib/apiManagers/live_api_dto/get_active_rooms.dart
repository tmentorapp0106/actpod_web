import 'package:quick_share_app/dto/live_room_dto.dart';

class GetActiveRoomsRes {
  String code;
  String message;
  List<LiveRoomDto> rooms;

  GetActiveRoomsRes(this.code, this.message, this.rooms);

  factory GetActiveRoomsRes.fromJson(Map<String, dynamic> json) {
    return GetActiveRoomsRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] as List<dynamic>? ?? const [])
          .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
import 'package:actpod_web/features/live_page/dto/bulletin.dart';

class GetRoomBulletins {
  String code;
  String message;
  List<RoomBulletinDto> bulletins;

  GetRoomBulletins(this.code, this.message, this.bulletins);

  factory GetRoomBulletins.fromJson(Map<String, dynamic> json) {
    return GetRoomBulletins(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] as List<dynamic>? ?? const [])
          .map((e) => RoomBulletinDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
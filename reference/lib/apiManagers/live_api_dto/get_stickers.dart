import '../../dto/live_room_sticker_dto.dart';

class GetRoomStickersRes {
  String code;
  String message;
  List<LiveRoomStickerDto> stickers;

  GetRoomStickersRes(this.code, this.message, this.stickers);

  factory GetRoomStickersRes.fromJson(Map<String, dynamic> json) {
    return GetRoomStickersRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] as List<dynamic>? ?? const [])
        .map((e) => LiveRoomStickerDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    );
  }
}
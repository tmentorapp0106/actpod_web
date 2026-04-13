import 'package:actpod_web/features/live_page/dto/chat.dart';

class GetRoomChatsRes {
  String code;
  String message;
  List<ChatMessageDto> chats;

  GetRoomChatsRes(this.code, this.message, this.chats);

  factory GetRoomChatsRes.fromJson(Map<String, dynamic> json) {
    return GetRoomChatsRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] as List<dynamic>? ?? const [])
          .map((e) => ChatMessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
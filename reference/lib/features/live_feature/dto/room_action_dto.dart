import 'package:quick_share_app/dto/live_room_member_dto.dart';

enum RoomAction {
  open,
  join,
  leave,
  close,
  playBackgroundMusic,
  stopBackgroundMusic
}

class RoomActionDto {
  RoomAction action;
  LiveRoomMemberDto? member;
  List<String>? params;

  RoomActionDto({required this.action, this.member, this.params});
}
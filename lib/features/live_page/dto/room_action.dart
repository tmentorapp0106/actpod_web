import 'package:actpod_web/features/live_page/dto/member.dart';

enum RoomAction {
  open,
  join,
  leave,
  close,
  playBackgroundMusic,
  stopBackgroundMusic,
}

class RoomActionDto {
  RoomAction action;
  LiveRoomMemberDto? member;
  List<String>? params;

  RoomActionDto({required this.action, this.member, this.params});
}
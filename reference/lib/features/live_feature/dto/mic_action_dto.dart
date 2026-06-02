import 'package:quick_share_app/dto/live_room_member_dto.dart';

enum MemberAction {
  attemptToSendInvitation,
  receivedInvitation,
  attemptToKickout,
  attemptToRevokeMic,
}

class MemberActionDto {
  MemberAction memberAction;
  LiveRoomMemberDto? memberInfo;

  MemberActionDto({required this.memberAction, this.memberInfo});
}
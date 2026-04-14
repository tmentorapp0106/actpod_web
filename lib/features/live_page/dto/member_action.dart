import 'package:actpod_web/features/live_page/dto/member.dart';

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
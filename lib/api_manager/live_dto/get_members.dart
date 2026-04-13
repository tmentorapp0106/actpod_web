import 'package:actpod_web/features/live_page/dto/member.dart';

class GetRoomMembersRes {
  String code;
  String message;
  List<LiveRoomMemberDto> members;

  GetRoomMembersRes(this.code, this.message, this.members);

  factory GetRoomMembersRes.fromJson(Map<String, dynamic> json) {
    return GetRoomMembersRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      (json['data'] as List<dynamic>? ?? const [])
          .map((e) => LiveRoomMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
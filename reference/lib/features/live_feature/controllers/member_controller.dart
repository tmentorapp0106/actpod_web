import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_livekit_status.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_room_members.dart';
import 'package:quick_share_app/apiManagers/live_system_api_manager.dart';
import 'package:quick_share_app/features/live_feature/dto/room_action_dto.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../dto/live_room_member_dto.dart';
import '../dto/ws_message_dto.dart';

class MemberController {
  final WidgetRef ref;
  final StreamController<RoomActionDto> roomActionStream;
  final StreamController<LiveKitCmd>? livekitStream;
  StreamSubscription<RoomActionDto>? _roomActionSub;
  String? _roomId;


  MemberController(this.ref, this.roomActionStream, this.livekitStream);

  Future<void> initMemberStreamController() async {
    await _roomActionSub?.cancel();
    _roomActionSub = null;
    _roomActionSub = roomActionStream.stream.listen((roomAction) async {
      if(roomAction.action == RoomAction.open) {
        _roomId = roomAction.params![0];
        GetRoomMembersRes response = await liveApiManager.getRoomMembers(_roomId!);
        if(response.code != "0000") {
          ToastService.showNoticeToast("找不到房間成員");
          return;
        }
        ref.watch(roomMembersProvider.notifier).state = response.members;
      } else if(roomAction.action == RoomAction.join) {
        List<LiveRoomMemberDto> members = ref.watch(roomMembersProvider);
        members.add(roomAction.member!);
        ref.watch(roomMembersProvider.notifier).state = [...members];
      } else if(roomAction.action == RoomAction.leave) {
        List<LiveRoomMemberDto> members = ref.watch(roomMembersProvider);
        members.removeWhere((member) => member.userId == roomAction.params![0]);
        ref.watch(roomMembersProvider.notifier).state = [...members];
      }
    });
  }

  void dispose() {
    _roomActionSub?.cancel();
    _roomActionSub = null;
  }
}
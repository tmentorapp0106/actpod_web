import 'dart:async';

import 'package:actpod_web/api_manager/live_api_manager.dart';
import 'package:actpod_web/api_manager/live_dto/get_livekit_status.dart';
import 'package:actpod_web/api_manager/live_dto/get_members.dart';
import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:actpod_web/features/live_page/dto/room_action.dart';
import 'package:actpod_web/features/live_page/dto/ws_message.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberController {
  final WidgetRef ref;
  final StreamController<RoomActionDto> roomActionStream;
  final StreamController<LiveKitCmd>? livekitStream;
  StreamSubscription<RoomActionDto>? _roomActionSub;
  String? _roomId;


  MemberController(this.ref, this.roomActionStream, this.livekitStream);

  Future<void> initMemberStreamController() async {
    _roomActionSub = roomActionStream.stream.listen((roomAction) async {
      if(roomAction.action == RoomAction.open) {
        _roomId = roomAction.params![0];
        GetRoomMembersRes response = await liveApiManager.getRoomMembers(_roomId!);
        if(response.code != "0000") {
          ToastService.showNoticeToast("找不到房間成員");
          return;
        }
        ref.watch(roomMembersProvider.notifier).state = response.members;

        if(livekitStream != null) {
          GetLivekitStatusRes livekitStatusRes = await liveApiManager.getLivekitStatus(_roomId!);
          if(livekitStatusRes.code != "0000") {
            return;
          }
          if(livekitStatusRes.status.started) {
            livekitStream?.add(LiveKitCmd(LiveKitAction.start, ""));
            List<String> userIdList = livekitStatusRes.status.onMicMembers;
            List<LiveRoomMemberDto> roomMembers = ref.read(roomMembersProvider);

            List<LiveRoomMemberDto> onMicList = [];
            for (final userId in userIdList) {
              final matches = roomMembers.where((m) => m.userId == userId);
              if (matches.isNotEmpty) {
                onMicList.add(matches.first);
              }
            }
            ref.watch(onMicMembersProvider.notifier).state = onMicList;
          }
        }
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
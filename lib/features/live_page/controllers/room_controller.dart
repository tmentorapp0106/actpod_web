import 'package:actpod_web/api_manager/live_api_manager.dart';
import 'package:actpod_web/api_manager/live_dto/get_members.dart';
import 'package:actpod_web/api_manager/live_dto/get_room_info.dart';
import 'package:actpod_web/features/live_page/dto/check_room.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/room.dart';

class RoomController {
  WidgetRef ref;

  RoomController(this.ref);

  Future<void> getRoomInfo(String roomId) async {
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(roomInfoProvider.notifier).state = response.room;

    GetRoomMembersRes membersRes = await liveApiManager.getRoomMembers(roomId);
    if(membersRes.code != "0000") {
      return;
    }
    ref.watch(roomMembersProvider.notifier).state = membersRes.members;
  }

	Future<CheckRoomRes> checkRoomInfo(String roomId) async {
    if(ref.read(userInfoProvider) == null) {
      return CheckRoomRes.error;
    }
    GetRoomInfoRes response = await liveApiManager.getRoomInfo(roomId);
    if(response.code != "0000") {
      return CheckRoomRes.error;
    }
    ref.watch(roomInfoProvider.notifier).state = response.room;

    if(response.room.capacity - response.room.memberCount <= 1) {
      return CheckRoomRes.full;
    }

    GetRoomMembersRes membersRes = await liveApiManager.getRoomMembers(roomId);
    if(membersRes.code != "0000") {
      return CheckRoomRes.error;
    }
    final currentUserId = ref.read(userInfoProvider)?.userId;
    final exists = membersRes.members.any((member) => member.userId == currentUserId);
    if(exists) {
      return CheckRoomRes.duplicate;
    }
    return CheckRoomRes.ok;
  }
}
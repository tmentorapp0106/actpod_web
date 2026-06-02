import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apiManagers/live_api_dto/get_active_rooms.dart';
import '../../../apiManagers/live_system_api_manager.dart';
import '../../../dto/live_room_dto.dart';
import '../../../services/toast_service.dart';
import '../providers.dart';

class LiveController {
  WidgetRef ref;

  LiveController(this.ref);

  Future<void> getLiveRooms() async {
    GetActiveRoomsRes response = await liveApiManager.getActiveRooms();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ref.watch(activeRoomsProvider.notifier).state = response.rooms;
  }
}
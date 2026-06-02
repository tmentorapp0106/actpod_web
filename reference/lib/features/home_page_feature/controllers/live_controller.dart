import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/get_active_rooms.dart';
import 'package:quick_share_app/apiManagers/live_system_api_manager.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

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
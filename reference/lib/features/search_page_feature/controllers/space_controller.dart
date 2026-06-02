import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apiManagers/space_api_dto/get_active_boards_res.dart';
import '../../../apiManagers/space_system_api_manager.dart';
import '../../../services/toast_service.dart';
import '../providers.dart';

class SpaceController {
  WidgetRef _ref;

  SpaceController(this._ref);

  Future<void> getSpaces() async {
    GetActiveSpacesRes response = await spaceApiManager.getActiveSpaces();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }

    if(response.spaces != null) {
      _ref.watch(spacesProvider.notifier).state = response.spaces!;
    }
  }
}
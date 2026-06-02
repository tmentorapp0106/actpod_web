import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/space_system_api_manager.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';

import '../../../apiManagers/space_api_dto/get_active_boards_res.dart';

class SpaceController {
  WidgetRef _ref;

  SpaceController(this._ref);

  Future<void> getSpaces() async {
    GetActiveSpacesRes resp = await spaceApiManager.getActiveSpaces();
    if(resp.code != "0000") {
      print(resp.message);
      return;
    }

    _ref.watch(spaceListProvider.notifier).state = resp.spaces?? [];
  }
}
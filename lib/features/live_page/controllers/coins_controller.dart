import 'package:actpod_web/api_manager/purchase_dto/get_user_purses.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinsController {
  WidgetRef ref;

  CoinsController(this.ref);

  Future<void> getUserPurses() async {
    GetUserPursesRes response = await purchaseApiManager.getUserPurses();
    if(response.code != "0000") {
      ToastService.showNoticeToast("獲取 Podcoins 與 Podcash 資訊失敗");
    }
    ref.watch(userPodCoinsProvider.notifier).state = response.purses!.coinsPurse.podCoins;
  }
}
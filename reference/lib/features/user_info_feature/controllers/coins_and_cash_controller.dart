import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/get_user_purses_res.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

class CoinsAndCashController {
  WidgetRef ref;

  CoinsAndCashController(this.ref);

  Future<void> getUserPurses() async {
    GetUserPursesRes response = await purchaseApiManager.getUserPurses();
    if(response.code != "0000") {
      ToastService.showNoticeToast("獲取 Podcoins 與 Podcash 資訊失敗");
    }
    ref.watch(userPodCoinsProvider.notifier).state = response.purses!.coinsPurse.podCoins;
    ref.watch(userPodCashProvider.notifier).state = response.purses!.cashPurse.podCash;
  }
}
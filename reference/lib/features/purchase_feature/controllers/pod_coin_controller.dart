
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import '../../../apiManagers/purchase_api_dto/get_user_purses_res.dart';
import '../../../providers.dart';
import '../../../services/toast_service.dart';

class PodCoinController {
  WidgetRef _ref;

  PodCoinController(this._ref);

  Future<void> getCoinList() async {
    List<Offering> offers = await PurchaseSystemApi.fetchPodCoins();
    offers.sort((offerA, offerB) {
      int a = offerA.metadata["ntdDollar"] as int;
      int b = offerB.metadata["ntdDollar"] as int;
      if(a > b) {
        return 1;
      } else if(a == b) {
        return 0;
      } else {
        return -1;
      }
    });
    _ref.watch(podCoinsListProvider.notifier).state = offers;
  }

  Future<void> getUserPurses() async {
    GetUserPursesRes response = await purchaseApiManager.getUserPurses();
    if(response.code != "0000") {
      ToastService.showNoticeToast("failed to fetch podCoins and podCash");
    }
    _ref.watch(userPodCoinsProvider.notifier).state = response.purses!.coinsPurse.podCoins;
    _ref.watch(userPodCashProvider.notifier).state = response.purses!.cashPurse.podCash;
  }
}
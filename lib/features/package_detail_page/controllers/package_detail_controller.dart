import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/check_purchase_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_package_info_res.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageDetailController {
  final WidgetRef ref;

  PackageDetailController(this.ref);

  Future<void> getPackageInfo(String packageId) async {
    ref.watch(packageDetailLoadingProvider.notifier).state = true;
    ref.watch(packageDetailErrorProvider.notifier).state = null;

    try {
      final GetPackageInfoRes response =
          await storyApiManager.getPackageInfo(packageId);
      if (response.code != "0000") {
        ref.watch(packageDetailErrorProvider.notifier).state = response.message;
        ToastService.showNoticeToast("獲取套裝資訊失敗");
        return;
      }
      ref.watch(packageDetailProvider.notifier).state = response.packageInfo;
    } catch (e) {
      ref.watch(packageDetailErrorProvider.notifier).state = e.toString();
      ToastService.showNoticeToast("獲取套裝資訊失敗");
    } finally {
      ref.watch(packageDetailLoadingProvider.notifier).state = false;
    }
  }

  Future<bool> checkPurchased(String packageId) async {
    if (!await AuthService.ensureLoggedIn()) {
      ref.watch(packagePurchasedProvider.notifier).state = false;
      return false;
    }
    ref.watch(packagePurchasedProvider.notifier).state = null;
    try {
      CheckPurchaseRes response =
          await storyApiManager.checkPurchased("", packageId);
      final bool purchased = response.code == "0000" && response.purchased;
      ref.watch(packagePurchasedProvider.notifier).state = purchased;
      return purchased;
    } catch (e) {
      ref.watch(packagePurchasedProvider.notifier).state = false;
      ToastService.showNoticeToast("確認購買狀態失敗");
      return false;
    }
  }
}

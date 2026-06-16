import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_package_info_res.dart';
import 'package:actpod_web/features/package_purchase_fail/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackagePurchaseFailController {
  final WidgetRef ref;

  PackagePurchaseFailController(this.ref);

  Future<void> getPackageInfo(String packageId) async {
    ref.watch(packagePurchaseFailLoadingProvider.notifier).state = true;
    ref.watch(packagePurchaseFailErrorProvider.notifier).state = null;

    try {
      final GetPackageInfoRes response =
          await storyApiManager.getPackageInfo(packageId);
      if (response.code != "0000") {
        ref.watch(packagePurchaseFailErrorProvider.notifier).state =
            response.message;
        ToastService.showNoticeToast("獲取套裝資訊失敗");
        return;
      }

      ref.watch(packagePurchaseFailProvider.notifier).state =
          response.packageInfo;
    } catch (e) {
      ref.watch(packagePurchaseFailErrorProvider.notifier).state = e.toString();
      ToastService.showNoticeToast("獲取套裝資訊失敗");
    } finally {
      ref.watch(packagePurchaseFailLoadingProvider.notifier).state = false;
    }
  }
}

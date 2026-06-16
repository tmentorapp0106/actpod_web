import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_package_info_res.dart';
import 'package:actpod_web/features/package_purchase_success/providers.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackagePurchaseSuccessController {
  final WidgetRef ref;

  PackagePurchaseSuccessController(this.ref);

  Future<void> getPackageInfo(String packageId) async {
    ref.watch(packagePurchaseSuccessLoadingProvider.notifier).state = true;
    ref.watch(packagePurchaseSuccessErrorProvider.notifier).state = null;

    try {
      final GetPackageInfoRes response = await storyApiManager.getPackageInfo(packageId);
      if (response.code != "0000") {
        ref.watch(packagePurchaseSuccessErrorProvider.notifier).state =
            response.message;
        ToastService.showNoticeToast("獲取套裝資訊失敗");
        return;
      }

      ref.watch(packagePurchaseSuccessProvider.notifier).state =
          response.packageInfo;
    } catch (e) {
      ref.watch(packagePurchaseSuccessErrorProvider.notifier).state =
          e.toString();
      ToastService.showNoticeToast("獲取套裝資訊失敗");
    } finally {
      ref.watch(packagePurchaseSuccessLoadingProvider.notifier).state = false;
    }
  }
}

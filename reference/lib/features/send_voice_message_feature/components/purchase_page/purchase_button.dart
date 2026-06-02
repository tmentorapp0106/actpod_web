import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../providers.dart';

class PurchaseButton extends ConsumerWidget {

  PurchaseButton();

  Future<void> polling(WidgetRef ref) async {
    final originCoins = ref.watch(userPodCoinsProvider);
    int attempts = 0;
    const maxAttempts = 4;
    const delayBetweenAttempts = Duration(seconds: 2);
    bool isSuccess = false;
    int finalPodcoins = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(delayBetweenAttempts);
      attempts++;

      try {
        final response = await purchaseApiManager.getUserPurses();
        finalPodcoins = response.purses?.coinsPurse.podCoins ?? 0;

        // 💡 Replace this logic with your actual check
        if (originCoins != finalPodcoins) {
          isSuccess = true;
          break;
        }
      } catch (e) {
        print("Error checking PodCoin status: $e");
      }
    }
    ref.watch(loadingProvider.notifier).state = false;
    if(isSuccess) {
      ref.watch(userPodCoinsProvider.notifier).state = finalPodcoins;
      ToastService.showSuccessToast("購買成功");
    } else {
      ToastService.showNoticeToast("Podcoins 轉換失敗！請稍後查看或是聯絡客服人員！");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        if(ref.watch(selectPodcoinProvider) == null) {
          return;
        }
        final offering = ref.watch(selectPodcoinProvider);
        ref.watch(loadingProvider.notifier).state = true;
        try {
          await purchaseApiManager.purchasePodCoins(offering!.availablePackages[0], offering);
        }on PlatformException catch (e) {
          final errorCode = PurchasesErrorHelper.getErrorCode(e);

          if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
            ref.watch(loadingProvider.notifier).state = false;
            return;
          }
          if(e.code == "1") { // cancel purchase
            ref.watch(loadingProvider.notifier).state = false;
            return;
          }
          ToastService.showNoticeToast("購買失敗");
          ref.watch(loadingProvider.notifier).state = false;
          return;
        } catch(e) {
          ToastService.showNoticeToast("購買失敗");
          ref.watch(loadingProvider.notifier).state = false;
          return;
        }
        polling(ref);
      },
      child: Container(
        width: 250.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: ConfigColor.primaryDefault,
          borderRadius: BorderRadius.circular(20.w)
        ),
        child: Center(
          child: Text(
            "儲值",
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.black
            ),
          )
        ),
      ),
    );
  }
}
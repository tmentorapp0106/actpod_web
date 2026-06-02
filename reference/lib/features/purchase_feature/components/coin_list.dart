import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';

import '../controllers/pod_coin_controller.dart';

class CoinList extends ConsumerWidget {
  final PodCoinController podCoinController;

  CoinList(this.podCoinController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinList = ref.watch(podCoinsListProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 105.w / 105.w,
          crossAxisCount: 3, // Number of columns in the grid
          crossAxisSpacing: 10.w, // Spacing between columns
          mainAxisSpacing: 3.h, // Spacing between rows
        ),
        itemCount: coinList.length,
        itemBuilder: (context, index) {
          return coinOption(ref, coinList[index]);
        }
      )
    );
  }

  Widget coinOption(WidgetRef ref, Offering offering) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        color: Colors.white,
        border: Border.all(
          color: ConfigColor.primaryDefault
        )
      ),
      child: GestureDetector(
        onTap: () async {
          try {
            ref.watch(loadingProvider.notifier).state = true;
            await purchaseApiManager.purchasePodCoins(offering.availablePackages[0], offering);
            await podCoinController.getUserPurses();
            ref.watch(loadingProvider.notifier).state = false;
          } on PlatformException catch (e) {
            final errorCode = PurchasesErrorHelper.getErrorCode(e);

            if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
              ref.watch(loadingProvider.notifier).state = false;
              return;
            }
            ref.watch(loadingProvider.notifier).state = false;
          }
          ref.watch(loadingProvider.notifier).state = false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/podcoins.png",
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.fitWidth,
                ),
                Text(
                  offering.metadata["coins"] as String,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32.sp
                  ),
                ),
              ]
            ),
            SizedBox(height: 10.h,),
            Text(
              offering.availablePackages[0].storeProduct.priceString,
              style: TextStyle(
                color: Color(0xff8f8f8f),
                fontSize: 16.sp
              ),
            )
          ],
        )
      ),
    );
  }
}
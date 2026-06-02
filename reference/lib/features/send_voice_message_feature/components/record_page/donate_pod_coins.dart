import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';
import '../../../../l10n/app_localizations.dart';

class DonatePodCoins extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> coinList = [10, 50, 100, 200, 500, 1000];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10.h,),
        Container(
          height: 3.h,
          width: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.grey
          ),
        ),
        SizedBox(
          height: 165.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 105.w / 70.w,
                crossAxisCount: 3, // Number of columns in the grid
                crossAxisSpacing: 20.w, // Spacing between columns
                mainAxisSpacing: 10.h, // Spacing between rows
              ),
              itemCount: coinList.length,
              itemBuilder: (context, index) {
                return coinOption(coinList[index], ref, context);
              }
            )
          )
        ),
        Padding(
          padding: EdgeInsets.only(left: 25.w, bottom: 10.h),
          child: remainPodCoins(ref, context)
        )
      ]
    );
  }

  Widget remainPodCoins(WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Text(
          "${AppLocalizations.of(context)!.remain}: ",
          style: TextStyle(
            fontSize: 14.sp,
            color: ConfigColor.textColorDefault
          ),
        ),
        Text(
          ref.watch(userPodCoinsProvider).toString(),
          style: TextStyle(
            fontSize: 22.sp,
            color: ConfigColor.textColorDefault
          ),
        ),
        Image.asset(
          "assets/images/podcoins.png",
          width: 25.w,
          height: 25.w,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }

  Widget coinOption(int podCoins, WidgetRef ref, BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20.w),
      color: ConfigColor.backgroundFifth,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.w),
        onTap: () {
          // ref.watch(donatePodCoinsProvider.notifier).state = podCoins;
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/podcoins.png",
              width: 25.w,
              height: 25.w,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(width: 5.w,),
            Text(
              podCoins.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                color: ConfigColor.textColorDefault
              ),
            )
          ],
        )
      )
    );
  }
}
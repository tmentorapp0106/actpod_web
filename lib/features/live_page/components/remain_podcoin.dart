import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RemainPodcoin extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Image.asset(
            "assets/images/podcoins.png",
            width: 20.w,
            height: 20.w,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(width: 4,),
          Text(
            "剩餘 Podcoin：${ref.watch(userPodCoinsProvider)}",
          ),
          SizedBox(width: 4.w,),
          ref.watch(selectedStickerDonateAmountProvider) > ref.watch(userPodCoinsProvider)? GestureDetector(
            onTap: () {
              // PurchasePodcoinDialog().show(context);
            },
            child: Text(
              "餘額不足,請先儲值",
              style: TextStyle(
                color: Color(0xff0067ed),
              ),
            )
          ) : const SizedBox.shrink()
        ],
      )
    );
  }
}
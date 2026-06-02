import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../providers.dart';
import '../../providers.dart';

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
          Text(
            "剩餘 Podcoin：${ref.watch(userPodCoinsProvider)}",
          ),
          SizedBox(width: 4.w,),
          ref.watch(donateAmountProvider) > ref.watch(userPodCoinsProvider)? GestureDetector(
            onTap: () {
              ref.watch(isPurchasingProvider.notifier).state = true;
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
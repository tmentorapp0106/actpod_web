import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../../providers.dart';


class PodCoins extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Podcoins",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 28.sp
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h,),
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
              ref.watch(userPodCoinsProvider).toString(),
              style: TextStyle(
                fontSize: 48.sp,
                color: ConfigColor.primaryDefault
              ),
            )
          ],
        )
      ],
    );
  }
}
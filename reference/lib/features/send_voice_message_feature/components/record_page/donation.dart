import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/record_page/donate_pod_coins.dart';
import 'package:quick_share_app/features/send_voice_message_feature/providers.dart';

import '../../../../config/color.dart';

class Donation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        donationAmount(context, ref),
        SizedBox(height: 2.h,),
        donateButton(context)
      ],
    );
  }

  Widget donationAmount(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "",
          // "${AppLocalizations.of(context)!.donate}: ${ref.watch(donatePodCoinsProvider).toString()}",
          style: TextStyle(
            fontSize: 18.sp,
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

  Widget donateButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20.w),
      color: ConfigColor.primaryDefault,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.w),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: ConfigColor.backgroundThird,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.w)
              )
            ),
            builder: (context) {
              return DonatePodCoins();
            }
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          child: Image.asset(
            "assets/icons/donation_icon.png",
            width: 25.w,
            height: 25.w,
            fit: BoxFit.fitWidth,
          )
        ),
      ),
    );
  }
}
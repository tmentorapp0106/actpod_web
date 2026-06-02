import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/coins_and_cash_controller.dart';

class CoinsAndCash extends ConsumerWidget {

  CoinsAndCash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        podCoin(ref, context),
        SizedBox(width: 16.w,),
        podCash(ref, context),
      ],
    );
  }

  Widget podCash(WidgetRef ref, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.w),
      onTap: () {
        if(!UserService.hasLoggedIn()) {
          showDialog(
              context: context,
              builder: (context) {
                return LoginPageScreen();
              }
          );
          return;
        }

        final podcash = ref.watch(userPodCashProvider);
        final membership = ref.watch(selfMembershipProvider);
        if(membership?.customerLevel == "Free") {
          router.push("/subscribe");
        } else if(podcash == 0) {
          ToastService.showNoticeToast("您尚無 PodCash 可提領喔！"); 
        } else {
          router.push("/withdraw");
        }
      },
      child: Row(
        children: [
          Image.asset(
            "assets/images/podcash.png",
            width: 24.w,
            height: 24.w,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(width: 5.w,),
          Text(
            ref.watch(userPodCashProvider).toString(),
            style: TextStyle(
              fontSize: 12.sp,
              color: ConfigColor.textColorDefault
            ),
          )
        ],
      ),
    );
  }

  Widget podCoin(WidgetRef ref, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.w),
      onTap: () {
        if(UserService.getUserToken() == null || UserService.getUserToken() == "") {
          showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          return;
        }
        router.push("/purchase");
      },
      child: Row(
        children: [
          PodCoin(size: 22.w),
          SizedBox(width: 6.w,),
          Text(
            ref.watch(userPodCoinsProvider).toString(),
            style: TextStyle(
              fontSize: 12.sp,
              color: ConfigColor.textColorDefault
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/purchase_page/podcoin_box.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/purchase_page/purchase_button.dart';
import 'package:quick_share_app/features/send_voice_message_feature/components/purchase_page/remain_podcoin.dart';
import 'package:quick_share_app/utils/device_utils.dart';

import '../components/purchase_page/upper_area.dart';

class PurchasePage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 280.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h,),
          UpperArea(),
          SizedBox(height: 20.h),
          PodcoinBox(),
          RemainPodcoin(),
          Divider(),
          SizedBox(height: 8.h,),
          PurchaseButton(),
          SizedBox(height: 12.h,),
        ]
      )
    );
  }
}
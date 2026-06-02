import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../providers.dart';

class UpperArea extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "贊助方案",
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold,
              color: ConfigColor.textColorDefault
            ),
          ),
          SizedBox(height: 12.h,),
          hintText()
        ]
      )
    );
  }

  Widget hintText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "您可以使用 Podcoin 以贊助創作者",
          style: TextStyle(
            fontSize: 14.w,
            color: Colors.grey
          ),
        )
      ]
    );
  }
}
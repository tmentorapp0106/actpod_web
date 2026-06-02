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

    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "回覆語音留言",
                style: TextStyle(
                  fontSize: 24.w,
                fontWeight: FontWeight.bold,
                color: ConfigColor.textColorDefault
              ),
            ),
            SizedBox(height: 5.h,),
            ref.watch(responseStatusProvider) == "pending" || ref.watch(responseStatusProvider) == "recording"? hintText() : const SizedBox.shrink(),
          ]
        )
      )
      ]
    );
  }

  Widget hintText() {
    return Text(
      "只有該故事的創作者會收到此留言",
      style: TextStyle(
        fontSize: 14.w,
        color: Colors.grey
      ),
    );
  }
}
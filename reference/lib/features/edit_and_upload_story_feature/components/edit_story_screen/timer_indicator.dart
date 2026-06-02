import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers.dart';

class TimerIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: ScreenUtil().screenWidth / 2,),
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: SizedBox(
            height: 380.h,
            child: VerticalDivider(thickness: 2, width: 1, color: Colors.white)
          )
        ),
        Column(
          children: [
            SizedBox(height: 105.h,),
          ],
        )
      ]
    );
  }
}
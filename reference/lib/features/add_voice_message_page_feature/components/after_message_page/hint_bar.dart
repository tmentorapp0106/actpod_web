import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

class HintBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          opening(),
          voiceMessage(),
          afterMessage()
        ],
      )
    );
  }

  Widget opening() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1"
        ),
        Container(
          margin: EdgeInsets.only(right: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            color: Colors.grey
          ),
          child: Text(
            "開場內容",
            style: TextStyle(
              fontSize: 14.w,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ]
    );
  }

  Widget voiceMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "2"
        ),
        Container(
          margin: EdgeInsets.only(left: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            color: Colors.grey
          ),
          child: Text(
            "加入的語音留言串",
            style: TextStyle(
              fontSize: 14.w,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ]
    );
  }

  Widget afterMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "3"
        ),
        Container(
          margin: EdgeInsets.only(left: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            color: DesignColor.primary50
          ),
          child: Text(
            "結尾內容",
            style: TextStyle(
              fontSize: 14.w,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ]
    );
  }
}
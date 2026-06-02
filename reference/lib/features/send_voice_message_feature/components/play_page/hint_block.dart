import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

class HintBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("1"),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.w),
                  color: DesignColor.neutral300
                ),
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                child: Text(
                  "已加入的語音",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.w
                  ),
                ),
              )
            ],
          ),
          SizedBox(width: 8.w,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("2"),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    color: DesignColor.actpodPrimary400
                ),
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                child: Text(
                  "本則語音",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.w
                  ),
                ),
              )
            ],
          )
        ],
      )
    );
  }
}
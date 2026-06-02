import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreMessageDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Text(
        "你錄製的開場內容，將會在加入的語音留言串前播放",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.w,
        ),
      )
    );
  }
}
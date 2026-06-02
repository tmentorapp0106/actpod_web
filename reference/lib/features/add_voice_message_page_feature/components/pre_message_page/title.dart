import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreMessageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
      child: Text(
        "錄製開場內容",
        style: TextStyle(
          fontSize: 24.w,
          fontWeight: FontWeight.bold
        ),
      )
    );
  }
}
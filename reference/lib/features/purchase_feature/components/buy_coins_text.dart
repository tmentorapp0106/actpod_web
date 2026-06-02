import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

class BuyCoinsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Text(
        "購買 Podcoins",
        style: TextStyle(
          color: ConfigColor.textColorDefault,
          fontSize: 16.sp
        ),
      )
    );
  }
}
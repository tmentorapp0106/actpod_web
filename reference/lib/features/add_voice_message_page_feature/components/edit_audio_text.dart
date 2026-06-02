import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

class EditAudioText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "編輯音檔",
      style: TextStyle(
        fontSize: 24.w,
        color: ConfigColor.textColorDefault
      ),
    );
  }
}
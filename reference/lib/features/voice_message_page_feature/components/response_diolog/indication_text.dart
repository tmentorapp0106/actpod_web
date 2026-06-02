import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';

class IndicationText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "按住開始錄製(5分鐘內)",
      style: TextStyle(
        color: Color(0xff8f8f8f),
        fontSize: 14.sp
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawHistoryTitle extends StatelessWidget {
  const WithdrawHistoryTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.history_rounded,
          size: 20.w,
        ),
        SizedBox(width: 8.w),
        Text(
          '您的提領紀錄',
          style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
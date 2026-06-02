import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddVoiceTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "將留言串加進故事",
        style: TextStyle(
          fontSize: 24.w,
          fontWeight: FontWeight.bold
        ),
      )
    );
  }
}
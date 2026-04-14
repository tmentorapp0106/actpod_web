import 'package:actpod_web/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActPodBackButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        myRouter.pop();
      },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 24.w
      )
    );
  }
}
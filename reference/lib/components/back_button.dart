import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/router.dart';

class ActPodBackButton extends StatelessWidget{
  final VoidCallback? pressFunction;

  const ActPodBackButton({super.key, this.pressFunction});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: pressFunction ?? () {
        router.pop();
      },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 24.w
      )
    );
  }
}